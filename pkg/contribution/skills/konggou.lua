local konggou = fk.CreateSkill {
  name = "yyfy_konggou",
}

Fk:loadTranslationTable {
  ["yyfy_konggou"] = "控构",
  [":yyfy_konggou"] = "你可以将体力值/手牌数调整为一，并视为使用一张可以使体力值/手牌数变化的牌。（每回合每牌名限一次）",
}

local hand_change = {"dismantlement", "snatch", "ex_nihilo", "amazing_grace"} -- 拆顺无中，五谷

-- 游戏开始时，根据房间中开启的牌名，充实“可以使体力值变化的表”hp_change，这个效果不应该被无效
konggou:addEffect(fk.GameStart, {
  can_refresh = function (self, event, target, player, data)
    return player and player:hasSkill(self.name, true, true)
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:addTableMark(player, "yyfy_konggou-hp-change", "peach") -- 桃
    player.room:addTableMark(player, "yyfy_konggou-hp-change", "god_salvation") -- 桃园结义
    for _, name in ipairs(Fk:getAllCardNames("bt")) do -- 伤害类牌
      if Fk:cloneCard(name).is_damage_card then
        player.room:addTableMark(player, "yyfy_konggou-hp-change", name)
      end
    end
    local hp_change = player:getTableMark("yyfy_konggou-hp-change")
    player:setMark("yyfy_konggou-hp-num", #hp_change)
    for _, name in ipairs(hp_change) do
      player.room:addTableMark(player, "yyfy_konggou-hp", name)
    end
    for _, name in ipairs(hand_change) do
      player.room:addTableMark(player, "yyfy_konggou-hand", name)
    end
  end
})

-- 回合内用视为技view_as，印各种牌
-- 回合外用触发技，只能印桃
konggou:addEffect("viewas", {
  interaction = function (self, player)
    local choices = player:getTableMark("yyfy_konggou-hand")
    table.insertTableIfNeed(choices, player:getTableMark("yyfy_konggou-hp"))
    local all_choices = hand_change
    table.insertTableIfNeed(all_choices, player:getTableMark("yyfy_konggou-hp-change"))
    return UI.CardNameBox {
      choices = player:getViewAsCardNames(konggou.name, choices),
      all_choices = all_choices,
      default_choice = "Cancel",
    }
  end,
  view_as = function (self, player, cards)
    local name = self.interaction.data
    if name == "Cancel" then return end
    if Fk.all_card_types[name] == nil then return end
    local card = Fk:cloneCard(name)
    card.skillName = konggou.name
    return card
  end,
  before_use = function (self, player, use)
    local name = self.interaction.data
    if table.contains(player:getTableMark("yyfy_konggou-hp"), name) then
      if not player.room:askToSkillInvoke(player, {
        skill_name = konggou.name,
        prompt = "控构：是否要将体力值调整到1，并视为使用"..Fk:translate(name).."？"
      }) then return "Cancel" end
      player.hp = 1
      player.room:broadcastProperty(player, "hp")
      player.room:removeTableMark(player, "yyfy_konggou-hp", name)
    else
      local num = #player:getCardIds(Player.Hand)
      if num > 1 then
        if #player.room:askToDiscard(player, {
          min_num = num - 1,
          max_num = num - 1,
          skill_name = konggou.name,
          prompt = "控构：请将手牌数弃至1张，并视为使用"..Fk:translate(name),
          cancelable = true
        }) == 0 then return "Cancel" end
      elseif num < 1 then
        if not player.room:askToSkillInvoke(player, {
          skill_name = konggou.name,
          prompt = "控构：是否要摸1张牌，并视为使用"..Fk:translate(name).."？"
        }) then return "Cancel" end
        player:drawCards(1, konggou.name)
      end
      player.room:removeTableMark(player, "yyfy_konggou-hand", name)
    end
  end,
  enabled_at_response = Util.FalseFunc
})

konggou:addEffect(fk.AskForCardUse, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
    Exppattern:Parse(data.pattern):matchExp("peach")
    and table.contains(player:getTableMark("yyfy_konggou-hp"), "peach")
    and player.room:askToSkillInvoke(player, {
      skill_name = konggou.name,
      prompt = "控构：是否要将体力值调整至1，并视为使用一张【桃】？"
    })
  end,
  on_cost = function (self, event, target, player, data)
    player.hp = 1
    player.room:broadcastProperty(player, "hp")
  end,
  on_trigger = function (self, event, target, player, data)
    data.result = ({
      from = player,
      card = Fk:cloneCard("peach"),
      tos = {}
    })
    player.room:removeTableMark(player, "yyfy_konggou-hp", "peach")
  end
})

konggou:addEffect(fk.TurnEnd, {
  can_refresh = function (self, event, target, player, data)
    return player and player:hasSkill(self.name, true) and
    (#player:getTableMark("yyfy_konggou-hp") ~= player:getMark("yyfy_konggou-hp-num")
    or #player:getTableMark("yyfy_konggou-hand") ~= 4)
  end,
  on_refresh = function (self, event, target, player, data)
    if #player:getTableMark("yyfy_konggou-hp") ~= player:getMark("yyfy_konggou-hp-num") then
      for _, name in ipairs(player:getTableMark("yyfy_konggou-hp-change")) do
        player.room:addTableMarkIfNeed(player, "yyfy_konggou-hp", name)
      end
    end
    if #player:getTableMark("yyfy_konggou-hand") ~= 4 then
      for _, name in ipairs(hand_change) do
        player.room:addTableMarkIfNeed(player, "yyfy_konggou-hand", name)
      end
    end
  end
})

return konggou
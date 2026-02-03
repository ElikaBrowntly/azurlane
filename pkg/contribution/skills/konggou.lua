local konggou = fk.CreateSkill {
  name = "yyfy_konggou",
}

Fk:loadTranslationTable {
  ["yyfy_konggou"] = "控构",
  [":yyfy_konggou"] = "你可以将体力值/手牌数变更为1，并视为使用一张不因对方使用牌而可以使体力值/手牌数变化的牌。（每回合每牌名限一次，限军争牌堆）",
}

local hand_change = {"dismantlement", "snatch", "ex_nihilo", "amazing_grace",-- 拆顺无中，五谷
"savage_assault", "archery_attack", "fire_attack", "duel"} -- 南蛮万箭，火攻决斗

local hp_change = {"slash", "peach", "savage_assault", "archery_attack",-- 杀桃，南万
"fire_attack", "duel", "god_salvation", "analeptic"} -- 火攻决斗桃园，酒

konggou:addEffect(fk.GameStart, {
  can_refresh = function (self, event, target, player, data)
    return player and player:hasSkill(self.name, true, true)
  end,
  on_refresh = function (self, event, target, player, data)
    for _, name in ipairs(hp_change) do
      player.room:addTableMarkIfNeed(player, "yyfy_konggou-hp", name)
    end
    for _, name in ipairs(hand_change) do
      player.room:addTableMarkIfNeed(player, "yyfy_konggou-hand", name)
    end
  end
})
-- 回合内用视为技view_as，印各种牌
-- 回合外用触发技，只能印桃
konggou:addEffect("viewas", {
  interaction = function (self, player)
    local choices = {}
    if player.hp == 1 then
      choices = player:getTableMark("yyfy_konggou-hand")
    else
      choices = player:getTableMark("yyfy_konggou-hp")
    end
    if #player:getCardIds(Player.Hand) ~= 1 then
      table.insertTableIfNeed(choices, player:getTableMark("yyfy_konggou-hand"))
    end
    table.removeOne(choices, "analeptic") -- 主动印牌不应该能印酒
    local all_choices = hand_change
    table.insertTableIfNeed(all_choices, hp_change)
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
    local pure_hand = {"dismantlement", "snatch", "ex_nihilo", "amazing_grace"} -- 只能通过调整手牌数印
    local pure_hp = {"slash", "peach", "god_salvation"} -- 只能通过调整体力值印
    local in_common = {"savage_assault", "archery_attack", "fire_attack", "duel"} -- 共有的牌名
    local case = 0
    if table.contains(pure_hp, name) then case = 1
    elseif table.contains(in_common, name) then
      if #player:getCardIds(Player.Hand) == 1 then case = 1
      elseif player.hp == 1 then
      else
        if player.room:askToChoice(player, {
          skill_name = konggou.name,
          choices = {"调整体力值", "调整手牌数"},
          prompt = "控构：请选择要通过哪种方式印牌？"
          }) == "调整体力值" then
          case = 1
        end
      end
    end
    if case == 1 then
      if not player.room:askToSkillInvoke(player, {
        skill_name = konggou.name,
        prompt = "控构：是否要将体力值调整到1，并视为使用"..Fk:translate(name).."？"
      }) then return "Cancel" end
      player.hp = 1
      player.room:broadcastProperty(player, "hp")
      player.room:removeTableMark(player, "yyfy_konggou-hp", name) -- 两种方式共用牌名次数
      player.room:removeTableMark(player, "yyfy_konggou-hand", name)
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
      player.room:removeTableMark(player, "yyfy_konggou-hp", name) -- 两种方式共用牌名次数
      player.room:removeTableMark(player, "yyfy_konggou-hand", name)
    end
  end,
  enabled_at_response = Util.FalseFunc,
  enabled_at_play = function (self, player)
    return player.hp ~= 1 or #player:getCardIds(Player.Hand) ~= 1
  end
})
-- 求桃时印桃
konggou:addEffect(fk.AskForCardUse, {
  can_trigger = function (self, event, target, player, data)
    local case = 0
    if table.contains(player:getTableMark("yyfy_konggou-hp"), "peach") then case = case + 1 end
    if table.contains(player:getTableMark("yyfy_konggou-hp"), "analeptic") then case = case + 2 end
    if not (target == player and player:hasSkill(self.name) and case ~= 0
    and Exppattern:Parse(data.pattern):matchExp("peach|analeptic") and player.hp ~= 1
    ) then return false end
    if case == 3 then
      local choice = player.room:askToChoice(player, {
        choices = {"peach", "analeptic"},
        skill_name = konggou.name,
        prompt = "控构：是否要将体力值调整至1，并视为使用一张【桃】或【酒】？",
        cancelable = true
      })
      if choice ~= "Cancel" then
        event:setCostData(self, {choice = choice})
        return true
      end
    end
    if case == 2 then
      if player.room:askToSkillInvoke(player, {
        skill_name = konggou.name,
        prompt = "控构：是否要将体力值调整至1，并视为使用一张【酒】？",
        })
      then
        event:setCostData(self, {choice = "analeptic"})
        return true
      end
    end
    if case == 1 then
      if player.room:askToSkillInvoke(player, {
        skill_name = konggou.name,
        prompt = "控构：是否要将体力值调整至1，并视为使用一张【桃】？",
        })
      then
        event:setCostData(self, {choice = "peach"})
        return true
      end
    end
  end,
  on_trigger = function (self, event, target, player, data)
    local choice = event:getCostData(self).choice
    player.hp = 1
    player.room:broadcastProperty(player, "hp")
    data.result = ({
      from = player,
      card = Fk:cloneCard(choice),
      tos = {}
    })
    player.room:removeTableMark(player, "yyfy_konggou-hp", choice)
  end
})

konggou:addEffect(fk.TurnEnd, {
  can_refresh = function (self, event, target, player, data)
    return player and player:hasSkill(self.name, true) and
    (#player:getTableMark("yyfy_konggou-hp") ~= 8
    or #player:getTableMark("yyfy_konggou-hand") ~= 8)
  end,
  on_refresh = function (self, event, target, player, data)
    if #player:getTableMark("yyfy_konggou-hp") ~= 8 then
      for _, name in ipairs(hp_change) do
        player.room:addTableMarkIfNeed(player, "yyfy_konggou-hp", name)
      end
    end
    if #player:getTableMark("yyfy_konggou-hand") ~= 8 then
      for _, name in ipairs(hand_change) do
        player.room:addTableMarkIfNeed(player, "yyfy_konggou-hand", name)
      end
    end
  end
})

return konggou
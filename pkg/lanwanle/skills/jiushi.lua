local jiushi = fk.CreateSkill{
  name = "lan__jiushi",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["lan__jiushi"] = "酒诗",
  [":lan__jiushi"] = "持恒技，若你的武将牌正面朝上，你可以翻面视为使用一张【酒】。"..
  "你使用梅花牌无距离限制且不可被响应。当你受到伤害后，或当你发动〖落英〗累计获得至少X张牌后"..
  "（X为你的体力上限），你可以翻面。你翻面后获得一张锦囊牌。",
  
  ["#lan__jiushi"] = "酒诗：你可以翻面，视为使用一张【酒】",
  ["@lan__jiushi_count"] = "酒诗",

  ["$lan__jiushi1"] = "置酒高殿上，亲友从我游。",
  ["$lan__jiushi2"] = "走马行酒醴，驱车布鱼肉。",
  ["$lan__jiushi3"] = "乐饮过三爵，缓带倾庶羞。",
  ["$lan__jiushi4"] = "归来宴平乐，美酒斗十千。",
  ["$lan__jiushi5"] = "花落白宣上，秉笔有天工。",
  ["$lan__jiushi6"] = "泼墨染秋意，落花亦有情。",
  ["$lan__jiushi7"] = "心愤无所表，下笔即成篇。"
}

jiushi:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@lan__jiushi_count", 0)
end)

jiushi:addEffect("viewas", {
  anim_type = "support",
  prompt = "#lan__jiushi",
  pattern = "analeptic",
  filter_pattern = {
    min_num = 0,
    max_num = 0,
    pattern = "",
    subcards = {}
  },
  before_use = function(self, player)
    player:turnOver()
  end,
  view_as = function(self)
    local c = Fk:cloneCard("analeptic")
    c.skillName = jiushi.name
    return c
  end,
  enabled_at_play = function (self, player)
    return player.faceup
  end,
  enabled_at_response = function (self, player, response)
    return player.faceup and not response
  end,
})

jiushi:addEffect(fk.Damaged, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiushi.name) and (data.extra_data or {}).jiushi_check
  end,
  on_use = function(self, event, target, player, data)
    player:turnOver()
  end,
})

jiushi:addEffect(fk.DamageInflicted, {
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.jiushi_check = true
  end,
})
-- 落英获得牌后计数增加，达到体力上限后询问是否翻面
jiushi:addEffect(fk.AfterCardsMove, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(jiushi.name) then
      for _, move in ipairs(data) do
        if move.skillName == "dl__luoying" and move.to == player and player:getMark("@lan__jiushi_count") >= player.maxHp then
          return player.room:askToChoice(player, {
          skill_name = self.name,
          choices = {"确定", "取消"},
          prompt = "落英牌达到了体力上限。是否要翻面？"
          }) == "确定"
        end
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    player:turnOver()
  end,

  can_refresh = function (self, event, target, player, data)
    if player:hasSkill(jiushi.name, true) and not player.faceup then
      for _, move in ipairs(data) do
        if move.skillName == "dl__luoying" and move.to == player and player.room.current ~= player then
          return true
        end
      end
    end
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    for _, move in ipairs(data) do
      if move.skillName == "dl__luoying" and move.to == player then
        room:addPlayerMark(player, "@lan__jiushi_count", #move.moveInfo)
      end
    end
  end,
})

jiushi:addEffect(fk.PreCardUse, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(jiushi.name) then
      return target == player and data.card.suit == Card.Club and
        (data.card.trueName == "slash" or data.card:isCommonTrick())
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    data.disresponsiveList = table.simpleClone(player.room.players)
  end,
})

jiushi:addEffect(fk.TurnedOver, {
  can_refresh = function (self, event, target, player, data)
    return player.faceup and player:getMark("@lan__jiushi_count") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@lan__jiushi_count", 0)
  end,
})

jiushi:addEffect("targetmod", {
  bypass_distances = function(self, player, skill, card, to)
    return player:hasSkill(jiushi.name) and card and card.suit == Card.Club
  end,
})
-- 获得锦囊牌
jiushi:addEffect(fk.TurnedOver, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiushi.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = player.room:getCardsFromPileByRule(".|.|.|.|.|trick", 1, "allPiles")
    if #cards > 0 then
      room:obtainCard(player, cards, false, fk.ReasonJustMove, player, jiushi.name)
    end
  end,
})
return jiushi

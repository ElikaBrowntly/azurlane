local xiaowu = fk.CreateSkill {
  name = "lan__xiaowu",
}

Fk:loadTranslationTable {
  ["lan__xiaowu"] = "骁武",
  [":lan__xiaowu"] = "出牌阶段限一次，你可以获得2张【杀】（以此法获得的牌无距离次数限制）。" ..
      "你使用【杀】指定目标后，此技能视为未发动过。",

  ["#lan__xiaowu"] = "骁武：是否要获得2张【杀】",
  ["@@lan__xiaowu-inhand"] = "骁武",

  ["$lan__xiaowu1"] = "百战生豪意，一戟破万军！",
  ["$lan__xiaowu2"] = "烽烟既起，吾当独擎沙场！",
}

xiaowu:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#lan__xiaowu",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    if player:usedSkillTimes(xiaowu.name, Player.HistoryPhase) > 0 then return false end
    return table.find(Fk:currentRoom().draw_pile, function(id)
          return Fk:getCardById(id).trueName == "slash"
        end) or
        table.find(Fk:currentRoom().discard_pile, function(id)
          return Fk:getCardById(id).trueName == "slash"
        end)
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local cards = room:getCardsFromPileByRule("slash", 2, "allPiles")
    if #cards > 0 then
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, xiaowu.name, nil, false, player,
        "@@lan__xiaowu-inhand")
    end
  end,
})

xiaowu:addEffect(fk.PreCardUse, {
  can_refresh = function(self, event, target, player, data)
    return target == player and data.card:getMark("@@lan__xiaowu-inhand") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.extraUse = true
  end,
})

xiaowu:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and card:getMark("@@lan__xiaowu-inhand") > 0
  end,
  bypass_distances = function (self, player, skill, card, to)
    return card and card:getMark("@@lan__xiaowu-inhand") > 0
  end
})

xiaowu:addEffect(fk.TargetSpecified, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(xiaowu.name, true)
  end,
  on_refresh = function(self, event, target, player, data)
    player:clearSkillHistory(xiaowu.name)
  end,
})

return xiaowu
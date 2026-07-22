local jianbai = fk.CreateSkill {
  name = "lan__jianbai",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["lan__jianbai"] = "坚白",
  [":lan__jianbai"] = "你使用一张牌后，可以重铸任意张牌。" ..
      "每名角色的回合结束时，你交给一名其他角色一张牌并摸3张牌。",

  ["#lan__jianbai-ask"] = "坚白：你可以重铸任意张牌",
  ["#lan__jianbai-give"] = "坚白：交给一名其他角色一张牌，摸3张数的牌",

  ["$lan__jianbai1"] = "阿爷答应我的事，一定能做到。",
  ["$lan__jianbai2"] = "花开有期，世间流水终会相逢。",
  ["$lan__jianbai3"] = "唱山歌咧，这边唱来那边和~",
  ["$lan__jianbai4"] = "什么有脚不走路咧？什么无脚满江游？",
}

jianbai:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local cards = player.room:askToCards(player, {
      min_num = 1,
      max_num = #player:getCardIds("he"),
      include_equip = true,
      skill_name = jianbai.name,
      prompt = "#lan__jianbai-ask",
      cancelable = true
    })
    if not cards or #cards == 0 then return false end
    event:setCostData(self, { cards = cards })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local cards = (event:getCostData(self) or {}).cards or {}
    if #cards == 0 then return end
    player.room:recastCard(cards, player, jianbai.name)
  end,
})

jianbai:addEffect(fk.TurnEnd, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(self) and not player:isNude() and
        #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to, card = room:askToChooseCardsAndPlayers(player, {
      min_card_num = 1,
      max_card_num = 1,
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      pattern = ".",
      skill_name = jianbai.name,
      prompt = "#lan__jianbai-give",
      cancelable = false,
    })
    room:moveCardTo(card, Card.PlayerHand, to[1], fk.ReasonGive, jianbai.name, nil, false, player)
    if player.dead then return end
    player:drawCards(3, jianbai.name)
  end,
})

return jianbai
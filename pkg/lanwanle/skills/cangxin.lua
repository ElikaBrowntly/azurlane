local cangxin = fk.CreateSkill {
  name = "lan__cangxin",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["lan__cangxin"] = "藏心",
  [":lan__cangxin"] = "锁定技，你摸牌时，展示牌堆底5张牌并多摸其中红色牌数的牌。" ..
      "当你受到伤害时，弃置牌堆底3张牌，令伤害值-X（X为以此法弃置的红色牌数）。",

  ["$lan__cangxin1"] = "世间百味，品在唇而味在心。",
  ["$lan__cangxin2"] = "我藏风雨于心，故而衣不沾雨。",
  ["$lan__cangxin3"] = "红豆藏香米，共裹一青叶，其味佳否？",
  ["$lan__cangxin4"] = "手折素柳织祥瑞，且将艾荷寄清风。"
}

cangxin:addEffect(fk.BeforeDrawCard, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:getNCards(5, "bottom")
    room:turnOverCardsFromDrawPile(player, cards, cangxin.name)
    room:delay(1500)
    local n = #table.filter(cards, function(id)
      return Fk:getCardById(id).color == Card.Red
    end)
    data.num = data.num + n
    room:returnCardsToDrawPile(player, cards, cangxin.name, "bottom")
  end
})

cangxin:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(cangxin.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to_throw = room:getNCards(3, "bottom")
    local n = #table.filter(to_throw, function(id)
      return Fk:getCardById(id).color == Card.Red
    end)
    data:changeDamage(-n)
    room:moveCards {
      ids = to_throw,
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonPutIntoDiscardPile,
      skillName = cangxin.name,
      proposer = player,
    }
  end,
})

return cangxin
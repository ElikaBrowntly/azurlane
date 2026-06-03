local wuku = fk.CreateSkill {
  name = "lan__wuku",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["lan__wuku"] = "武库",
  [":lan__wuku"] = "锁定技，当一名角色使用装备牌时，你获得1枚“武库”然后摸一张牌。每回合结束时，你将“武库”补充至体力上限。",

  ["@lan__wuku"] = "武库",

  ["$lan__wuku1"] = "损益万枢，竭世运机。",
  ["$lan__wuku2"] = "胸藏万卷，充盈如库。",
}

wuku:addEffect(fk.CardUsing, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(wuku.name) and data.card.type == Card.TypeEquip
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@lan__wuku")
    player:drawCards(1, wuku.name)
  end,
})

wuku:addEffect(fk.TurnEnd, {
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self) and player:getMark("@lan__wuku") < player.maxHp
  end,
  on_use = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@lan__wuku", player.maxHp)
  end
})

return wuku
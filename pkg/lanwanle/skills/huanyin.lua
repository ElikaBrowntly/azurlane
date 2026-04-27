local huanyin = fk.CreateSkill {
  name = "lan__huanyin",
  tags = { Skill.Compulsory }
}

Fk:loadTranslationTable {
  ["lan__huanyin"] = "还阴",
  [":lan__huanyin"] = "锁定技，有角色进入濒死状态时，你从牌堆获得4种花色的牌各一张。",

  ["$lan__huanyin1"] = "世间千百物，物物皆相思。",
  ["$lan__huanyin2"] = "伊人将逝，何物为葬？",
}

huanyin:addEffect(fk.EnterDying, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local suits = { 1, 2, 3, 4 }
    local cards = {}
    local id = -1
    for i = #room.draw_pile, 1, -1 do
      id = room.draw_pile[i]
      if table.removeOne(suits, Fk:getCardById(id).suit) then
        table.insert(cards, id)
      end
    end
    if #cards > 0 then
      room:moveCards({
        ids = cards,
        to = player,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonJustMove,
        proposer = player,
        skillName = huanyin.name,
        moveVisible = true,
      })
    end
  end,
})

return huanyin
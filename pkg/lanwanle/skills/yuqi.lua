local yuqi = fk.CreateSkill {
  name = "lan__yuqi",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable {
  ["lan__yuqi"] = "隅泣",
  [":lan__yuqi"] = "持恒技，当一名角色受到伤害后，你可以观看牌堆顶的5张牌，将其中任意张交给受伤角色，任意张牌自己获得，剩余的牌置于牌堆顶。",

  ["#lan__yuqi"] = "隅泣：请分配卡牌，余下的牌置于牌堆顶",

  ["$lan__yuqi1"] = "孤影独泣，困于隅角。",
  ["$lan__yuqi2"] = "向隅而泣，黯然伤感。",
  ["$lan__yuqi3"] = "玉儿摔倒了，要阿娘抱抱。",
  ["$lan__yuqi4"] = "雪花纷飞，独存寒冬。"
}

yuqi:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(yuqi.name) and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
          skill_name = yuqi.name,
        }) then
      event:setCostData(self, { tos = { target } })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player, { target })
    local n1, n2, n3 = 5, 5, 5
    local cards = room:getNCards(n1)
    room:turnOverCardsFromDrawPile(player, cards, yuqi.name, false)
    local result = room:askToArrangeCards(player, {
      skill_name = yuqi.name,
      card_map = {
        cards,
        "Top", target.general, player.general
      },
      prompt = "#lan__yuqi",
      box_size = 0,
      max_limit = { n1, n2, n3 },
      min_limit = { 0, 0, 0 }
    })
    local top, bottom = result[2], result[3]
    local moveInfos = {}
    if #top > 0 then
      table.insert(moveInfos, {
        ids = top,
        to = target,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonGive,
        proposer = player,
        skillName = yuqi.name,
        moveVisible = false,
        visiblePlayers = player,
      })
    end
    if #bottom > 0 then
      table.insert(moveInfos, {
        ids = bottom,
        to = player,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonJustMove,
        proposer = player,
        moveVisible = false,
        skillName = yuqi.name,
      })
    end
    room:moveCards(table.unpack(moveInfos))
    room:returnCardsToDrawPile(player, cards, yuqi.name, "top", false)
  end,
})

return yuqi
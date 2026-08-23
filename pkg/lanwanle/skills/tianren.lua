local tianren = fk.CreateSkill {
  name = "lan__tianren",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["lan__tianren"] = "天任",
  [":lan__tianren"] = "锁定技，当一张牌进入弃牌堆后，你获得1个“天任”标记。当你的“天任”标记不少于你的体力上限时，" ..
      "你移去体力上限等量个“天任”，加1点体力上限并摸等量张牌。",

  ["@lan__tianren"] = "天任",

  ["$lan__tianren1"] = "举石补苍天，舍我更复其谁？",
  ["$lan__tianren2"] = "天地同协力，何愁汉道不昌？",
  ["$lan__tianren3"] = "青天犹在汉，其辰在北，其兴在我！",
  ["$lan__tianren4"] = "天之所任者，负重如山，行役在远！"
}

tianren:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(tianren.name) then
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          return true
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local x = 0
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          x = x + 1
        end
      end
    end
    room:addPlayerMark(player, "@lan__tianren", x)
    while player:getMark("@lan__tianren") >= player.maxHp do
      local maxHp = player.maxHp
      room:removePlayerMark(player, "@lan__tianren", maxHp)
      room:changeMaxHp(player, 1)
      if player.dead then return false end
      player:drawCards(maxHp, tianren.name)
      if player.dead then return false end
    end
  end,
})

tianren:addLoseEffect(function(self, player, is_death)
  player.room:setPlayerMark(player, "@lan__tianren", 0)
end)

return tianren
local huitian = fk.CreateSkill{
  name = "lan__huitian",
}

Fk:loadTranslationTable{
  ["lan__huitian"] = "回天",
  [":lan__huitian"] = "其他角色的回合结束时，你可摸一张牌并执行一个使用牌无距离次数限制的额外回合。",

  ["$lan__huitian1"] = "胸怀赤义，敢问苍天争命数！",
  ["$lan__huitian2"] = "但凭天澍，偏离覆地逆乾坤！"
}

huitian:addEffect(fk.TurnEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return not target.dead and target ~= player and player:hasSkill(huitian.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, huitian.name)
    if not player.dead then
      player:gainAnExtraTurn(true, huitian.name)
    end
  end,
})

huitian:addEffect("targetmod", {
  bypass_distances = function(self, player, skill, card, to)
    return player and player:hasSkill(self) and Fk:currentRoom().current == player
    and player.insideExtraTurn and player:getCurrentExtraTurnReason() == huitian.name and card
  end,
  bypass_times = function(self, player, skill, scope, card)
    return player and player:hasSkill(self) and Fk:currentRoom().current == player
    and player.insideExtraTurn and player:getCurrentExtraTurnReason() == huitian.name and card
  end,
})

return huitian
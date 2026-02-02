local shishen = fk.CreateSkill {
  name = "yyfy_shishen",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["yyfy_shishen"] = "弑神",
  [":yyfy_shishen"] = "永恒技，当你杀死其他角色时，你篡夺其所有技能、体力上限和所有牌。",
}

-- 永恒技：失去此技能时重新添加
shishen:addLoseEffect(function(self, player, is_death)
  player.room:handleAddLoseSkills(player, self.name, nil, false, true)
end)

shishen:addEffect(fk.Death, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and data.killer and data.killer == player
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:chat("弑杀神明，篡夺神明的权能。")
    -- 篡夺所有技能，不触发相关时机
    local skills = table.map(table.filter(target.player_skills, function(s)
      return s:isPlayerSkill(target) and s.visible and not player:hasSkill(s, true)
    end), function(s)
      return s.name
    end)
    for _, s in ipairs(skills) do
      room:handleAddLoseSkills(target, "-"..s, nil, true, true)
    end
    room:handleAddLoseSkills(player, skills, nil, true, true)
    -- 篡夺体力上限
    player.maxHp = player.maxHp + target.maxHp
    room:broadcastProperty(player, "maxHp")
    target.maxHp = 0
    room:broadcastProperty(target, "maxHp")
    target.hp = 0
    room:broadcastProperty(target, "hp")
    -- 篡夺所有牌
    if not target:isKongcheng() then
      room:moveCardTo(target:getCardIds("h"), Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, false, player)
    end
  end,
})

return shishen
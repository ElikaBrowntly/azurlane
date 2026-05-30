local duoqi = fk.CreateSkill{
  name = "lan__duoqi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["lan__duoqi"] = "夺炁",
  [":lan__duoqi"] = "锁定技，每名角色的回合开始时和结束时，你执行一个额外的出牌阶段。"..
    "你造成的伤害+X（X为本回合你造成的最高伤害）。",
  ["@lan__duoqi-turn"] = "夺炁",
  ["$lan__duoqi1"] = "你的胆气，一文不值！",
  ["$lan__duoqi2"] = "你的脊梁，不堪一击！",
}

duoqi:addEffect(fk.TurnStart, {
  anim_type = "offensive",
  priority = 0.1,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(duoqi.name)
  end,
  on_use = function(self, event, target, player, data)
    player:gainAnExtraPhase(Player.Play, duoqi.name, false)
  end,
})

duoqi:addEffect(fk.TurnEnd, {
  anim_type = "offensive",
  priority = 0.1,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(duoqi.name)
  end,
  on_refresh = function(self, event, target, player, data)
    player:gainAnExtraPhase(Player.Play, duoqi.name, false)
  end,
})

duoqi:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player == target and player:hasSkill(duoqi.name) and player:getMark("@lan__duoqi-turn") > 0
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(player:getMark("@lan__duoqi-turn"))
  end,
})

duoqi:addEffect(fk.Damage, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player == target and player:hasSkill(duoqi.name) and data.damage > player:getMark("@lan__duoqi-turn")
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@lan__duoqi-turn", data.damage)
  end,
})

duoqi:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@lan__duoqi-turn", 0)
end)

return duoqi
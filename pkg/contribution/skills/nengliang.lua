local nengliang = fk.CreateSkill {
  name = "yyfy_nengliang",
}

Fk:loadTranslationTable{
  ["yyfy_nengliang"] = "能量",
  [":yyfy_nengliang"] = "锁定技，你使用牌无次数和距离限制，你造成的伤害等同于你的技能数量；"..
  "当你受到其他角色的伤害时，你对其造成一点伤害。"
}

nengliang:addEffect(fk.PreCardUse, {
  can_refresh = function(self, event, target, player, data)
    return player and player:hasSkill(self) and data.from == player
  end,
  on_refresh = function(self, event, target, player, data)
    data.extraUse = true
  end,
})

nengliang:addEffect("targetmod", {
  bypass_distances = function (self, player, skill, card, to)
    return card and player and player:hasSkill(self)
  end,
  bypass_times = function (self, player, skill, scope, card, to)
    return card and player and player:hasSkill(self)
  end,
})

nengliang:addEffect(fk.DetermineDamageCaused, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self) and target == player
  end,
  on_trigger = function (self, event, target, player, data)
    data.damage = #player.player_skills
  end
})

nengliang:addEffect(fk.DamageInflicted, {
  anim_type = "masochism",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.from and data.from ~= player
  end,
  on_trigger = function (self, event, target, player, data)
    player.room:damage({
      from = player,
      to = data.from,
      damage = 1,
      skillName = nengliang.name
    })
  end
})

return nengliang
local skill = fk.CreateSkill {
  name = "yyfy_guangzhihuihuang",
}

Fk:loadTranslationTable {
  ["yyfy_guangzhihuihuang"] = "光之辉煌",
  [":yyfy_guangzhihuihuang"] = "你受到大于1的伤害后，暴击率提升5%，造成大于1的伤害时令其增加5%，可叠加。",
}

skill:addEffect(fk.Damaged, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.damage > 1
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:addPlayerMark(player, skill.name)
  end
})

skill:addEffect(fk.DamageCaused, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self)
    and data.damage > 0 and math.random(20) <= player:getMark(skill.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    data:changeDamage(data.damage)
  end
})

skill:addEffect(fk.DetermineDamageCaused, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self)
    and data.damage > 1 and player:getMark(skill.name) > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    data:changeDamage(math.ceil(data.damage * 0.05 * player:getMark(skill.name)))
  end
})

return skill
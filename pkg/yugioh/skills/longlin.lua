local longlin = fk.CreateSkill {
  name = "yyfy_longlin",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["yyfy_longlin"] = "龙鳞",
  [":yyfy_longlin"] = "锁定技，你不会因技能受到伤害，其他角色不能把你作为虚拟牌或转化牌的目标。" ,
}

longlin:addEffect(fk.DetermineDamageInflicted, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and not data.card
  end,
  on_use = function (self, event, target, player, data)
    data:preventDamage()
  end
})

longlin:addEffect("prohibit", {
  is_prohibited = function(self, from, to, card)
    return card and from and to and from ~= to and to:hasSkill(self.name) and card:isVirtual()
  end,
})

return longlin
local hufu = fk.CreateSkill {
  name = "yyfy_hufu",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable{
  ["yyfy_hufu"] = "护符",
  [":yyfy_hufu"] = "持恒技，防止你受到的伤害。"
}

hufu:addEffect(fk.DetermineDamageInflicted, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    data:preventDamage()
  end
})

return hufu
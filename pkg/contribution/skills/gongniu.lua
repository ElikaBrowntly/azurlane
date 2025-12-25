local gongniu = fk.CreateSkill{
  name = "yyfy_gongniu",
}

Fk:loadTranslationTable{
  ["yyfy_gongniu"] = "公牛",
  [":yyfy_gongniu"] = "你对其他角色造成的伤害改为其体力值。",
}

gongniu:addEffect(fk.DetermineDamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.to ~= player
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = data.to.hp
  end
})

return gongniu

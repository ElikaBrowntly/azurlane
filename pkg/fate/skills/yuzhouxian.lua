local yuzhou = fk.CreateSkill {
  name = "yyfy_yuzhouxian",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["yyfy_yuzhouxian"] = "宇宙线",
  [":yyfy_yuzhouxian"] = "持恒技，你造成或受到伤害后，对方减1点体力上限。"
}

yuzhou:addEffect(fk.Damage, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.to
    and not data.to.dead and data.to.maxHp > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:changeMaxHp(data.to, -1)
  end
})

yuzhou:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.from
    and not data.from.dead and data.from.maxHp > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:changeMaxHp(data.from, -1)
  end
})

return yuzhou
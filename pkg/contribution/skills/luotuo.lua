local luotuo = fk.CreateSkill {
  name = "yyfy_luotuo",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["yyfy_luotuo"] = "骆驼",
  [":yyfy_luotuo"] = "你受到伤害后回复等量体力。"
}

luotuo:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function (self, event, target, player, data)
    return player:isAlive() and data.to == player and player:hasSkill(self.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:recover{
      who = player,
      num = data.damage,
      recoverBy = player,
      skillName = self.name,
    }
  end,
})

return luotuo
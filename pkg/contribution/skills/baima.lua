local baima = fk.CreateSkill{
  name = "yyfy_baima",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["yyfy_baima"] = "白马",
  [":yyfy_baima"] = "其他角色造成伤害结算后，你可以对其造成等量火焰伤害。",
  ["#yyfy_baima-invoke"] = "白马：是否要对 %dest 造成 %arg 点火焰伤害？",
}

baima:addEffect(fk.DamageFinished, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return data.from and player and player:hasSkill(self.name) and data.from ~= player
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "#yyfy_baima-invoke:"..data.from.id..":"..tostring(data.damage)
    })
  end,
  on_use = function(self, event, target, player, data)
      player.room:damage{
      from = player,
      to = data.from,
      damage = data.damage,
      skillName = self.name,
    }
  end
})

return baima

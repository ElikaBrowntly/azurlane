local skill = fk.CreateSkill {
  name = "yyfy_huangjinshuhai",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable {
  ["yyfy_huangjinshuhai"] = "<font color='#FFA500'>黄金树海</font>",
  [":yyfy_huangjinshuhai"] = "<font color='#FFA500'>持恒技，你的第二血条被击破后，你接下来受到的6次"
  .."伤害减少20%，且你每次造成伤害会吸收目标的1点生命。</font>",
  ["@yyfy_huangjinshuhai"] = "黄金树海"
}

skill:addEffect(fk.AfterPlayerRevived, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
        (player.tag["@yyfy_xietiao_XibalbaORT"] or 0) == 4
  end,
  on_cost = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@yyfy_huangjinshuhai", 6)
  end
})

skill:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:getMark("@yyfy_huangjinshuhai") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data:changeDamage(-math.ceil(data.damage * 0.2))
    player.room:addPlayerMark(player, "@yyfy_huangjinshuhai", -1)
  end
})

skill:addEffect(fk.Damage, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
        (player.tag["@yyfy_xietiao_XibalbaORT"] or 0) <= 4
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if not data.to.dead then
      room:loseHp(data.to, 1, skill.name, player)
    end
    room:recover({
      who = player,
      num = 1,
      skillName = skill.name,
      recoverBy = player
    })
  end
})

return skill
local skill = fk.CreateSkill {
  name = "yyfy_baotouji",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable {
  ["yyfy_baotouji"] = "<font color='#8300FF'>豹头纪</font>",
  [":yyfy_baotouji"] = "<font color='#8300FF'>持恒技，你的第五血条被击破后，你接下来受到的8次伤害减少20%。</font>",
  ["@yyfy_baotouji"] = "豹头纪"
}

skill:addEffect(fk.AfterPlayerRevived, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
        (player.tag["@yyfy_xietiao_XibalbaORT"] or 0) == 1
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@yyfy_baotouji", 8)
  end
})

skill:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:getMark("@yyfy_baotouji") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data:changeDamage(-math.ceil(data.damage * 0.2))
    player.room:addPlayerMark(player, "@yyfy_baotouji", -1)
  end
})

return skill
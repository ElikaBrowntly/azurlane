local skill = fk.CreateSkill {
  name = "yyfy_heianji",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable {
  ["yyfy_heianji"] = "<font color='#0982FF'>黑暗纪</font>",
  [":yyfy_heianji"] = "<font color='#0982FF'>持恒技，你的第四血条被击破后，你翻至背面。"
  .."此后，当你受到伤害后你翻至正面。</font>",
}

skill:addEffect(fk.AfterPlayerRevived, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.faceup
      and (player.tag["@yyfy_xietiao_XibalbaORT"] or 0) == 2
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:turnOver()
  end
})

skill:addEffect(fk.Damaged, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and not player.faceup
    and (player.tag["@yyfy_xietiao_XibalbaORT"] or 0) <= 2
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:turnOver()
  end
})

return skill
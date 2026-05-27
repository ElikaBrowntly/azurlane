local buchang = fk.CreateSkill {
  name = "yyfy_beilunbuchang",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable {
  ["yyfy_beilunbuchang"] = "悖论补偿",
  [":yyfy_beilunbuchang"] = "持恒技，你始终跳过判定阶段；你的判定区每存在一张牌，你造成的伤害+20%（向上取整）。",
}

buchang:addEffect(fk.EventPhaseChanging, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
        data.phase == Player.Judge and not data.skipped
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.skipped = true
  end,
})

buchang:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and #player:getCardIds("j") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data:changeDamage(math.ceil(data.damage * 0.2 * #player:getCardIds("j")))
  end
})

return buchang
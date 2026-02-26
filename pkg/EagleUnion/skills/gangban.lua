local gangban = fk.CreateSkill{
  name = "yyfy_gangban",
  tags = { Skill.Compulsory }
}

Fk:loadTranslationTable {
  ["yyfy_gangban"] = "钢板",
  [":yyfy_gangban"] = "锁定技，你受到的伤害-1。",

  ["$yyfy_gangban1"] = "啊呜！！",
  ["$yyfy_gangban2"] = "萨拉妹妹爱你哦~",
  ["$yyfy_gangban3"] = "可不许嫌弃我小哦？…各种意义上的都是！"
}

gangban:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_use = function (self, event, target, player, data)
    data.damage = data.damage - 1
  end
})

return gangban
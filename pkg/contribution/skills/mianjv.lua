local mianjv = fk.CreateSkill{
  name = "yyfy_mianjv",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["yyfy_mianjv"] = "面具",
  [":yyfy_mianjv"] = "锁定技，你视为装备着<a href='xieshenmianjv'>【邪神面具】</a>。",

  ["xieshenmianjv"] = "<b>【邪神面具】</b><br>锁定技，你不能被翻面。当你受到大于1点的伤害时，此伤害-1。"
}

-- 不能被翻面
mianjv:addEffect(fk.BeforeTurnOver, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.faceup
  end,
  on_use = function (self, event, target, player, data)
    data.prevented = true
  end,
})

-- 减伤
mianjv:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.damage >= 2
  end,
  on_use = function (self, event, target, player, data)
    data.damage = data.damage - 1
  end,
})

return mianjv
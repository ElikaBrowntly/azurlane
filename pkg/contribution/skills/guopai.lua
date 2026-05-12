local skill = fk.CreateSkill {
  name = "yyfy_guopai",
}

Fk:loadTranslationTable {
  ["yyfy_guopai"] = "过牌",
  [":yyfy_guopai"] = "当你使用牌时，你可以摸一张牌。",

  ["$yyfy_guopai1"] = "只此四字，绝、妙、好、辞。",
  ["$yyfy_guopai2"] = "君侯，他日君若乘上高轩，我当为君揽辔策马！"
}

skill:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return data.from == player and player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, skill.name)
  end,
})

return skill
local yanru = fk.CreateSkill {
  name = "yyfy_yanru",
}

Fk:loadTranslationTable{
  ["yyfy_yanru"] = "晏如",
  [":yyfy_yanru"] = "出牌阶段限一次，你可以摸10张牌。",

  ["$yyfy_yanru1"] = "国有宁日，民有丰年，大同也。",
  ["$yyfy_yanru2"] = "及臻厥成，天下晏如也。"
}

yanru:addEffect("active", {
  anim_type = "drawcard",
  prompt = "晏如：你可以摸10张牌",
  max_phase_use_time = 1,
  target_num = 0,
  card_num = 0,
  on_use = function(self, room, effect)
    effect.from:drawCards(10, yanru.name)
  end,
})

yanru:addAI(Fk.Ltk.AI.newActiveStrategy {
  think = function(self, ai)
    return { }, 10
  end,
})

return yanru
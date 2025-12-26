local skill = fk.CreateSkill {
  name = "yyfy_jv_skill",
}

Fk:loadTranslationTable{
  ["yyfy_jv_skill"] = "句",
  ["#yyfy_jv_skill"] = "这只是一张【句】，无任何效果。"
}

skill:addEffect("cardskill", {
  prompt = "#yyfy_jv_skill",
  can_use = Util.FalseFunc,
  on_effect = function(self, room, effect)
  end,
})

return skill
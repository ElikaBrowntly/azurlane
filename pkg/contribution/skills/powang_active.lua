local powang = fk.CreateSkill {
  name = "yyfy_powang_active",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable{
  ["yyfy_powang_active"] = "破妄",
  [":yyfy_powang_active"] = "持恒技，每回合限一次，你发动〖欺诈〗时，你可令对方先选择选项且对你可见，然后你再选择。",
}

powang:addEffect("active", {
  anim_type = "control",
  can_use = Util.FalseFunc,
  target_num = 0,
  card_num = 0,
  on_use = Util.TrueFunc
})

return powang
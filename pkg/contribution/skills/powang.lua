local powang = fk.CreateSkill {
  name = "yyfy_powang",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable{
  ["yyfy_powang"] = "破妄",
  [":yyfy_powang"] = "持恒技，每回合限一次，你发动〖欺诈〗时，你可令对方先选择选项且对你可见，然后你再选择。",
}
-- 具体实现耦合在〖欺诈〗中
return powang
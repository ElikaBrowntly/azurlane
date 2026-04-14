local xietiao = fk.CreateSkill {
  name = "yyfy_xietiao",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["yyfy_xietiao"] = "血条",
  [":yyfy_xietiao"] = "持恒技，你获得2个额外的血条。你死亡时，若血条已全被击破，则变更为“移动ORT”。(未实装)"
}

return xietiao
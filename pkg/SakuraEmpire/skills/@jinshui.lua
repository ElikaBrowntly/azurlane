local jinshui = fk.CreateSkill {
  name = "@yyfy_jinshui",
  anim_type = "negative",
}

Fk:loadTranslationTable {
  [":@yyfy_jinshui"] = "拥有「进水」的角色每回合结束时失去1点体力。" ,
}

return jinshui
local amuweiruqiu = fk.CreateSkill {
  name = "yyfy_amuweiruqiu",
  tags = { Skill.Compulsory }
}

Fk:loadTranslationTable{
  ["yyfy_amuweiruqiu"] = "阿母为汝求",
  [":yyfy_amuweiruqiu"] = "锁定技，你拥有〖媒言〗〖妁语〗和〖作保〗。"
}

amuweiruqiu:addAcquireEffect(function (self, player, is_start, src)
  player.room:handleAddLoseSkills(player, { "meiyan", "shuoyu", "zuobao" }, self.name)
end)

return amuweiruqiu
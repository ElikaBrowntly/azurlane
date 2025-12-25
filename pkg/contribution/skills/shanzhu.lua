local shanzhu = fk.CreateSkill {
  name = "yyfy_shanzhu",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["yyfy_shanzhu"] = "山猪",
  [":yyfy_shanzhu"] = "获得此技能时，令一名其他角色失去所有体力"
}

shanzhu:addAcquireEffect(function (self, player, is_start)
  local room = player.room
  local to = room:askToChoosePlayers(player, {
    targets = room:getOtherPlayers(player),
    min_num = 1,
    max_num = 1,
    skill_name = self.name
  })[1]
  room:loseHp(to, to.hp, self.name, player)
end)

return shanzhu
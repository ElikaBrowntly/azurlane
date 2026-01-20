local xingshou = fk.CreateSkill{
  name = "yyfy_xingshou",
  anim_type = "support",
  tags = {Skill.Limited},
}

Fk:loadTranslationTable{
  ["yyfy_xingshou"] = "行狩",
  [":yyfy_xingshou"] = "限定技，当你杀死一名角色后，你将体力回复至上限并升级〖厉勇〗。",

  ["$yyfy_xingshou"] = "巡环一甲子，嫉恶如仇雠！"
}

xingshou:addEffect(fk.Death, {
  can_trigger = function (self, event, target, player, data)
    return player and data.killer == player and player:hasSkill(self.name)
    and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player)
    player.room:recover({
      who = player,
      num = player.maxHp - player.hp,
      recoverBy = player,
      skillName = self.name
    })
    player.room:addPlayerMark(player, "yyfy_liyong_update")
  end
})

return xingshou
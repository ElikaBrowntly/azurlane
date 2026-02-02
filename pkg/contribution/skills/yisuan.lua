local yisuan = fk.CreateSkill{
  name = "yyfy_yisuan",
}

Fk:loadTranslationTable{
  ["yyfy_yisuan"] = "亦算",
  [":yyfy_yisuan"] = "你的回合内，当一名角色进入濒死状态时，你可以选择自己一个已发动的限定技，令此技能视为未发动。",
  ["#yyfy_yisuan-reset"] = "亦算：请重置一个限定技",
  ["#yyfy_YisuanReset"] = "%from 重置了限定技〖%arg〗",
  ["$yyfy_yisuan1"] = "吾亦能善算谋划",
  ["$yyfy_yisuan2"] = "算计人心，我也可略施一二",
}

yisuan:addEffect(fk.EnterDying, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return player and player.room:getCurrent()== player and player:hasSkill(self.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skills = table.filter(player.player_skills, function(s)
      return s:hasTag(Skill.Limited) and player:usedSkillTimes(s.name, Player.HistoryGame) > 0
    end)
    if #skills == 0 then return false end
    local skillNames = table.map(skills, Util.NameMapper)
    local skill = room:askToChoice(player, {
        choices = skillNames,
        skill_name = yisuan.name,
        prompt = "#yyfy_yisuan-reset",
      })
    player:setSkillUseHistory(skill, 0, Player.HistoryGame)
    room:sendLog{
      type = "#yyfy_YisuanReset",
      from = player.id,
      arg = skill,
    }
  end,
})

return yisuan
local red = fk.CreateSkill {
  name = "yyfy_red",
  tags = { Skill.Limited },
  related_skills = { "yyfy_21stJingshenbingren" }
}

Fk:loadTranslationTable {
  ["yyfy_red"] = "red",
  [":yyfy_red"] = "限定技，回合开始时，若场上只有两名角色，你可以失去所有技能，获得〖21世纪精神病人〗。",
}

red:addEffect(fk.TurnStart, {
  anim_type = "big",
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self) and player:usedSkillTimes(red.name, Player.HistoryGame) == 0) then return end
    local players = table.filter(player.room:getAllPlayers(false), function(p)
      return p:isAlive() or p.rest > 0
    end)
    return #players == 2
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skills = player:getSkillNameList()
    local lose = {}
    for _, s in ipairs(skills) do
      ---@diagnostic disable-next-line: undefined-field
      if not Fk.skills[s].mode_skill then
        table.insert(lose, "-" .. s)
      end
    end
    room:handleAddLoseSkills(player, lose)
    room:handleAddLoseSkills(player, "yyfy_21stJingshenbingren")
  end
})

return red
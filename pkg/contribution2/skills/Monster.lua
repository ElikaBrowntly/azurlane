local monster = fk.CreateSkill {
  name = "yyfy_Monster",
  tags = { Skill.Permanent, Skill.Limited },
}

Fk:loadTranslationTable {
  ["yyfy_Monster"] = "Monster",
  [":yyfy_Monster"] = "持恒技，限定技，回合开始时，你可以失去所有技能，令一名角色死亡。",
}

monster:addEffect(fk.TurnStart, {
  anim_type = "big",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:usedSkillTimes(monster.name, Player.HistoryGame) == 0
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      targets = room:getAlivePlayers(false),
      min_num = 1,
      max_num = 1,
      skill_name = monster.name,
      prompt = "Monster：你可以失去所有技能，令一名角色死亡"
    })
    if not tos or #tos ~= 1 then return false end
    local cost = event:getCostData(self) or {}
    cost.tos = tos
    event:setCostData(self, cost)
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tos = (event:getCostData(self) or {}).tos or {}
    if #tos ~= 1 then return end
    local skills = player:getSkillNameList()
    local lose = {}
    for _, s in ipairs(skills) do
      ---@diagnostic disable-next-line: undefined-field
      if not Fk.skills[s].mode_skill then
        table.insert(lose, "-"..s)
      end
    end
    room:handleAddLoseSkills(player, lose)
    room:killPlayer({
      who = tos[1],
      killer = player
    })
  end
})

return monster
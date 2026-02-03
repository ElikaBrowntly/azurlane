local tuogu = fk.CreateSkill{
  name = "yyfy_tuogu",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["yyfy_tuogu"] = "托孤",
  [":yyfy_tuogu"] = "持恒技，当一名角色死亡时，你可以获得其武将牌上的任意个技能。",

  ["#yyfy_tuogu-invoke"] = "托孤：你可以获得 %dest 的任意个技能",
  ["#yyfy_tuogu-choice"] = "托孤：请选择要获得的技能",

  ["$yyfy_tuogu1"] = "君托以六尺之孤，爽，当寄百里之命。",
  ["$yyfy_tuogu2"] = "先帝以大事托我，任重而道远。",
  ["$yyfy_tuogu3"] = "陛下托孤，臣定当竭尽忠诚，至死方休！"
}

tuogu:addEffect(fk.Deathed, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) then
      local all_skills = Fk.generals[target.general]:getSkillNameList()
      if target.deputyGeneral ~= "" then
        table.insertTableIfNeed(all_skills, Fk.generals[target.deputyGeneral]:getSkillNameList())
      end
      if #all_skills > 0 then
        event:setCostData(self, {extra_data = all_skills})
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "#yyfy_tuogu-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}, extra_data = event:getCostData(self).extra_data})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = event:getCostData(self).extra_data
    choices = room:askToChoices(player, {
      choices = choices,
      skill_name = self.name,
      prompt = "#yyfy_tuogu-choice",
      min_num = 0,
      max_num = #choices
    })
    room:handleAddLoseSkills(player, choices)
  end,
})

return tuogu
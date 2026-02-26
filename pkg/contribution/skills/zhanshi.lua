local zhanshi = fk.CreateSkill{
  name = "yyfy_zhanshi",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["yyfy_zhanshi"] = "战士",
  [":yyfy_zhanshi"] = "获得此化身时，你可以令一名其他角色失去所有技能直到你的回合结束。",
  ["yyfy_zhanshi_skills"] = "技能",
  ["yyfy_zhanshi_target"] = "目标"
}

zhanshi:addAcquireEffect(function (self, player, is_start)
  local room = player.room
  local to = room:askToChoosePlayers(player, {
    targets = room:getOtherPlayers(player),
    min_num = 1,
    max_num = 1,
    skill_name = self.name,
    prompt = "战士：请选择一名其他角色，令其暂时失去所有技能"
  })[1]
  if to == nil then return end
  local skills = to:getAllSkills()
  if skills == nil then return end
  for _, skill in ipairs(skills) do
    if skill:isPlayerSkill(to, true) then
      room:handleAddLoseSkills(to, "-"..skill.name)
      room:addTableMark(player, "yyfy_zhanshi_skills", skill.name)
    end
  end
  room:setPlayerMark(player, "yyfy_zhanshi_target", to.id) -- 这里只添加标记，用于恢复技能。
  --恢复技能的效果写在主技能〖权能〗里，因为本技能在回合结束就会失去，撑不到那么久
end)

return zhanshi
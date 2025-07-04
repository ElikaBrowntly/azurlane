local skill = fk.CreateSkill{
  name = "hangmutexing",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable({
  ["hangmutexing"] = "航母特性",
  [":hangmutexing"] = "锁定技，准备阶段，你获得1个「空袭」标记。当你需要使用或打出【杀】时，你可以移去1个「空袭」视为使用或打出之"..
  "（以此法使用的杀无距离和次数限制，且可指定任意名角色为目标）。"..
  "每当你失去1个「空袭」后，你可令任意名其他角色将技能还原为游戏开始时的状态。",
  
  ["@kongxi"] = "空袭",
  
  ["#hangmutexing-use"] = "你可以移去1个「空袭」视为使用或打出【杀】",
  ["#hangmutexing-choose"] = "请选择要重置技能的角色",
  ["#hangmutexing-target"] = "航母特性：请选择任意名角色作为【杀】的目标",
  
  ["$hangmutexing1"] = "虎豹骁骑，甲兵自当冠宇天下。",
  ["$hangmutexing2"] = "非虎贲难入我营，唯坚铠方配锐士。",
})

--重置技能
local function resetPlayerSkills(room, targetPlayer)
  
  local currentSkills = targetPlayer:getSkillNameList()
  
  if #currentSkills > 0 then
    room:handleAddLoseSkills(targetPlayer, "-"..table.concat(currentSkills, "|-"), nil, false, true)
  end

  local initialSkills = Fk.generals[targetPlayer.general]:getSkillNameList()
  if targetPlayer.deputyGeneral ~= "" then
    table.insertTableIfNeed(initialSkills, Fk.generals[targetPlayer.deputyGeneral]:getSkillNameList())
  end
  
  if #initialSkills > 0 then
    for _, skill_name in ipairs(initialSkills) do
      local skillObj = Fk.skills[skill_name]
      if skillObj then
        targetPlayer:setSkillUseHistory(skill_name, 0, Player.HistoryPhase)
        targetPlayer:setSkillUseHistory(skill_name, 0, Player.HistoryTurn)
        targetPlayer:setSkillUseHistory(skill_name, 0, Player.HistoryRound)
        targetPlayer:setSkillUseHistory(skill_name, 0, Player.HistoryGame)

        if skillObj:hasTag(Skill.Quest) then
          room:setPlayerMark(targetPlayer, MarkEnum.QuestSkillPreName .. skill_name, 0)
        end
        if skillObj:hasTag(Skill.Switch) then
          room:setPlayerMark(targetPlayer, MarkEnum.SwithSkillPreName .. skill_name, fk.SwitchYang)
        end
      end
    end

    room:handleAddLoseSkills(targetPlayer, table.concat(initialSkills, "|"), nil, false, true)
  end
end

--无次数限制
skill:addEffect("targetmod", {
  bypass_times = function(self, player, skillObj, scope, card)
    if player:hasSkill(skill.name) and 
       skillObj and 
       skillObj.trueName == "slash_skill" and 
       scope == Player.HistoryPhase and
       card and 
       card.skillName == skill.name then
      return true
    end
  end,
})

-- 视为使用杀
skill:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "slash",
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    if #cards ~= 0 then return end
    local c = Fk:cloneCard("slash")
    c.skillName = skill.name
    return c
  end,
  before_use = function(self, player, use)
    local room = player.room

    room:removePlayerMark(player, "@kongxi", 1)
    
    --不计入使用次数
    use.extra_data = use.extra_data or {}
    use.extra_data.bypass_distances = true
    use.extra_data.bypass_times = true
    use.extra_data.bypass_target_num = true
    use.extraUse = true
    
    use.card.skillName = skill.name
    
    if not use.card.responding then
      local targets = room:getOtherPlayers(player)
      
      if #targets > 0 then
        local targetPlayers = {}
        for _, p in ipairs(targets) do
          if p:isAlive() then
            table.insert(targetPlayers, p)
          end
        end

        local tos = room:askToChoosePlayers(player, {
          min_num = 0,
          max_num = #targetPlayers,
          targets = targetPlayers,
          prompt = "#hangmutexing-target",
          skill_name = skill.name,
          cancelable = true,
        })
        
        if tos and #tos > 0 then
          use.tos = tos
        end
      end
    end
    
    -- 询问是否要重置技能
    local other_players = room:getOtherPlayers(player)
    if #other_players > 0 then
      local choices = room:askToChoosePlayers(player, {
        min_num = 0,
        max_num = #other_players,
        targets = other_players,
        prompt = "#hangmutexing-choose",
        skill_name = skill.name,
        cancelable = true,
      })
      
      for _, targetPlayer in ipairs(choices or {}) do
        resetPlayerSkills(room, targetPlayer)
      end
    end
    
    return true
  end,
  enabled_at_play = function(self, player)
    return player:getMark("@kongxi") > 0
  end,
  enabled_at_response = function(self, player)
    return player and not player.dead and player:getMark("@kongxi") > 0
  end,
})

-- 准备阶段获得空袭标记
skill:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and 
           player:hasSkill(skill.name) and 
           player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@kongxi", 1)
  end,
})

return skill
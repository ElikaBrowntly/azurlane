local shiri = fk.CreateSkill {
  name = "yyfy_shiri",
  anim_type = "control",
  tags = {Skill.Permanent}
}

Fk:loadTranslationTable {
  ["yyfy_shiri"] = "蚀日",
  [":yyfy_shiri"] = "永恒技，每局游戏限3次，出牌阶段你可以弃置5张牌（其中1张可以来自其他角色），令任意名其他角色本局游戏中"..
  "不能发动其武将牌上的技能。" ,

  ["@@yyfy_shiri"] = "蚀日",
  ["$yyfy_shiri"] = ""
}

shiri:addLoseEffect(function(self, player, is_death)
  local room = player.room
  room:handleAddLoseSkills(player, shiri.name, nil, false, true)
end)

-- 不检查玩家存活性和技能失效性的神人技能
local skills_after_death = {
  "Luaputi", "emo__guangguang", "emo__xinyang"
}

shiri:addEffect("active", {
  mute = true,
  max_game_use_time = 3,
  can_use = function (self, player)
    if not (player and player:isAlive() and player:hasSkill(self.name) and
      Fk:currentRoom():getCurrent() == player and player.phase == Player.Play) then return false end
    return #player:getCardIds("he") >= 4
  end,
  card_filter = function (self, player, to_select, selected, selected_targets)
    return #selected <= 4
  end,
  feasible = function (self, player, selected, selected_cards, card)
    return #selected_cards == 4 or #selected_cards == 5
  end,
  prompt = "蚀日：请弃置4~5张牌",
  on_cost = function (self, player, data, extra_data)
    local room = player.room
    local dis = data.cards
    if #dis == 0 then return nil end
    if #dis == 4 then
      local targets = {}
      if room:getOtherPlayers(player, false, false) == nil then return nil end
      for _, t in ipairs(room:getOtherPlayers(player, false, false)) do
        if not t:isNude() then
          table.insert(targets, t)
        end
      end
      if #targets == 0 then return nil end
      local target = room:askToChoosePlayers(player, {
        targets = targets,
        min_num = 1,
        max_num = 1,
        skill_name = shiri.name,
        prompt = "蚀日：请选择一名角色，弃置其一张牌作为代替"
      })
      if #target == 0 then return nil end
      local plus = room:askToChooseCard(player, {
        target = target[1],
        flag = "he",
        skill_name = shiri.name,
        prompt = "蚀日：请弃置该角色的一张牌作为代替"
      })
      room:throwCard(dis, shiri.name, player, player)
      room:throwCard(plus, shiri.name, target[1], player)
      table.insert(dis, plus)
      return { cards = dis }
    end
    room:throwCard(dis, shiri.name, player, player)
    return { cards = dis }
  end,
  on_use = function (self, room, skillUseEvent)
    if skillUseEvent.cost_data == nil then return false end
    if not skillUseEvent.cost_data.cards or #skillUseEvent.cost_data.cards ~= 5 then return false end
    room:doSuperLightBox("packages/hidden-clouds/qml/shiri.qml")
    local player = skillUseEvent.from
    player:broadcastSkillInvoke(shiri.name)
    local targets = room:getOtherPlayers(player, false, false)
    if #targets == 0 then return false end
    targets = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 999,
      skill_name = shiri.name,
      prompt = "蚀日：请选择任意名其他角色，这些角色无法再发动技能"
    })
    for _, t in ipairs(targets) do
      room:addPlayerMark(t, "@@yyfy_shiri")
      for _, skill in ipairs(t.player_skills) do
        if skill:isPlayerSkill(t, true) then
          skill.skeleton.max_game_use_time = 0
          skill.times = 0
          if skill.skeleton.max_branches_use_time ~= nil then
          -- 如果是函数，获取其返回值
            local branch_times = skill.skeleton.max_branches_use_time
              if type(branch_times) == "function" then
                branch_times = branch_times(skill.skeleton, t)
              end
            -- 遍历并修改分支次数
            if branch_times and type(branch_times) == "table" then
              for branch_name, times_table in pairs(branch_times) do
                if times_table and type(times_table) == "table" then
                  for history_type, max_times in pairs(times_table) do
                    times_table[history_type] = 0
                  end
                end
              end
              -- 重新赋值
              skill.skeleton.max_branches_use_time = branch_times
            end
          end
        end
        t:addSkillUseHistory(skill.name, 9999999999999999999999999)
        t:addSkillBranchUseHistory(skill.name, "", 9999999999999999999999999)
        if t:hasSkill(skill.name) then
          room:handleAddLoseSkills(t, "-"..skill.name, nil, false, true)
        end
      end
      -- 对神人技能重拳出击
      for _, s in ipairs(skills_after_death) do
        if t:hasSkill(s, true, true) then
          room:handleAddLoseSkills(t, "-"..s, nil, false, true)
        end
      end
    end
  end
})

shiri:addEffect("invalidity", {
  invalidity_func = function(self, from, skill)
    return from:getMark("@@yyfy_shiri") > 0 and skill:isPlayerSkill(from, false)
  end,
})

return shiri
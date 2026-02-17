local mingshen = fk.CreateSkill {
  name = "yyfy_mingshen",
  anim_type = "control",
  tags = {Skill.Permanent}
}

Fk:loadTranslationTable {
  ["yyfy_mingshen"] = "冥神",
  [":yyfy_mingshen"] = "永恒技，其他角色进入濒死状态时，你可以终止一切结算直接令其死亡，并结束当前回合。"..
  "濒死/死亡/修整的角色不能使用牌或技能。其他角色复活后，你可以令其死亡。",

  ["#yyfy_mingshen-invoke"] = "冥神：是否要终止一切结算，直接令 %dest 死亡？",
  ["#yyfy_mingshen-kill"] = "冥神：%dest想要复活，是否要杀死他？"
}

mingshen:addLoseEffect(function(self, player, is_death)
  local room = player.room
  room:handleAddLoseSkills(player, mingshen.name, nil, false, true)
end)

-- 不检查玩家存活性和技能失效性的神人技能
local skills_after_death = {
  "Luaputi", "emo__guangguang", "emo__xinyang"
}

mingshen:addEffect(fk.EnterDying, {
  priority = 2,
  can_trigger = function (self, event, target, player, data)
    return target ~= player and not player.dead and player:hasSkill(self.name)
    and player.room:askToSkillInvoke(player, {
      skill_name = mingshen.name,
      prompt = "#yyfy_mingshen-invoke::"..target.id
    })
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = {}
    room:killPlayer({ who = target, killer = player})
    target._splayer:setDied(true)
    for _, p in ipairs(room:getAllPlayers()) do
      if p.dead or p.rest > 0 or p.dying then
        table.insert(targets, p)
      end
    end
    table.insertIfNeed(targets, data.who)
    for _, t in ipairs(targets) do
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
    room.logic:breakTurn()
  end,
  on_use = Util.FalseFunc
})

mingshen:addEffect("invalidity", {
  invalidity_func = function(self, from, skill)
    return from.dead or from.rest > 0 or from.dying
  end,
})

mingshen:addEffect("prohibit", {
  prohibit_func = function(self, player, card)
    return player.dead or player.rest > 0 or player.dying
  end,
})

mingshen:addEffect(fk.AfterPlayerRevived, {
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self.name) and target ~= player
    and player.room:askToSkillInvoke(player, {
      skill_name = mingshen.name,
      prompt = "#yyfy_mingshen-kill::"..target.id
    })
  end,
  on_trigger = function (self, event, target, player, data)
    player.room:killPlayer({
      who = target,
      killer = player
    })
  end
})

mingshen:addEffect(fk.SkillEffect, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target and player and player:hasSkill(self, true, true) and (target.dying or target.dead or target.rest > 0)
    and data.skill:isPlayerSkill(target) and target:hasSkill(data.skill:getSkeleton().name, true, true)
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    local e = room.logic:getCurrentEvent():findParent(GameEvent.SkillEffect)
    if e then
      room.logic:breakEvent(e)
    end
  end,
})

return mingshen
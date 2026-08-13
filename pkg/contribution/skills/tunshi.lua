local tunshi = fk.CreateSkill {
  name = "yyfy_tunshi",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable {
  ["yyfy_tunshi"] = "吞噬",
  [":yyfy_tunshi"] = "持恒技，当你获得此技能时，可以<a href='yyfy_tunshi_tunshi'>吞噬</a>一名角色。"..
  "当你造成伤害后，你可以获得对方任意个技能。游戏结束时，若你获得胜利，则你永久拥有本局游戏获得的技能。"..
  "出牌阶段，你可以调整你的技能。",

  ["yyfy_tunshi_tunshi"] = "<b>吞噬</b>：获得被吞噬者的所有技能，且当其获得技能时，你也获得之。",
  ["#yyfy_tunshi-invoke"] = "吞噬：是否获得 %dest 的任意个技能？",
  ["#yyfy_tunshi-skill"] = "吞噬：获得%dest的任意个技能",
}

tunshi:addEffect(fk.Damage, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
        data.to ~= player and not data.to.dead
  end,
  on_cost = function(self, event, target, player, data)
    local to = data.to
    local room = player.room
    --排除夺锐自身
    local skills = {}
    for _, s in ipairs(to.player_skills) do
      if s:isPlayerSkill(to) and s.name ~= tunshi.name then
        table.insertIfNeed(skills, s.name)
      end
    end
    if #skills == 0 then return false end
    if not room:askToSkillInvoke(player, {
          skill_name = self.name,
          prompt = "#yyfy_tunshi-invoke::" .. to.id }) then
      return false
    end
    -- 选择技能
    local choice = room:askToCustomDialog(player, {
      skill_name = tunshi.name,
      qml_path = "packages/utility/qml/ChooseSkillBox.qml",
      extra_data = { skills, 1, 999, "#yyfy_tunshi-skill::" .. to.id }
    })
    if not choice or choice == "" then return end
    if type(choice) == "string" then
      choice = {choice}
    end
    event:setCostData(self, {
      skills = choice,
    })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cost_data = event:getCostData(self)
    local skills = cost_data.skills
    if #skills == 0 then return end
    room:handleAddLoseSkills(player, skills)
  end,
})

tunshi:addAcquireEffect(function (self, player, is_start, src)
  local room = player.room
  local to = room:askToChoosePlayers(player, {
    targets = room:getAlivePlayers(),
    min_num = 1,
    max_num = 1,
    skill_name = tunshi.name,
    prompt = "吞噬：你可以吞噬一名角色",
    cancelable = true
  })
  if #to ~= 1 then return end
  local skills = {}
  for _, s in ipairs(to[1].player_skills) do
    if s:isPlayerSkill(to[1]) and s.name ~= tunshi.name then
      table.insertIfNeed(skills, s.name)
    end
  end
  room:handleAddLoseSkills(player, skills)
  local tag = player.tag[tunshi.name] or {}
  table.insertIfNeed(tag, to[1].id)
  player.tag[tunshi.name] = tag
  if player.id <= 0 then return end
  local state = player:getGlobalSaveState("hidden-clouds") or {}
  local save = state["yyfy_tunshi"] or {}
  room:handleAddLoseSkills(player, save)
end)

tunshi:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target ~= player and player:hasSkill(self) and data.skill.name ~= tunshi.name
    and table.contains(player.tag[tunshi.name] or {}, target.id)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:handleAddLoseSkills(player, data.skill.name)
  end
})

tunshi:addEffect(fk.GameFinished, {
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self) and player.id > 0
    and table.contains(data.players, player)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local state = player:getGlobalSaveState("hidden-clouds") or {}
    local save = state["yyfy_tunshi"] or {}
    for _, s in ipairs(player:getSkillNameList()) do
      table.insertIfNeed(save, s)
    end
    state["yyfy_tunshi"] = save
    player:saveGlobalState("hidden-clouds", state)
  end
})

--- 调整技能
---@param player ServerPlayer
local function delete(player)
  local room = player.room
  local state = player:getGlobalSaveState("hidden-clouds") or {}
  local save = state["yyfy_tunshi"] or {}
  local sname = room:askToCustomDialog(player, {
    skill_name = tunshi.name,
    qml_path = "packages/utility/qml/ChooseSkillBox.qml",
    extra_data = { player:getSkillNameList(), 0, 1, "吞噬：请选择要删去的技能" }
  })
  if not sname or sname == "" then return end
  if type(sname) == "table" then
    sname = sname[1]
  end
  room:handleAddLoseSkills(player, "-" .. sname, nil, false, true)
  table.removeOne(save, sname)
  state["yyfy_tunshi"] = save
  player:saveGlobalState("hidden-clouds", state)
end

tunshi:addEffect("active", {
  prompt = "吞噬：你可以调整你的技能池",
  can_use = function (self, player)
    return player and player:hasSkill(self) and player.id > 0
  end,
  card_num = 0,
  target_num = 0,
  on_use = function (self, room, effect)
    delete(effect.from)
  end
})

return tunshi
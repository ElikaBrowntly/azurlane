local pingdai = fk.CreateSkill {
  name = "yyfy_pingdai",
  tags = { Skill.Quest },
  related_skills = { "yyfy_congyun" }
}

Fk:loadTranslationTable {
  ["yyfy_pingdai"] = "凭代",
  [":yyfy_pingdai"] = "使命技，当你拥有〖护符〗时，防止你造成的伤害。回合开始时或其他角色进入濒死状态时，" ..
      "你可以失去〖护符〗。<br>⬤　成功：当你失去〖护符〗后，你获得〖丛云〗，并在场上召唤一位“丛雨”加入战斗。"
}

pingdai:addEffect(fk.DetermineDamageCaused, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:hasSkill("yyfy_hufu", true)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data:preventDamage()
  end
})

pingdai:addEffect(fk.TurnStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:hasSkill("yyfy_hufu", true)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = pingdai.name,
      prompt = "凭代：是否要失去〖护符〗？"
    })
  end,
  on_use = function(self, event, target, player, data)
    player.room:handleAddLoseSkills(player, "-yyfy_hufu")
  end
})

pingdai:addEffect(fk.EnterDying, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player and target ~= player and player:hasSkill(self) and player:hasSkill("yyfy_hufu", true)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = pingdai.name,
      prompt = "凭代：是否要失去〖护符〗？"
    })
  end,
  on_use = function(self, event, target, player, data)
    player.room:handleAddLoseSkills(player, "-yyfy_hufu")
  end
})

pingdai:addEffect(fk.EventLoseSkill, {
  anim_type = "big",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.skill.name == "yyfy_hufu"
        and player:getMark(MarkEnum.QuestSkillPreName .. pingdai.name) ~= "succeed"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:updateQuestSkillState(player, pingdai.name, false)
    room:handleAddLoseSkills(player, "yyfy_congyun")
    local next = room:getPlayerById(player:getNextAlive().id)
    local role = player.role
    if role == "lord" then
      role = "loyalist"
    end
    local npc = room:addNpc(next, {
      role = role,
      role_shown = player.role_shown,
      general = "yyfy_Murasame"
    })
    local operator = room:askToChoosePlayers(player, {
      targets = room:getAlivePlayers(false),
      min_num = 1,
      max_num = 1,
      skill_name = pingdai.name,
      prompt = "凭代：要让谁操控“丛雨”？",
      cancelable = false
    })
    if not operator or #operator ~= 1 or not npc then return end
    operator[1]:control(npc)
  end
})

return pingdai
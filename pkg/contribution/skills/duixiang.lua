local duixiang = fk.CreateSkill {
  name = "yyfy_duixiang",
  anim_type = "defensive",
  tags = {Skill.Permanent}
}

Fk:loadTranslationTable{
  ["yyfy_duixiang"] = "对象",
  [":yyfy_duixiang"] = "永恒技，你无法被其他角色控制；你的武将牌无法被变更；多目标牌对你无效。",
}

duixiang:addLoseEffect(function(self, player, is_death)
  local room = player.room
  room:handleAddLoseSkills(player, duixiang.name, nil, false, true)
end)

duixiang:addEffect(fk.AfterSkillEffect, {
  can_refresh = function (self, event, target, player, data)
    return player and player:hasSkill(self.name) and not player:isControlling(player)
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:doBroadcastNotify("ShowToast", "冥神是我们牌佬唯一指定对象，你连这都要NTR掉吗！")
    player:control(player)
  end
})

duixiang:addEffect(fk.TargetConfirmed, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(duixiang.name) and data.card and data.card.multiple_targets
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.use.nullifiedTargets = data.use.nullifiedTargets or {}
    table.insertIfNeed(data.use.nullifiedTargets, player)
  end,
})

duixiang:addEffect(fk.BeforePropertyChange, {
  is_delay_effect = true,
  can_refresh = function (self, event, target, player, data)
    if target == player and player:hasSkill(self.name, true) then
      return data.from == player and ((data.general and data.general ~= "yyfy_UnderworldGoddess" and player.general == "yyfy_UnderworldGoddess")
      or (data.deputyGeneral and data.deputyGeneral ~= "yyfy_UnderworldGoddess" and player.deputyGeneral == "yyfy_UnderworldGoddess"))
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    player.room:doBroadcastNotify("ShowToast", "冥神！我的老婆！她不能离开我！")
    if data.general ~= "yyfy_UnderworldGoddess" and player.general == "yyfy_UnderworldGoddess" then
      data.general = "yyfy_UnderworldGoddess"
    end
    if data.deputyGeneral ~= "yyfy_UnderworldGoddess" and player.deputyGeneral == "yyfy_UnderworldGoddess" then
      data.deputyGeneral = "yyfy_UnderworldGoddess"
    end
    local mingshen_skills = {"yyfy_shiri", "yyfy_mingshen", "yyfy_duixiang"}
    for _, skill in ipairs(mingshen_skills) do
      if not player:hasSkill(skill, true) then
        room:handleAddLoseSkills(player, skill)
      end
    end
  end,
})

return duixiang
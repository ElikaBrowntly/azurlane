local xuwu = fk.CreateSkill {
  name = "yyfy_xuwu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["yyfy_xuwu"] = "虚无",
  [":yyfy_xuwu"] = "锁定技，当你受到伤害时，终止一切结算并立即结束此回合。你出场时，继承所有技能、终止一切结算并立即行动。"
}

xuwu:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return player and target == player and player:hasSkill(self)
  end,
  on_trigger = function (self, event, target, player, data)
    player.room.logic:breakTurn()
  end
})

xuwu:addEffect(fk.AfterPropertyChange, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    return player and target == player and player:hasSkill(self)
    and (data.general == "yyfy_shenglingpuni" or data.deputyGeneral and data.deputyGeneral == "yyfy_shenglingpuni")
  end,
  on_trigger = function (self, event, target, player, data)
    local room = player.room
    local skills = player.tag["yyfy_puni_jicheng"]
    if type(skills) ~= "table" then
      skills = {}
    end
    for _, skill in ipairs(skills) do
      if not player:hasSkill(skill, true, true) then
        room:handleAddLoseSkills(player, skill.name, xuwu.name)
      end
    end
    room:setBanner(xuwu.name, player.id)
    for _, p in ipairs(room:getAllPlayers()) do
     if p.dead then
      local winner = Fk.game_modes[room:getSettings('gameMode')]:getWinner(p)
      if winner ~= "" then
        room:gameOver(winner)
      end
     end
    end
    room.logic:breakTurn()
  end
})

xuwu:addEffect(fk.EventTurnChanging, {
  mute = true,
  can_refresh = function (self, event, target, player, data)
    return player.room:getBanner(xuwu.name) == player.id
  end,
  on_refresh = function (self, event, target, player, data)
    if data.to == player then
      player.room:setBanner(xuwu.name, 0)
    else
      data.skipped = true
    end
  end,
})

return xuwu
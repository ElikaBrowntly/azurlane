local skill = fk.CreateSkill{
  name = "yyfy_wansha",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable{
  ["yyfy_wansha"] = "完杀",
  [":yyfy_wansha"] = "锁定技，其他角色进入濒死状态时，终止濒死结算与其他一切结算，"..
  "并结束当前回合。然后你选择一名角色立即行动。",

  ["$yyfy_wansha1"] = "吾之所好，杀人诛心。",
  ["$yyfy_wansha2"] = "汝可遣使相问，四下可有援军？"
}

skill:addEffect(fk.EnterDying, {
  priority = 2,
  can_trigger = function (self, event, target, player, data)
    return target ~= player and not player.dead and player:hasSkill(self.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local e = room.logic:getCurrentEvent():findParent(GameEvent.Dying)
    if e then
      local to = room:askToChoosePlayers(player, {
        targets = room:getAlivePlayers(),
        min_num = 1,
        max_num = 1,
        skill_name = skill.name,
        prompt = "请选择一名角色立即行动"
      })
      if #to > 0 then
        room:setBanner(skill.name, to[1].id)
      end
      room:killPlayer({ who = e.data.who, killer = e.data.killer, damage = e.data.damage })
      room.logic:breakTurn()
    end
  end,
})

skill:addEffect(fk.EventTurnChanging, {
  can_refresh = function (self, event, target, player, data)
    return player.room:getBanner(skill.name) == player.id
  end,
  on_refresh = function (self, event, target, player, data)
    if data.to == player then
      player.room:setBanner(skill.name, 0)
    else
      data.skipped = true
    end
  end,
})

return skill
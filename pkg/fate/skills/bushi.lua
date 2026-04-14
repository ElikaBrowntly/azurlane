local bushi = fk.CreateSkill {
  name = "yyfy_bushijianglin",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["yyfy_bushijianglin"] = "捕食降临",
  [":yyfy_bushijianglin"] = "持恒技，共鸣技，当你对一名其他角色造成致命伤害时，你令其死亡。"..
  "你杀死一名角色后，将其<a href='fate_bushi'><font color='red'>捕食</font></a>。",
  ["fate_bushi"] = "<br><b>捕食</b>：<br>获得其所有牌和技能。以此法获得的技能不会因游戏结束而失去。"
}

local ORT = {"yyfy_ORT", "yyfy_mobileORT", "yyfy_flyingORT", "yyfy_XibalbaORT"}

bushi:addAcquireEffect(function(self, player)
  local state = player:getGlobalSaveState("hidden-clouds") or {}
  local save = state["yyfy_bushijianglin"] or {}
  player.room:handleAddLoseSkills(player, save, nil, false, true)
end)

bushi:addEffect(fk.BeforeGameOverJudge, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.killer and data.killer == player
    and (table.contains(ORT, player.general) or table.contains(ORT, player.deputyGeneral))
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 捕食所有技能，不触发相关时机
    local skills = table.map(table.filter(target.player_skills, function(s)
      return s:isPlayerSkill(target) and s.visible and not player:hasSkill(s, true)
    end), function(s)
      return s.name
    end)
    -- 存档
    local state = player:getGlobalSaveState("hidden-clouds") or {}
    local save = state["yyfy_bushijianglin"] or {}
    for _, s in ipairs(skills) do
      table.insertIfNeed(save, s)
    end
    state["yyfy_bushijianglin"] = save
    player:saveGlobalState("hidden-clouds", state)
    for _, s in ipairs(skills) do
      room:handleAddLoseSkills(target, "-"..s, nil, true, true)
    end
    room:handleAddLoseSkills(player, skills, nil, true, true)
    -- 捕食所有牌
    if not target:isAllNude() then
      room:moveCardTo(target:getCardIds("he"), Card.PlayerHand, player, fk.ReasonPrey, bushi.name, nil, false, player)
    end
  end,
})

bushi:addEffect(fk.DetermineDamageCaused, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.to and data.to ~= player
    and data.to.hp <= data.damage and (table.contains(ORT, player.general) or table.contains(ORT, player.deputyGeneral))
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:killPlayer({
      who = data.to,
      killer = player
    })
  end
})

return bushi
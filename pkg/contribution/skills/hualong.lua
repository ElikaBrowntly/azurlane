local hualong = fk.CreateSkill {
  name = "yyfy_hualong",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable {
  ["yyfy_hualong"] = "化龙",
  [":yyfy_hualong"] = "持恒技，游戏开始时，你的回合开始或结束时，你可以化身<font color='red'>十大祖龙" ..
      "</font>之一。当你死亡时，在剩余的祖龙中重新化身并将体力值和体力上限调整为3，然后继承此前化身的技能。"
}

local all_generals = { "yyfy_longchen" }
local j = 1
while j <= 10 do
  table.insert(all_generals, "yyfy_longchen" .. tostring(j))
  j = j + 1
end

hualong:addEffect(fk.GameStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(self)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local i = 1
    local generals = {}
    while i <= 10 do
      table.insert(generals, "yyfy_longchen" .. tostring(i))
      i = i + 1
    end
    player.tag[hualong.name] = generals

    -- 使用自定义对话框选择出场武将
    local choice
    if player.id < 0 then
      -- AI自动随机选择
      choice = generals[math.random(#generals)]
    else
      local result = room:askToCustomDialog(player, {
        skill_name = hualong.name,
        qml_path = "packages/hidden-clouds/qml/Hualong.qml",
        extra_data = { generals }
      })
      if result ~= "" and result.general then
        choice = result.general
      else
        -- 若取消或出错，默认选第一个
        choice = generals[1]
      end
    end

    local skills_snapshot = {}
    for _, s in ipairs(player.player_skills) do
      if s:isPlayerSkill(player) then
        table.insert(skills_snapshot, s)
      end
    end
    player.tag["yyfy_hualong_jicheng"] = skills_snapshot

    local isDeputy = false
    if table.contains(all_generals, player.deputyGeneral) then
      isDeputy = true
    end
    table.removeOne(generals, choice)
    player.tag[hualong.name] = generals
    if #generals == 0 then
      room:doBroadcastNotify("ShowToast", "请注意，这是最后一个祖龙化身了......")
    end
    room:changeHero(player, choice, true, isDeputy)
    player.maxHp = 3
    player.hp = 3
    room:broadcastProperty(player, "maxHp")
    room:broadcastProperty(player, "hp")
    -- 继承所有技能
    for _, s in ipairs(player.tag["yyfy_hualong_jicheng"]) do
      if not player:hasSkill(s, true, true) then
        room:handleAddLoseSkills(player, s.name, hualong.name)
      end
    end
  end
})

hualong:addEffect(fk.BeforeGameOverJudge, {
  anim_type = "support",
  priority = 2,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self, true, true)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if #player.tag[hualong.name] == 0 then
      room:setTag("SkipGameRule", nil)
      return
    end
    room:setTag("SkipGameRule", true)
    local skills_snapshot = {}
    for _, s in ipairs(player.player_skills) do
      if s:isPlayerSkill(player) then
        table.insert(skills_snapshot, s)
      end
    end
    player.tag["yyfy_hualong_jicheng"] = skills_snapshot
    room:revivePlayer(player, false)
    local generals = player.tag[hualong.name]
    -- 使用自定义对话框选择出场武将
    local choice
    if player.id < 0 then
      choice = generals[math.random(#generals)]
    else
      local result = room:askToCustomDialog(player, {
        skill_name = hualong.name,
        qml_path = "packages/hidden-clouds/qml/Hualong.qml",
        extra_data = { generals }
      })
      if result ~= "" and result.general then
        choice = result.general
      else
        choice = generals[1]
      end
    end

    local isDeputy = false
    if table.contains(all_generals, player.deputyGeneral) then
      isDeputy = true
    end
    table.removeOne(generals, choice)
    player.tag[hualong.name] = generals
    if #generals == 0 then
      room:doBroadcastNotify("ShowToast", "请注意，这是最后一个祖龙化身了......")
    end
    room:changeHero(player, choice, true, isDeputy, true, false)
    player.maxHp = 3
    player.hp = 3
    room:broadcastProperty(player, "maxHp")
    room:broadcastProperty(player, "hp")
    -- 继承所有技能
    for _, s in ipairs(player.tag["yyfy_hualong_jicheng"]) do
      if not player:hasSkill(s, true, true) then
        room:handleAddLoseSkills(player, s.name, hualong.name)
      end
    end
    local logic = player.room.logic
    local e = logic:getCurrentEvent()
    logic:breakEvent(e)
  end
})

return hualong
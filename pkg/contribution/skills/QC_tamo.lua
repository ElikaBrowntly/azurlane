local QC_tamo = fk.CreateSkill{
  name = "QC_tamo",
  tags = { Skill.Permanent },
  anim_type = "big",
}

Fk:loadTranslationTable{
  ["QC_tamo"] = "榻谟",
  [":QC_tamo"] = "持恒技，游戏开始以及每轮开始时，你可以重新分配所有角色的座次。",
  ["#QC_tamo-invoke"] = "榻谟：你可以重新分配场上角色的座次",
  ["$QC_tamo"] = "榻谟",
  ["click to exchange"] = "点击交换",
}

QC_tamo:addEffect(fk.GameStart, {
  priority = 2,
  anim_type = "big",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(QC_tamo.name)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = QC_tamo.name,
      prompt = "#QC_tamo-invoke"
    }) then
      local availablePlayerIds = table.map(table.filter(room.players, function(p)
        return p.rest > 0 or not p.dead
      end), Util.IdMapper)
      local result = room:askToCustomDialog(player, {
        skill_name = QC_tamo.name,
        qml_path = "packages/mobile/qml/TaMoBox.qml",
        extra_data = {
          availablePlayerIds,
          "$QC_tamo",
        },
      })
      if result ~= "" then
        event:setCostData(self, { extra_data = result })
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local players = table.simpleClone(room.players)
    for seat, playerId in pairs(event:getCostData(self).extra_data) do
      players[seat] = room:getPlayerById(playerId)
    end
    room.players = players
    local player_circle = {}
    for i = 1, #room.players do
      room.players[i].seat = i
      table.insert(player_circle, room.players[i].id)
    end
    for i = 1, #room.players - 1 do
      room.players[i].next = room.players[i + 1]
    end
    room.players[#room.players].next = room.players[1]
    room:setCurrent(room.players[1])
    room:doBroadcastNotify("ArrangeSeats", player_circle)
  end,
})

QC_tamo:addEffect(fk.RoundStart, {
  priority = 2,
  anim_type = "big",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(QC_tamo.name)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = QC_tamo.name,
      prompt = "#QC_tamo-invoke"
    }) then
      local availablePlayerIds = table.map(table.filter(room.players, function(p)
        return p.rest > 0 or not p.dead
      end), Util.IdMapper)
      local result = room:askToCustomDialog(player, {
        skill_name = QC_tamo.name,
        qml_path = "packages/mobile/qml/TaMoBox.qml",
        extra_data = {
          availablePlayerIds,
          "$QC_tamo",
        },
      })
      if result ~= "" then
        event:setCostData(self, { extra_data = result })
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local players = table.simpleClone(room.players)
    for seat, playerId in pairs(event:getCostData(self).extra_data) do
      players[seat] = room:getPlayerById(playerId)
    end
    room.players = players
    local player_circle = {}
    for i = 1, #room.players do
      room.players[i].seat = i
      table.insert(player_circle, room.players[i].id)
    end
    for i = 1, #room.players - 1 do
      room.players[i].next = room.players[i + 1]
    end
    room.players[#room.players].next = room.players[1]
    room:setCurrent(room.players[1])
    room:doBroadcastNotify("ArrangeSeats", player_circle)
  end,
})

return QC_tamo
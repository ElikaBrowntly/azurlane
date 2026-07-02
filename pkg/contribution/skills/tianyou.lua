local tianyou = fk.CreateSkill {
  name = "yyfy_tianyou",
}

Fk:loadTranslationTable{
  ["yyfy_tianyou"] = "天幽",
  [":yyfy_tianyou"] = "持恒技，游戏开始时和每轮开始时，你可以重新分配所有角色的座次。",

  ["#yyfy_tianyou-invoke"] = "天幽：你可以重新分配场上角色的座次",
  ["$yyfy_tianyou"] = "天幽",
  ["click to exchange"] = "点击交换",
  ["$yyfy_tianyou1"] = "天幽",
  ["$yyfy_tianyou2"] = "天幽"
}
local ok, M = pcall(require, "packages.mobile")

local spec = {
  priority = 2,
  anim_type = "big",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(tianyou.name) and ok
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player,{
      skill_name = tianyou.name,
      prompt = "#yyfy_tianyou-invoke"
    }) then
      local availablePlayerIds = table.map(table.filter(room.players, function(p)
        return p.rest > 0 or not p.dead
      end), Util.IdMapper)
      local result = room:askToCustomDialog(player, {
        skill_name = tianyou.name,
        qml_path = "packages/mobile/qml/TaMoBox.qml",
        extra_data = {
          availablePlayerIds,
          {},
          "$yyfy_tianyou",
        },
      })
      if result ~= "" then
        event:setCostData(self, {extra_data = result})
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
  end
}

tianyou:addEffect(fk.GameStart, spec)

tianyou:addEffect(fk.RoundStart, spec)

return tianyou
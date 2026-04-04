local chain = fk.CreateSkill {
  name = "yyfy_xs_chain_skill",
}



Fk:loadTranslationTable {
  ["@yyfy_xs_chain"] = "绑定",
  ["@[:]yyfy_xs_avenge"] = "<font color='red'>复仇任务</font>"
}

--- 更新左上角复仇任务的函数
--- @param room Room 房间
local function updateBanner(room)
  local banner = room:getBanner("yyfy_xs_avenge")
  if not banner then
    room:setBanner("@[:]yyfy_xs_avenge", nil)
    return
  end
  local players = room:getAlivePlayers()
  local desc = ""
  for _, p in ipairs(players) do
    local avenge = banner[tostring(p.id)]
    if avenge and avenge ~= {} then
      local current = avenge.current
      local next = avenge.next
      local name = Fk:translate(p.general) --复仇者的名字
      if current and #current ~= 0 then
        desc = desc.."<br>"..name.." 需要在本轮结束前杀死"
        for _, id in ipairs(current) do
          local e = room:getPlayerById(id)
          local enemy = Fk:translate(e.general) --目标的名字
          desc = desc.." "..enemy.."，"
        end
        desc = desc.."<br>"
      end
      if next and #next ~= 0 then
        desc = desc.."<br>"..name.." 需要在下轮结束前杀死"
        for _, id in ipairs(next) do
          local e = room:getPlayerById(id)
          local enemy = Fk:translate(e.general) --目标的名字
          desc = desc.." "..enemy.."，"
        end
        desc = desc.."<br>"
      end
      desc = desc.."<br>" --不同的复仇者之间空一行
    end
  end
  room:setBanner("@[:]yyfy_xs_avenge", desc)
end

chain:addEffect("cardskill", {
  can_use = function(self, player, card, extra_data)
    return player and not player.dead and #Fk:currentRoom().alive_players > 1
  end,
  target_num = 1,
  target_filter = function(self, player, to_select, selected, selected_cards, card, extra_data)
    return #selected == 0 and to_select ~= player and to_select:isAlive()
  end,
  prompt = "选择一名角色，与其进入绑定状态！",
  on_effect = function(self, room, effect)
    local to = effect.to
    room:addTableMarkIfNeed(effect.from, "@yyfy_xs_chain", to.general)
    room:addTableMarkIfNeed(effect.from, "yyfy_xs_chain", to.id)
  end
})

chain:addEffect(fk.Death, {
  global = true,
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getTableMark("@yyfy_xs_chain") ~= {} and data.killer
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local tos = player:getTableMark("yyfy_xs_chain")
    --键值表，键为复仇者id字符串，值为本轮任务current和下轮任务next两个表，next是复仇任务目标id列表
    local banner = room:getBanner("yyfy_xs_avenge") or {}
    for _, id in ipairs(tos) do
      local avenge = banner[tostring(id)] or {}
      local next = avenge.next or {}
      table.insertIfNeed(next, data.killer.id)
      avenge.next = next
      banner[tostring(id)] = avenge
    end
    room:setBanner("yyfy_xs_avenge", banner)
    updateBanner(room)
  end,
})

chain:addEffect(fk.RoundEnd, {
  global = true,
  can_refresh = function(self, event, target, player, data)
    return player.room:getBanner("yyfy_xs_avenge") and player and player:isAlive()
    and (event:getCostData(self) or {}).invoked == nil
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local banner = room:getBanner("yyfy_xs_avenge")
    if banner == {} then return false end
    local players = room:getAlivePlayers()
    for _, p in ipairs(players) do
      local avenge = banner[tostring(p.id)]
      if avenge and avenge ~= {} then
        local current = avenge.current
        local next = avenge.next
        if current and #current ~= 0 then
          avenge = nil
          room:killPlayer({
            who = p
          })
        elseif next and #next ~= 0 then
          avenge.current = next
          avenge.next = nil
        else
          avenge = nil
        end
      end
    end
    room:setBanner("yyfy_xs_avenge", banner)
    updateBanner(room)
    local costData = event:getCostData(self) or {}
    costData.invoked = true
    event:setCostData(self, costData)
  end
})

chain:addEffect(fk.Death, {
  global = true,
  can_refresh = function(self, event, target, player, data)
    return player.room:getBanner("yyfy_xs_avenge") and data.killer
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local banner = room:getBanner("yyfy_xs_avenge")
    if banner == {} then return false end
    local avenge = banner[tostring(data.killer.id)]
    local id = data.who.id
    if avenge and avenge ~= {} then
      local current = avenge.current
      local next = avenge.next
      if current and #current ~= 0 and table.contains(current, id) then
        table.removeOne(current, id)
        if #current == 0 then current = nil end
      end
      if next and #next ~= 0 and table.contains(next, id) then
        table.removeOne(next, id)
        if #next == 0 then next = nil end
      end
      if current == nil and next == nil then avenge = nil end
    end
    room:setBanner("yyfy_xs_avenge", banner)
    updateBanner(room)
  end,
})

return chain

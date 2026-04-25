local linghun = fk.CreateSkill {
  name = "yyfy_linghun",
  anim_type = "defensive",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable {
  ["yyfy_linghun"] = "灵魂",
  [":yyfy_linghun"] = "持恒技，你不能被操控、替换武将牌。当此化身登场时，其他角色随机变更主将并移除副将。",
}

local all_generals = { "yyfy_longchen" }
local j = 1
while j <= 10 do
  table.insert(all_generals, "yyfy_longchen" .. tostring(j))
  j = j + 1
end

linghun:addEffect(fk.AfterSkillEffect, {
  can_refresh = function(self, event, target, player, data)
    return player and player:hasSkill(self.name) and not player:isControlling(player)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:doBroadcastNotify("ShowToast", "<font color='red'>起源天龙</font>不会被操控……")
    player:control(player)
  end
})

linghun:addEffect(fk.BeforePropertyChange, {
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
    if target == player and player:hasSkill(self, true, true) then
      return data.from == player and ((data.general and not table.contains(all_generals, data.general)
        and table.contains(all_generals, player.general)) or (data.deputyGeneral and not
        table.contains(all_generals, data.deputyGeneral) and table.contains(all_generals, player.deputyGeneral)))
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    player.room:doBroadcastNotify("ShowToast", "<font color='red'>起源天龙</font>防止了替换武将牌")
    if not table.contains(all_generals, data.general) and table.contains(all_generals, player.general) then
      data.general = player.general
    end
    if not table.contains(all_generals, data.deputyGeneral) and table.contains(all_generals, player.deputyGeneral) then
      data.deputyGeneral = player.deputyGeneral
    end
  end,
})

-- 没有用获得此技能时，因为带有一些共鸣技的性质
linghun:addEffect(fk.AfterPropertyChange, {
  anim_type = "control",
  priority = 2,
  can_trigger = function(self, event, target, player, data)
    return player and target == player and player:hasSkill(self, true, true)
        and (table.contains(all_generals, data.general) or
          data.deputyGeneral and table.contains(all_generals, data.deputyGeneral))
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local generals = room.general_pile
    local num = #room:getOtherPlayers(player)
    for _, p in ipairs(room:getOtherPlayers(player)) do
      table.removeOne(generals, p.general)
      if p.deputyGeneral and p.deputyGeneral ~= "" then
        table.removeOne(generals, p.deputyGeneral)
      end
    end
    local max = #generals
    local index = {}
    while #index < num do
      local n = math.random(1, max)
      -- 检查是否已存在
      local duplicated = false
      for _, v in ipairs(index) do
        if v == n then
          duplicated = true
          break
        end
      end
      if not duplicated then
        table.insert(index, n)
      end
    end
    for i, p in ipairs(room:getOtherPlayers(player)) do
      if p.deputyGeneral and p.deputyGeneral ~= "" then
        room:removeDeputy(p, {})
      end
      room:changeHero(p, generals[index[i]], false, false)
    end
  end
})

return linghun
local skill = fk.CreateSkill {
  name = "yyfy_youdiezhimeng",
}

Fk:loadTranslationTable {
  ["yyfy_youdiezhimeng"] = "幽蝶之梦",
  [":yyfy_youdiezhimeng"] = "每轮开始时，以及第3、4、5个友方角色回合开始时，你可以视为使用一张【杀】。",
  ["#yyfy_youdiezhimeng"] = "幽蝶之梦：你可以视为使用一张【杀】",
  ["$yyfy_youdiezhimeng"] = "已经看到了，汝等破灭的命运——"
}

local F = require "packages.hidden-clouds.functions"

skill:addEffect(fk.RoundStart, {
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(self)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      targets = room:getOtherPlayers(player),
      min_num = 1,
      max_num = 1,
      skill_name = skill.name,
      prompt = "#yyfy_youdiezhimeng"
    })
    if not tos or #tos ~= 1 then return false end
    event:setCostData(self, { tos = tos, no_indicate = true })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = (event:getCostData(self) or {}).tos
    if not to then return end
    room:useVirtualCard("slash", nil, player, to, skill.name, true)
  end
})

skill:addEffect(fk.TurnStart, {
  can_trigger = function(self, event, target, player, data)
    if not (player and player:hasSkill(self) and target and not F.isEnemy(player, target)) then return end
    local banner = player.room:getBanner(skill.name) or {}
    return (banner[tostring(player.id)] or 0) < 5
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local banner = room:getBanner(skill.name) or {}
    local count = banner[tostring(player.id)] or 0
    banner[tostring(player.id)] = count + 1
    room:setBanner(skill.name, banner)
    if not table.contains({ 3, 4, 5 }, banner[tostring(player.id)]) then return false end
    local tos = room:askToChoosePlayers(player, {
      targets = room:getOtherPlayers(player),
      min_num = 1,
      max_num = 1,
      skill_name = skill.name,
      prompt = "#yyfy_youdiezhimeng"
    })
    if not tos or #tos ~= 1 then return false end
    event:setCostData(self, { tos = tos, no_indicate = true })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = (event:getCostData(self) or {}).tos
    if not to then return end
    room:useVirtualCard("slash", nil, player, to, skill.name, true)
  end
})

return skill
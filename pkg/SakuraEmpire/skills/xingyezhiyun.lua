local skill = fk.CreateSkill {
  name = "yyfy_xingyezhiyun",
}

Fk:loadTranslationTable {
  ["yyfy_xingyezhiyun"] = "星夜之云",
  [":yyfy_xingyezhiyun"] = "游戏开始时，或当你使用【杀】时，你可以令一名敌方角色获得1个「彩云」标记，" ..
      "拥有此标记的角色受到的伤害+1，最多+3。你使用的【杀】额外结算一次。",
  ["@yyfy_xingyezhiyun"] = "彩云",
  ["$yyfy_xingyezhiyun1"] = "胜负，皆为命定。至少…让我等竭尽全力",
  ["$yyfy_xingyezhiyun2"] = "已经看到了，汝等破灭的命运——",
  ["$yyfy_xingyezhiyun3"] = "但愿这一切不会成为无用功…"
}

local F = require "packages.hidden-clouds.functions"

local on_use = function(self, event, target, player, data)
  local room = player.room
  local tos = (event:getCostData(self) or {}).tos
  if not tos or #tos == 0 then return end
  local to = room:askToChoosePlayers(player, {
    targets = tos,
    min_num = 1,
    max_num = 1,
    skill_name = skill.name,
    prompt = "星夜之云：请令一名角色获得「彩云」标记"
  })
  if not to or #to ~= 1 then return end
  room:addPlayerMark(to[1], "@"..skill.name)
end

skill:addEffect(fk.GameStart, {
  audio_index = 1,
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if not (player and player:hasSkill(self)) then return end
    local tos = table.filter(player.room.alive_players, function(p)
      return p:isAlive() and F.isEnemy(player, p)
    end)
    if tos and #tos > 0 then
      event:setCostData(self, { tos = tos, no_indicate = true })
      return true
    end
  end,
  on_use = on_use
})

skill:addEffect(fk.CardUsing, {
  mute = true,
  can_trigger = function (self, event, target, player, data)
    if not (target == player and player:hasSkill(self) and data.card.trueName == "slash") then return end
    local tos = table.filter(player.room.alive_players, function(p)
      return p:isAlive() and F.isEnemy(player, p)
    end)
    if tos and #tos > 0 then
      event:setCostData(self, { tos = tos, no_indicate = true })
      return true
    end
  end,
  on_use = on_use
})

skill:addEffect(fk.DamageInflicted, {
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self) and target and target:getMark("@yyfy_xingyezhiyun") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    data:changeDamage(math.min(target:getMark("@yyfy_xingyezhiyun"), 3))
  end
})

skill:addEffect(fk.CardUsing, {
  anim_type = "control",
  is_delay_effect = true,
  priority = 1.1,
  audio_index = math.random(2, 3),
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and #data.tos > 0 and data.card.trueName == "slash"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.additionalEffect = (data.additionalEffect or 0) + 1
  end,
})

return skill
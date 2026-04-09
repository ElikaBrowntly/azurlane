local aozhan = fk.CreateSkill{
  name = "yyfy_aozhan",
}

Fk:loadTranslationTable{
  ["yyfy_aozhan"] = "傲斩",
  [":yyfy_aozhan"] = "出牌阶段或你受伤时，你可以将所有手牌当一张无距离次数限制且需响应数+1的【杀】使用。",

  ["#yyfy_aozhan"] = "傲斩：你可以将所有手牌当【杀】使用"
}

--- 出杀
--- @param player ServerPlayer 出杀者
---@param target ServerPlayer 目标
local function slash(player, target)
  local subcards = player:getCardIds("h")
  if #subcards == 0 then return end
  player.room:useVirtualCard("slash", subcards, player, {target}, aozhan.name, true, {
    bypass_distances = true,
    bypass_times = true,
    extraUse = true
  })
end

aozhan:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash"
    and data.card.skillName == aozhan.name
  end,
  on_use = function (self, event, target, player, data)
    data:setResponseTimes(2, data.to)
  end
})

-- 出牌阶段主动发动
aozhan:addEffect("active", {
  anim_type = "offensive",
  prompt = "#yyfy_aozhan",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player and #player:getCardIds("h") > 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player and to_select:isAlive()
  end,
  on_use = function(self, room, effect)
    slash(effect.from, effect.tos[1])
  end,
})

-- 受伤时触发
aozhan:addEffect(fk.DamageInflicted, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and #player:getCardIds("h") > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      targets = room:getOtherPlayers(player),
      min_num = 1,
      max_num = 1,
      skill_name = aozhan.name,
      prompt = "#yyfy_aozhan"
    })
    if #tos == 1 then
      local cost = event:getCostData(self) or {}
      cost.tos = tos
      event:setCostData(self, cost)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local to = event:getCostData(self).tos[1]
    slash(player, to)
  end,
})

return aozhan
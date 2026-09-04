local zuiying = fk.CreateSkill {
  name = "yyfy_zuiying",
  tags = { Skill.Compulsory }
}

Fk:loadTranslationTable {
  ["yyfy_zuiying"] = "嘴硬",
  [":yyfy_zuiying"] = "锁定技，你使用牌结算结束后，目标回复此牌结算过程中受到伤害值的体力。"
}

zuiying:addEffect(fk.CardUseFinished, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self) and data.card) then return false end
    local use = player.room.logic:getEventsByRule(GameEvent.UseCard, 1, function (e)
      return e.data.from == player and e.data.card.id == data.card.id
    end, nil, Player.HistoryPhase)
    if #(use or {}) ~= 1 then return false end
    local events = player.room.logic:getActualDamageEvents(99, function(e)
      local to = e.data.to
      return to and to:isAlive() and table.contains(data.tos, to) and e.data.damage > 0
    end, nil, use[1].id)
    if #(events or {}) == 0 then return false end
    local cost = event:getCostData(self) or {}
    cost.events = events
    event:setCostData(self, cost)
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local events = (event:getCostData(self) or {}).events or {} ---@type GameEvent.Damage[]
    if #events == 0 then return end
    local t = {}
    for _, e in ipairs(events) do
      local i = tostring(e.data.to.id)
      t[i] = (t[i] or 0) + e.data.damage
    end
    for id, num in pairs(t) do
      local p = room:getPlayerById(tonumber(id) or 0)
      if p and p:isAlive() then
        room:recover({
          who = p,
          num = num,
          recoverBy = player,
          skillName = zuiying.name
        })
      end
    end
  end
})

return zuiying
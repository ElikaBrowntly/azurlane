local sanshi = fk.CreateSkill {
  name = "lan__sanshi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["lan__sanshi"] = "散士",
  [":lan__sanshi"] = "锁定技，游戏开始时或你登场后，你将牌堆或弃牌堆中每个点数的随机一张牌标记为“死士”牌。每回合结束时，" ..
      "若本回合有“死士”牌不因你使用或打出而进入弃牌堆，你获得这些牌。你使用“死士”牌不能被响应。",

  ["#lan__sanshi-choice"] = "散士：是否要将每个点数的随机一张牌标记为“死士”牌",
  ["@@lan__sanshi-inhand"] = "死士",

  ["$lan__sanshi1"] = "春雨润物，未觉其暖，已见其青。",
  ["$lan__sanshi2"] = "养士效孟尝，用时可得千臂之助力。",
}

local U = require "packages.utility.utility"

sanshi:addEffect(fk.CardUsing, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(sanshi.name) and
        (data.card.trueName == "slash" or data.card:isCommonTrick()) and
        not data.card:isVirtual() and data.card:getMark("@@lan__sanshi-inhand") > 0
  end,
  on_use = function(self, event, target, player, data)
    data.disresponsiveList = table.simpleClone(player.room.players)
  end,
})

sanshi:addEffect(fk.TurnEnd, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(sanshi.name) and player:getMark(sanshi.name) ~= 0 then
      local room = player.room
      local cards = table.filter(player:getTableMark(sanshi.name), function(id)
        return table.contains(room.discard_pile, id)
      end)
      if #cards == 0 then return end
      local ids = {}
      room.logic:getEventsByRule(GameEvent.MoveCards, 1, function(e)
        for _, move in ipairs(e.data) do
          for _, info in ipairs(move.moveInfo) do
            local id = info.cardId
            if table.removeOne(cards, id) then
              if move.toArea == Card.DiscardPile then
                if move.moveReason == fk.ReasonUse then
                  --线上延迟锦囊在判定阶段结算后置入弃牌堆，司马师会发动散士，但是无法获得此延时锦囊，像bug
                  local use_event = e.parent
                  if use_event and use_event.event == GameEvent.UseCard and use_event.data.from ~= player then
                    table.insert(ids, id)
                  end
                elseif move.moveReason == fk.ReasonResponse then
                  local use_event = e.parent
                  if use_event and use_event.event == GameEvent.RespondCard and use_event.data.from ~= player then
                    table.insert(ids, id)
                  end
                else
                  table.insert(ids, id)
                end
              end
            end
          end
        end
      end, nil, Player.HistoryTurn)
      if #ids > 0 then
        event:setCostData(self, { cards = ids })
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:moveCardTo(event:getCostData(self).cards, Card.PlayerHand, player, fk.ReasonJustMove, sanshi.name, nil, true, player)
  end,
})

local spec = function(self, event, target, player, data)
  local room = player.room
  local cardmap = {}
  for _ = 1, 13 do
    table.insert(cardmap, {})
  end
  for _, id in ipairs(room.draw_pile) do
    local n = Fk:getCardById(id).number
    if n > 0 and n < 14 and not table.contains(player:getTableMark(sanshi.name) or {}, id) then
      table.insert(cardmap[n], id)
    end
  end
  for _, id in ipairs(room.discard_pile) do
    local n = Fk:getCardById(id).number
    if n > 0 and n < 14 and not table.contains(player:getTableMark(sanshi.name) or {}, id) then
      table.insert(cardmap[n], id)
    end
  end
  local cards = {}
  for _, ids in ipairs(cardmap) do
    if #ids > 0 then
      table.insert(cards, room:tableRandomPick(ids))
    end
  end
  local before = player:getTableMark(sanshi.name) or {}
  if #before > 0 then
    table.insertTable(cards, before)
  end
  room:setPlayerMark(player, sanshi.name, cards)
end

sanshi:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(sanshi.name)
  end,
  on_use = spec
})

sanshi:addEffect(U.GeneralAppeared, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasShownSkill(sanshi.name)
  end,
  on_use = spec
})

sanshi:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    return player:getMark(sanshi.name) ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, id in ipairs(player:getCardIds("h")) do
      local card = Fk:getCardById(id)
      if table.contains(player:getTableMark(sanshi.name), id) then
        room:setCardMark(card, "@@lan__sanshi-inhand", 1)
      end
    end
  end,
})

sanshi:addLoseEffect(function(self, player, is_death)
  local room = player.room
  room:setPlayerMark(player, sanshi.name, 0)
  for _, id in ipairs(player:getCardIds("h")) do
    local card = Fk:getCardById(id)
    if card:getMark("@@lan__sanshi-inhand") > 0 then
      room:setCardMark(card, "@@lan__sanshi-inhand", 0)
    end
  end
end)

return sanshi

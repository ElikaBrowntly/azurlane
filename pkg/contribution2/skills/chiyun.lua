local chiyun = fk.CreateSkill {
  name = "yyfy_chiyun",
}

Fk:loadTranslationTable {
  ["yyfy_chiyun"] = "炽沄",
  [":yyfy_chiyun"] = "当你每阶段首次获得牌后，可以交给一名其他角色至少一张手牌，你摸2张牌并横置其，" ..
      "然后其展示所有与这些牌颜色相同的手牌，你对其造成1点火焰伤害。",

  ["#yyfy_chiyun-invoke"] = "炽沄：你可交给一名其他角色至少一张手牌",
  ["$yyfy_chiyun1"] = "孙郎既有凌霄壮志，瑜当愧以展志青天。",
  ["$yyfy_chiyun2"] = "但凭瑜之能气，成江东毕才之愿。",
}

chiyun:addEffect(fk.AfterCardsMove, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not (player:hasSkill(chiyun.name) and player:getHandcardNum() > 0) then return false end

    local room = player.room
    local eventId = player:getMark("yyfy_chiyun-phase")
    if eventId == 0 then
      room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
        if
            table.find(e.data, function(move)
              return move.to == player and move.toArea == Card.PlayerHand
            end)
        then
          eventId = e.id
          room:setPlayerMark(player, "yyfy_chiyun-phase", eventId)
          return true
        end
      end, Player.HistoryPhase)
    end

    return eventId == room.logic:getCurrentEvent().id
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos, cards = room:askToChooseCardsAndPlayers(player, {
      min_num = 1,
      max_num = 1,
      min_card_num = 1,
      max_card_num = player:getHandcardNum(),
      targets = room:getOtherPlayers(player, false),
      pattern = ".|.|.|hand",
      skill_name = chiyun.name,
      prompt = "#yyfy_chiyun-invoke",
    }
    )

    if #tos == 1 and #cards > 0 then
      event:setCostData(self, { tos = tos, cards = cards })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    ---@type string
    local skillName = chiyun.name
    local room = player.room
    local to = event:getCostData(self).tos[1]
    ---@type integer[]
    local cards = event:getCostData(self).cards
    room:obtainCard(to, cards, false, fk.ReasonGive, player, skillName)
    if player:isAlive() then
      player:drawCards(2, skillName)
    end
    if to:isAlive() and not to.chained then
      to:setChainState(true)
    end
    local colors = {}
    table.forEach(cards, function(id)
      local color = Fk:getCardById(id).color
      if color ~= Card.NoColor then
        table.insertIfNeed(colors, color)
      end
    end)
    local toShow = table.filter(to:getCardIds("h"), function(id)
      local color = Fk:getCardById(id).color
      return table.contains(colors, color)
    end)
    if #toShow > 0 then
      to:showCards(toShow)
    end
    room:delay(1500)
    if to:isAlive() then
      if player:isAlive() then
        room:doIndicate(player, { to })
      end
      room:damage {
        from = player,
        to = to,
        damage = 1,
        damageType = fk.FireDamage,
        skillName = skillName,
      }
    end
  end,
})

return chiyun
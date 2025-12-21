local shelie = fk.CreateSkill {
  name = "yyfy_shelie",
}

Fk:loadTranslationTable{
  ["yyfy_shelie"] = "涉猎",
  [":yyfy_shelie"] = "摸牌阶段，你可以改为亮出牌堆顶的五张牌，然后获得其中每种花色的牌各一张。" ..
  "结束阶段后，若你本回合使用牌花色数不小于你的体力值，你选择执行一个额外摸牌或出牌阶段。（每轮限一次）",

  ["#yyfy_shelie_extra"] = "涉猎",
  ["@yyfy_shelie-turn"] = "涉猎",
  ["#yyfy_shelie_log"] = "%from 发动“%arg”，执行一个额外的 %arg2",

  ["$yyfy_shelie1"] = "从主之劝，博览群书。",
  ["$yyfy_shelie2"] = "为将者，自当识天晓地。",
}

shelie:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player:hasSkill(shelie.name) and
      player.phase == Player.Draw and
      not data.phase_end
  end,
  on_use = function(self, event, target, player, data)
    ---@type string
    local skillName = shelie.name
    local room = player.room
    data.phase_end = true

    local cards = room:getNCards(5)
    room:turnOverCardsFromDrawPile(player, cards, skillName)

    local get = {}
    for _, id in ipairs(cards) do
      local suit = Fk:getCardById(id).suit
      if table.every(get, function (id2)
        return Fk:getCardById(id2).suit ~= suit
      end) then
        table.insert(get, id)
      end
    end
    get = room:askToArrangeCards(
      player,
      {
        skill_name = skillName,
        card_map = cards,
        prompt = "#shelie-choose",
        box_size = 0,
        max_limit = { 5, 4 },
        min_limit = { 0, #get },
        poxi_type = "shelie",
        default_choice = { {}, get },
      }
    )[2]
    if #get > 0 then
      room:moveCardTo(get, Player.Hand, player, fk.ReasonPrey, skillName, nil, true, player)
    end

    room:cleanProcessingArea(cards)
  end,
})

shelie:addEffect(fk.EventPhaseEnd, {
  can_trigger = function(self, event, target, player, data)
    return
      target == player and player:hasSkill(shelie.name) and
      player.phase == Player.Finish and
      #player:getTableMark("@yyfy_shelie-turn") >= player.hp and
      player:usedEffectTimes(self.name, Player.HistoryRound) < 1
  end,
  on_cost = function(self, event, target, player)
    local choices = { "phase_draw", "phase_play" }
    event:setCostData(self, player.room:askToChoice(
      player,
      {
        choices = choices,
        skill_name = shelie.name,
        prompt = "涉猎：请选择执行一个额外的阶段"
      }
    ))
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self)
    room:sendLog{
      type = "#yyfy_shelie_log",
      from = player.id,
      arg = shelie.name,
      arg2 = choice,
    }
    room:setPlayerMark(player, "_yyfy_shelie", choice)
    player:gainAnExtraPhase(choice == "phase_draw" and Player.Draw or Player.Play)
  end,
})

shelie:addEffect(fk.AfterCardUseDeclared, {
  can_refresh = function(self, event, target, player, data)
    return
      target == player and
      player:hasSkill(shelie.name, true) and
      player.phase ~= Player.NotActive and
      data.card.suit ~= Card.NoSuit
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addTableMarkIfNeed(player, "@yyfy_shelie-turn", data.card:getSuitString(true))
  end,
})

shelie:addAcquireEffect(function(self, player, isStart)
  if not isStart and player.phase ~= Player.NotActive then
    local room = player.room
    local turn_event = room.logic:getCurrentEvent():findParent(GameEvent.Turn)
    if turn_event then
      local suitsRecorded = player:getTableMark("@yyfy_shelie-turn")

      room.logic:getEventsByRule(GameEvent.UseCard, 1, function (e)
        local use = e.data
        if use.from == player then
          table.insertIfNeed(suitsRecorded, use.card:getSuitString(true))
        end
        return false
      end, turn_event.id)
      room:setPlayerMark(player, "@yyfy_shelie-turn", suitsRecorded)
    end
  end
end)

return shelie

local qieyi = fk.CreateSkill {
  name = "yyfy_qieyi",
}

Fk:loadTranslationTable {
  ["yyfy_qieyi"] = "切议",
  [":yyfy_qieyi"] = "出牌阶段开始时，你观看牌堆顶4张牌。本回合你每使用一张有花色的牌后，亮出牌堆顶的一张牌，若这两张牌：" ..
      "花色相同，你获得亮出牌；否则，你将一张牌置于牌堆顶，置入4张后本回合此技能失效。然后，你观看牌堆顶4张牌。",

  ["@yyfy_qieyi-turn"] = "切议",
  ["#yyfy_qieyi-ask"] = "切议：请将一张牌置于牌堆顶",

  ["$yyfy_qieyi"] = "张角将成祸患…"
}

qieyi:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qieyi.name) and player.phase == Player.Play
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:getNCards(4)
    local log = {
      type = "#WatchCard",
      from = player.id,
      card = cards,
    }
    player:doNotify("GameLog", log)
    room:viewCards(player, { cards = cards, skill_name = qieyi.name })
  end,
})

qieyi:addEffect(fk.CardUseFinished, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(qieyi.name)
        and player:usedSkillTimes(qieyi.name, Player.HistoryTurn) > 0 then
      return data.card.suit ~= Card.NoSuit
    end
    return false
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:getNCards(1)
    room:turnOverCardsFromDrawPile(player, cards, qieyi.name)
    if Fk:getCardById(cards[1]).suit == data.card.suit then
      room:setCardEmotion(cards[1], "judgegood")
      room:delay(1000)
      room:obtainCard(player, cards[1], true, fk.ReasonJustMove, player, qieyi.name)
      room:addPlayerMark(player, "yyfy_qieyi-turn")
    else
      room:setCardEmotion(cards[1], "judgebad")
      room:cleanProcessingArea(cards, qieyi.name)
      if not player:isNude() then
        local card = room:askToCards(player, {
          min_num = 1,
          max_num = 1,
          include_equip = true,
          skill_name = qieyi.name,
          prompt = "#yyfy_qieyi-ask",
          cancelable = false,
        })
        room:moveCards({
          ids = card,
          from = player,
          toArea = Card.DrawPile,
          moveReason = fk.ReasonPut,
          skillName = qieyi.name,
        })
        room:addPlayerMark(player, "@yyfy_qieyi-turn")
        if player:getMark("@yyfy_qieyi-turn") > 3 then
          room:invalidateSkill(player, qieyi.name, "-turn")
        end
      end
    end
    room:viewCards(player, {
      cards = room:getNCards(4),
      skill_name = qieyi.name
    })
  end,
})

return qieyi
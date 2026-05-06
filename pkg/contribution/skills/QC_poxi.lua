local QC_poxi = fk.CreateSkill{
  name = "QC_poxi",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["QC_poxi"] = "魄袭",
  [":QC_poxi"] = "持恒技，其他角色的牌对你可见。出牌阶段限一次，你可以观看一名其他角色的牌，然后你可以弃置你与其共计四张不同花色的牌。若如此做，根据此次弃置你的牌数量执行以下效果：不小于0，加1点体力上限并回复1点体力值；不小于1，摸弃置牌数的牌；不小于2，本回合使用牌无次数距离限制；不小于3，本回合使用牌不可被响应；不小于4，你获得对方所有牌。",
  ["QC_poxi_discard"] = "魄袭",
  ["#QC_poxi"] = "魄袭：选择一名有其他角色，弃置双方手牌中共计四张花色各不相同的牌",
  ["#QC_poxi-ask"] = "魄袭：弃置双方手里四张不同花色的牌",
}

QC_poxi:addEffect("visibility", {
  card_visible = function(self, player, card)
    if player:hasSkill(QC_poxi.name) and Fk:currentRoom():getCardArea(card) == Card.PlayerHand then
      return true
    end
  end,
})

Fk:addPoxiMethod{
  name = "QC_poxi_discard",
  prompt = "#QC_poxi-ask",
  card_filter = function(to_select, selected, data, extra_data)
    local suit = Fk:getCardById(to_select).suit
    if suit == Card.NoSuit then return false end
    if table.find(selected, function(id) return Fk:getCardById(id).suit == suit end) then
      return false
    end
    return true
  end,
  feasible = function(selected, data, extra_data)
    return #selected == 4
  end,
}

QC_poxi:addEffect("active", {
  anim_type = "control",
  prompt = "#QC_poxi",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(QC_poxi.name, Player.HistoryPhase) < 1
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player and not to_select:isNude()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local player_hands = player:getCardIds("he")
    local target_hands = target:getCardIds("he")
    local cards = room:askToPoxi(player, {
      poxi_type = "QC_poxi_discard",
      data = {
        { player.general, player_hands },
        { target.general, target_hands },
      },
      cancelable = true,
    })
    if #cards == 0 then return end

    local cards1 = table.filter(cards, function(id) return table.contains(player_hands, id) end)
    local cards2 = table.filter(cards, function(id) return table.contains(target_hands, id) end)

    local moveInfos = {}
    if #cards1 > 0 then
      table.insert(moveInfos, {
        from = player.id,
        ids = cards1,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonDiscard,
        proposer = player,
        skillName = QC_poxi.name,
      })
    end
    if #cards2 > 0 then
      table.insert(moveInfos, {
        from = target.id,
        ids = cards2,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonDiscard,
        proposer = player,
        skillName = QC_poxi.name,
      })
    end
    room:moveCards(table.unpack(moveInfos))

    if player.dead then return end

    if #cards1 >= 0 then
      room:changeMaxHp(player, 1)
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = QC_poxi.name,
      }
    end
    if #cards1 >= 1 then
      player:drawCards(#cards, QC_poxi.name)
    end
    if #cards1 >= 2 then
      room:addPlayerMark(player, MarkEnum.BypassDistancesLimit .. "-turn")
      room:addPlayerMark(player, MarkEnum.BypassTimesLimit .. "-turn")
    end
    if #cards1 >= 3 then
      room:setPlayerMark(player, "QC_poxi3-turn", 1)
    end
    if #cards1 >= 4 then

      local all_target_cards = target:getCardIds("hej")  -- 手牌+装备+判定
      if #all_target_cards > 0 then
        room:moveCardTo(all_target_cards, Card.PlayerHand, player, fk.ReasonGive, QC_poxi.name, nil, true)
      end
    end
  end,
})

QC_poxi:addEffect(fk.PreCardUse, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("QC_poxi3-turn") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.disresponsiveList = table.simpleClone(player.room.players)
  end,
})

return QC_poxi
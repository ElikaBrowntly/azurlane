local zhejiao = fk.CreateSkill {
  name = "yyfy_zhejiao",
}

Fk:loadTranslationTable{
  ["yyfy_zhejiao"] = "折骄",
  [":yyfy_zhejiao"] = "出牌阶段限2次，你可以令一名其他角色展示任意张牌，其中每有一张红/黑色牌，"..
  "其下个回合摸牌阶段摸牌数+1/-1；然后直到下一轮结束，其手牌中每有一张展示过的红色牌或未展示过的黑色牌，"..
  "你的【杀】对其造成的伤害便+1。",
  ["@@yyfy_zhejiao-turn"] = "折骄",
  ["@@yyfy_zhejiao-next"] = "折骄",
}

local U = require "packages/utility/utility"

zhejiao:addEffect("active", {
  card_num = 0,
  anim_type = "control",
  prompt = "折骄：请选择一名其他角色，令其展示任意张牌",
  can_use = function(self, player)
    return player:usedSkillTimes(zhejiao.name, Player.HistoryPhase) < 2 and
    table.find(Fk:currentRoom().alive_players, function (p)
      return p ~= player and #p:getCardIds("h") > 0 -- 找一个有牌的其他角色
    end)
  end,
  target_num = 1,
  target_filter = function (self, player, to_select, selected, selected_cards, card, extra_data)
    return #selected == 0 and to_select ~= player and #to_select:getCardIds("h") > 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local cards = room:askToCards(target, {
      min_num = 0,
      max_num = #target:getCardIds("h"),
      include_equip = false,
      skill_name = zhejiao.name,
      prompt = "折骄：你需要展示任意张手牌"
    })
    target:showCards(cards)
    local red = 0
    local black = 0
    for _, c in ipairs(cards) do
      local card = Fk:getCardById(c)
      if card.color == Card.Red then
        red = red + 1
        room:addCardMark(card, "@@yyfy_zhejiao-next")
      elseif card.color == Card.Black then
        black = black + 1
        room:addCardMark(card, "@@yyfy_zhejiao-next")
      end
    end
    room:addPlayerMark(target, "yyfy_zhejiao_red", red)
    room:addPlayerMark(target, "yyfy_zhejiao_black", black)
  end,
})

-- 加伤
zhejiao:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and data.card and data.card.trueName == "slash"
    and data.to and #data.to:getCardIds("h") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local number = 0
    for _, c in ipairs(data.to:getCardIds("h")) do
      local card = Fk:getCardById(c)
      if card.color == Card.Red and (card:getMark("@@yyfy_zhejiao-next") > 0 or card:getMark("@@yyfy_zhejiao-turn") > 0) then
        number = number + 1
      elseif card.color == Card.Black and card:getMark("@@yyfy_zhejiao-next") == 0 and card:getMark("@@yyfy_zhejiao-turn") == 0 then
        number = number + 1
      end
    end
    data:changeDamage(number)
  end,
})

zhejiao:addEffect(fk.DrawNCards, {
  can_refresh = function (self, event, target, player, data)
    return player and player:hasSkill(self) and
    (target:getMark("yyfy_zhejiao_red") > 0 or target:getMark("yyfy_zhejiao_black") > 0)
  end,
  on_refresh = function (self, event, target, player, data)
    local add = target:getMark("yyfy_zhejiao_red")
    local sub = target:getMark("yyfy_zhejiao_black")
    data.n = math.max(data.n + add - sub, 0)
  end
})

zhejiao:addEffect(fk.RoundEnd, {
  can_refresh = function (self, event, target, player, data)
    return player and player:hasSkill(self, true, true) and
    table.find(player.room:getOtherPlayers(player), function (p)
      for _, c in ipairs(p:getCardIds("h")) do
        if Fk:getCardById(c):getMark("@@yyfy_zhejiao-next") > 0 then
          return true
        end
      end
      return false
    end)
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(player.room:getOtherPlayers(player)) do
      for _, c in ipairs(p:getCardIds("h")) do
        local card = Fk:getCardById(c)
        if card:getMark("@@yyfy_zhejiao-next") > 0 then
          room:setCardMark(card, "@@yyfy_zhejiao-next", 0)
          room:addCardMark(card, "@@yyfy_zhejiao-turn")
        end
      end
    end
  end
})

zhejiao:addEffect(fk.AfterCardsMove, {
  can_refresh = function (self, event, target, player, data)
    return player and player:hasSkill(self, true, true) and table.find(data, function (d)
      for _, m in ipairs(d.moveInfo) do
        local card = Fk:getCardById(m.cardId)
        if card:getMark("@@yyfy_zhejiao-next") > 0 or card:getMark("@@yyfy_zhejiao-turn") > 0 then
          return true
        end
      end
      return false
    end)
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    for _, d in ipairs(data) do
      for _, m in ipairs(d.moveInfo) do
        local card = Fk:getCardById(m.cardId)
        if m.fromArea == Player.Hand and (card:getMark("@@yyfy_zhejiao-next") > 0
         or card:getMark("@@yyfy_zhejiao-turn") > 0) then
          room:setCardMark(card, "@@yyfy_zhejiao-turn", 0)
          room:setCardMark(card, "@@yyfy_zhejiao-next", 0)
        end
      end
    end
  end
})

return zhejiao
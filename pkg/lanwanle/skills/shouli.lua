local shouli = fk.CreateSkill {
  name = "lan__shouli",
}

Fk:loadTranslationTable {
  ["lan__shouli"] = "狩骊",
  [":lan__shouli"] = "游戏开始时，所有其他角色随机使用牌堆、弃牌堆或手牌区的一张坐骑。你可以将场上的一张进攻装备当【杀】" ..
      "（无次数限制）、防御装备当【闪】使用或打出，以此法失去装备牌的其他角色本回合非锁定技失效、受到的伤害+1且改为雷电伤害。",

  ["#lan__shouli"] = "狩骊：选择一名装备着 %arg 的角色",
  ["#lan__shouli-slash"] = "狩骊：选择【杀】的目标角色",
  ["@@lan__shouli-turn"] = "狩骊",

  ["$lan__shouli1"] = "赤骊骋疆，巡狩八荒！",
  ["$lan__shouli2"] = "长缨在手，百骥可降！",
}

shouli:addEffect("viewas", {
  pattern = "slash,jink",
  prompt = function(self, player, card, selected_targets)
    local names = player:getViewAsCardNames(shouli.name, { "slash", "jink" })
    player.tag["lan__shouli-jink"] = names[1] == "jink" and 1 or 0
    if #names == 1 then
      return "#lan__shouli:::" .. (names[1] == "slash" and "进攻装备" or "防御装备")
    end
    return "#lan__shouli:::装备牌"
  end,
  filter_pattern = {
    min_num = 1,
    max_num = 1,
    pattern = ".",
  },
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    return nil
  end,
  target_filter = function(self, player, to_select, selected, selected_cards, c, extra_data)
    if #selected == 0 then
      local card
      for _, id in ipairs(to_select:getCardIds("e")) do
        local card_type = (to_select:getVirtualEquip(id) or Fk:getCardById(id)).sub_type
        if card_type == 3 or card_type == 6 then
          card = Fk:cloneCard("slash")
          if to_select == player then
            card:addSubcard(id)
          end
          card:setVSPattern(shouli.name, nil, ".")
          if Fk.currentResponsePattern == nil then
            return #card:getAvailableTargets(player) > 0
          elseif Exppattern:Parse(Fk.currentResponsePattern):match(card) then
            local handler = ClientInstance.current_request_handler
            if handler and handler.class.name == "ReqResponseCard" then
              return not player:prohibitResponse(card)
            else
              return #card:getAvailableTargets(player, extra_data) > 0
            end
          end
        elseif card_type == 4 or card_type == 5 then
          card = Fk:cloneCard("jink")
          card:setVSPattern(shouli.name, nil, ".")
          if Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(card) then
            local handler = ClientInstance.current_request_handler
            if handler and handler.class.name == "ReqResponseCard" then
              return not player:prohibitResponse(card)
            elseif not player:prohibitUse(card) then
              return true
            end
          end
        elseif card_type == 7 then
          if Fk.currentResponsePattern and (Exppattern:Parse(Fk.currentResponsePattern):match(Fk:cloneCard("jink"))
                or Exppattern:Parse(Fk.currentResponsePattern):match(Fk:cloneCard("slash"))) then
            return true
          end
          card = Fk:cloneCard("slash")
          card:addSubcard(id)
          return not player:prohibitResponse(card) and #card:getAvailableTargets(player, extra_data) > 0
        end
      end
    end
  end,
  feasible = function(self, player, selected, selected_cards, card)
    return #selected == 1
  end,
  on_use = function(self, room, cardUseEvent, _, params)
    local player = cardUseEvent.from
    local to = cardUseEvent.tos[1]
    local card = Fk:cloneCard("jink")
    local jink = params and card:matchPattern(params.pattern) -- 判断是在问杀还是闪
    local horses = table.filter(to:getCardIds("e"), function(id)
      local card_type = (to:getVirtualEquip(id) or Fk:getCardById(id)).sub_type
      if card_type == 3 or card_type == 6 or card_type == 7 and not jink then -- 武器、-1马、宝物
        card = Fk:cloneCard("slash")
        if to == player then
          card:addSubcard(id)
        end
        card:setVSPattern(shouli.name, nil, ".")
        if params == nil then
          return #card:getAvailableTargets(player) > 0
        elseif card:matchPattern(params.pattern) then
          if params.is_response then
            return not player:prohibitResponse(card)
          else
            return #card:getAvailableTargets(player, params.extra_data) > 0
          end
        end
      elseif card_type == 4 or card_type == 5 or card_type == 7 and jink then -- 防具、+1马、宝物
        card = Fk:cloneCard("jink")
        card:setVSPattern(shouli.name, nil, ".")
        if params and card:matchPattern(params.pattern) then
          if params.is_response then
            return not player:prohibitResponse(card)
          else
            return not player:prohibitUse(card)
          end
        end
      end
    end)
    local horse
    if #horses == 0 then
      return
    elseif #horses == 1 then
      horse = horses[1]
    else
      horse = room:askToChooseCard(player, {
        target = to,
        flag = {
          card_data = {
            { "equip_horse", horses }
          }
        },
        skill_name = shouli.name
      })
    end

    if horse then
      local sub_type = (to:getVirtualEquip(horse) or Fk:getCardById(horse)).sub_type
      local card_name = (sub_type == 3 or sub_type == 6 or sub_type == 7 and not jink) and "slash" or "jink"
      if to ~= player then
        room:addPlayerMark(to, "@@lan__shouli-turn", 1)
        room:addPlayerMark(to, MarkEnum.UncompulsoryInvalidity .. "-turn")
      end
      room:obtainCard(player, horse, true, fk.ReasonPrey, player, shouli.name)
      if room:getCardOwner(horse) == player and room:getCardArea(horse) == Player.Hand then
        card = Fk:cloneCard(card_name)
        card.skillName = shouli.name
        card:addSubcard(horse)
        ---@type UseCardDataSpec
        local use = {
          from = player,
          tos = {},
          card = card,
          extraUse = true
        }
        if not (params and params.is_response) and card_name == "slash" then
          local new_use = room:askToUseVirtualCard(player, {
            name = "slash",
            subcards = { horse },
            prompt = "#lan__shouli-slash",
            skill_name = shouli.name,
            extra_data = params and params.extra_data,
            cancelable = false,
            skip = true
          })
          if new_use then
            use.tos = new_use.tos
          else
            return
          end
        end
        return use
      end
    end
  end,
})

shouli:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(shouli.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player, room.alive_players)
    local temp = player.next
    local players = {}
    while temp ~= player do
      if not temp.dead then
        table.insert(players, temp)
      end
      temp = temp.next
    end
    for _, p in ipairs(players) do
      if not p.dead then
        local cards = {}
        for i = 1, #room.draw_pile, 1 do
          local card = Fk:getCardById(room.draw_pile[i])
          if (card.sub_type == Card.SubtypeOffensiveRide or card.sub_type == Card.SubtypeDefensiveRide) and
              p:canUse(card) and not p:prohibitUse(card) then
            table.insertIfNeed(cards, card)
          end
        end
        if #cards == 0 then
          for _, p1 in ipairs(room:getAlivePlayers()) do
            for _, c in ipairs(p1:getCardIds("h")) do
              if Fk:getCardById(c).sub_type == 5 or Fk:getCardById(c).sub_type == 6 then
                table.insertIfNeed(cards, Fk:getCardById(c))
              end
            end
          end
        end
        if #cards == 0 then
          for i = 1, #room.discard_pile, 1 do
            local card = Fk:getCardById(room.discard_pile[i])
            if (card.sub_type == 5 or card.sub_type == 6) and
                p:canUse(card) and not p:prohibitUse(card) then
              table.insertIfNeed(cards, card)
            end
          end
        end
        if #cards > 0 then
          local horse = cards[math.random(1, #cards)]
          room:useCard {
            from = p,
            tos = { p },
            card = horse,
          }
        end
      end
    end
  end,
})

shouli:addEffect(fk.DamageInflicted, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@lan__shouli-turn") > 0
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(1)
    data.damageType = fk.ThunderDamage
  end,
})

shouli:addEffect("targetmod", {
  bypass_times = function(self, player, skillName, scope, card)
    return card and scope == Player.HistoryPhase and table.contains(card.skillNames, shouli.name)
  end,
})

shouli:addEffect(fk.AfterCardsMove, {
  priority = 100,
  can_trigger = function(self, event, target, player, data)
    return #data > 0 and data[1].skillName == shouli.name and data[1].moveReason == fk.ReasonPrey
  end,
  on_trigger = Util.TrueFunc,
})

return shouli
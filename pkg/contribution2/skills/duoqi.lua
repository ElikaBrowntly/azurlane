local yyfy_duoqi = fk.CreateSkill{
  name = "yyfy_duoqi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["yyfy_duoqi"] = "夺炁",
  [":yyfy_duoqi"] = "锁定技，一号位首个回合开始前，你执行一个只有摸牌和出牌阶段的额外回合。所有角色的初始手牌称为“炁”。"..
    "你对一名角色造成伤害后，你获得其一张“炁”。",

  ["@@yyfy_duoqi-inhand"] = "炁",

  ["$yyfy_duoqi1"] = "你的胆气，一文不值！",
  ["$yyfy_duoqi2"] = "你的脊梁，不堪一击！",
}

yyfy_duoqi:addEffect(fk.RoundStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(yyfy_duoqi.name) and player.room:getBanner("RoundCount") == 1
  end,
  on_use = function(self, event, target, player, data)
    player:gainAnExtraTurn(true, yyfy_duoqi.name, { Player.Draw, Player.Play })
  end,
})

yyfy_duoqi:addEffect(fk.GameStart, {
  mute = true,
  --实测只计算初始手牌，机制不明，这里靠提高记录优先级来实现
  priority = 9,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(yyfy_duoqi.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local mark, ids = {}, {}
    for _, p in ipairs(room.alive_players) do
      local handcards = p:getCardIds("h")
      mark[tostring(p.id)] = handcards
      table.insertTableIfNeed(ids, handcards)
      if p == player then
        for _, id in ipairs(handcards) do
          --FIXME: 实测所有角色都能看到被记录的“炁”，先偷个懒
          room:setCardMark(Fk:getCardById(id), "@@yyfy_duoqi-inhand", 1)
        end
      end
    end
    room:setPlayerMark(player, "yyfy_duoqi_record", mark)
    room:setPlayerMark(player, "yyfy_duoqi_cards", ids)
  end,
})

yyfy_duoqi:addEffect(fk.AfterCardsMove, {
  can_refresh = function (self, event, target, player, data)
    --FIXME: 实测所有角色都能看到被记录的“炁”，先偷个懒
    return player:hasSkill(yyfy_duoqi.name, true)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local mark = player:getTableMark("yyfy_duoqi_cards")
    if #mark == 0 then return end
    for _, id in ipairs(player:getCardIds("h")) do
      if table.contains(mark, id) then
        room:setCardMark(Fk:getCardById(id), "@@yyfy_duoqi-inhand", 1)
      end
    end
  end,
})

yyfy_duoqi:addEffect(fk.Damage, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player == target and player:hasSkill(yyfy_duoqi.name)
  end,
  on_cost = function(self, event, target, player, data)
    event:setCostData(self, { tos = { data.to } })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local to = data.to
    local cards = player:getTableMark("yyfy_duoqi_record")[tostring(to.id)]
    if cards == nil then return end
    local room = player.room
    --移动信息对其他角色不可见
    --优先级顺序：其手牌区>其装备区>其判定区>从其开始，除其外的每名其他角色的{手牌区>装备区>判定区}>
    --弃牌堆>摸牌堆>自己的装备区>自己的判定区
    local to_get = {}

    local all_players = room:getAllPlayers()
    if to ~= player then
      table.removeOne(all_players, player)
    end
    local index = table.indexOf(all_players, to)
    local p
    for i = index, #all_players, 1 do
      p = all_players[i]
      for _, playerArea in ipairs({"h", "e", "j"}) do
        to_get = table.filter(p:getCardIds(playerArea), function(id)
          return table.contains(cards, id)
        end)
        if #to_get > 0 then
          if playerArea ~= "h" or p ~= player then
            room:obtainCard(player, room:tableRandomPick(to_get), false, fk.ReasonPrey, player, yyfy_duoqi.name)
          end
          return
        end
      end
    end
    if index > 1 then
      for i = 1, index - 1, 1 do
        p = all_players[i]
        for _, playerArea in ipairs({"h", "e", "j"}) do
          to_get = table.filter(p:getCardIds(playerArea), function(id)
            return table.contains(cards, id)
          end)
          if #to_get > 0 then
            if playerArea ~= "h" or p ~= player then
              room:obtainCard(player, room:tableRandomPick(to_get), false, fk.ReasonPrey, player, yyfy_duoqi.name)
            end
            return
          end
        end
      end
    end

    -- 弃牌堆和摸牌堆：通过 getCardArea 判定，比直接查 discard_pile/draw_pile 更可靠
    to_get = table.filter(cards, function(id)
      return room:getCardArea(id) == Card.DiscardPile
    end)
    if #to_get == 0 then
      to_get = table.filter(cards, function(id)
        return room:getCardArea(id) == Card.DrawPile
      end)
    end
    if #to_get > 0 then
      room:obtainCard(player, room:tableRandomPick(to_get), false, fk.ReasonJustMove, player, yyfy_duoqi.name)
      return
    end

    if to ~= player then
      for _, playerArea in ipairs({"e", "j"}) do
        to_get = table.filter(player:getCardIds(playerArea), function(id)
          return table.contains(cards, id)
        end)
        if #to_get > 0 then
          room:obtainCard(player, room:tableRandomPick(to_get), false, fk.ReasonPrey, player, yyfy_duoqi.name)
          return
        end
      end
    end
  end,
})

yyfy_duoqi:addLoseEffect(function (self, player, is_death)
  local room = player.room
  room:setPlayerMark(player, "yyfy_duoqi_cards", 0)
  room:setPlayerMark(player, "yyfy_duoqi_record", 0)
  for _, id in ipairs(player:getCardIds("h")) do
    room:setCardMark(Fk:getCardById(id), "@@yyfy_duoqi-inhand", 0)
  end
end)

return yyfy_duoqi
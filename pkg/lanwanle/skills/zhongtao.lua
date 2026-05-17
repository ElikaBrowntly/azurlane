local zhongtao = fk.CreateSkill {
  name = "lan__zhongtao",
}

Fk:loadTranslationTable{
  ["lan__zhongtao"] = "众讨",
  [":lan__zhongtao"] = "出牌阶段限一次，你可以随机从场上、弃牌堆或牌堆获得4种花色的牌各一张。" ..
  "若如此做，你使用三种类别的牌后，此技能视为未发动过。",

  ["#lan__zhongtao"] = "众讨：你可以随机获得4种花色的牌各一张",

  ["$lan__zhongtao1"] = "凉州男儿，可愿随我再破千军！",
  ["$lan__zhongtao2"] = "你我勠力讨贼，何人可堪一战！",
}

zhongtao:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#lan__zhongtao",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local choices = {"spade", "heart", "club", "diamond"}

    local cardsOnField = {}
    local suitsOnField = {}
    for _, p in ipairs(room.alive_players) do
      local cards = p:getCardIds("ej")
      for _, id in ipairs(cards) do
        local suit = Fk:getCardById(id):getSuitString()
        if table.contains(choices, suit) then
          cardsOnField[suit] = cardsOnField[suit] or {}
          table.insert(cardsOnField[suit], id)
          table.insertIfNeed(suitsOnField, suit)
        end
      end
    end

    local toObtain = {}
    if next(cardsOnField) ~= nil then
      local randomSuit = room:tableRandomPick(suitsOnField)
      table.removeOne(choices, randomSuit)
      table.insert(toObtain, room:tableRandomPick(cardsOnField[randomSuit]))
    end

    for _, suit in ipairs(choices) do
      local ids = room:getCardsFromPileByRule(".|.|" .. suit, 1, "discardPile")
      if #ids == 0 then
        ids = room:getCardsFromPileByRule(".|.|" .. suit)

        if #ids == 0 then
          table.insertTable(ids, cardsOnField[suit] or {})
        end
      end

      if #ids > 0 then
        table.insert(toObtain, room:tableRandomPick(ids))
      end
    end

    if #toObtain > 0 then
      room:obtainCard(player, toObtain, false, fk.ReasonPrey, player, zhongtao.name)
    end
  end,
})

zhongtao:addEffect(fk.CardUseFinished, {
  can_refresh = function(self, event, target, player, data)
    return
      target == player and
      player:hasSkill(zhongtao.name, true) and
      player.phase == Player.Play and
      not table.contains(player:getTableMark("lan__zhongtao_record-phase"), data.card.type)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:addTableMark(player, "lan__zhongtao_record-phase", data.card.type)
    if #player:getTableMark("lan__zhongtao_record-phase") > 2 then
      room:setPlayerMark(player, "lan__zhongtao_record-phase", 0)
      if player:usedSkillTimes(zhongtao.name) > 0 then
        player:clearSkillHistory(zhongtao.name)
      end
    end
  end,
})

return zhongtao
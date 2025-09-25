local quzhou = fk.CreateSkill {
  name = "lan__quzhou",
}

Fk:loadTranslationTable{
  ["lan__quzhou"] = "趋舟",
  [":lan__quzhou"] = "出牌阶段限一次，你可以重复亮出牌堆顶的牌直到亮出【杀】，然后你使用此【杀】并获得其余牌。",

  ["#lan__quzhou"] = "趋舟：亮出牌堆顶牌直到亮出【杀】",
  ["#lan__quzhou-use"] = "趋舟：请使用这张【杀】",

  ["$lan__quzhou1"] = "冲！冲！",
  ["$lan__quzhou2"] = "靠近！靠近！",
}

quzhou:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#lan__quzhou",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local revealedCards = {}  -- 记录所有亮出的牌
    
    -- 重复亮出牌直到亮出【杀】
    while true do
      local ids = room:getNCards(1)
      room:turnOverCardsFromDrawPile(player, ids, self.name)
      table.insert(revealedCards, ids[1])
      
      local card = Fk:getCardById(ids[1])
      if card.trueName == "slash" then
        -- 亮出【杀】，使用这张【杀】
        room:askToUseRealCard(player, {
          pattern = ids,
          skill_name = self.name,
          prompt = "#lan__quzhou-use",
          extra_data = {
            bypass_times = true,
            extraUse = true,
            expand_pile = ids,
          },
          cancelable = false,
        })
        break
      end
      -- 如果不是【杀】，继续亮出下一张牌
    end
    
    -- 获得其余的牌
    if #revealedCards > 1 then
      local cardsToObtain = {}
      for i = 1, #revealedCards - 1 do
        table.insert(cardsToObtain, revealedCards[i])
      end
      room:obtainCard(player, cardsToObtain, true, fk.ReasonJustMove, player, self.name)
    end
    
    room:cleanProcessingArea(revealedCards, self.name)
  end,
})

return quzhou
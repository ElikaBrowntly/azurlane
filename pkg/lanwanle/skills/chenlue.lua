local chenlue = fk.CreateSkill {
  name = "lan__chenlue"
}

Fk:loadTranslationTable{
  ["lan__chenlue"] = "沉略",
  [":lan__chenlue"] = "出牌阶段限一次，你可以从牌堆、弃牌堆、场上或其他角色的手牌中获得所有“死士”牌。",

  ["#lan__chenlue"] = "沉略：是否要获得所有“死士”牌",

  ["$lan__chenlue1"] = "怀泰山之重，必立以千仞。",
  ["$lan__chenlue2"] = "万世之勋待取，此乃亮剑之时。",
  ["$lan__chenlue3"] = "寒来暑往，春秋相异，我辈慕白，则九月飞雪！",
  ["$lan__chenlue4"] = "砺剑数载，今青锋始现，欲杀人于十步之内。"
}

chenlue:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#lan__chenlue",
  card_num = 0,
  target_num = 0,
  max_phase_use_time = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(chenlue.name, Player.HistoryPhase) == 0 and player:getMark("lan__sanshi") ~= 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local areas = { Card.PlayerEquip, Card.PlayerJudge, Card.DrawPile, Card.DiscardPile }
    local handcards = player:getCardIds("h")
    local cards = table.filter(player:getTableMark("lan__sanshi"), function(id)
      local area = room:getCardArea(id)
      return table.contains(areas, area) or (area == Card.PlayerHand and not table.contains(handcards, id))
    end)
    if #cards > 0 then
      room:setPlayerMark(player, "lan__chenlue-phase", cards)
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonPrey, chenlue.name, nil, true, player)
    end
  end,
})

return chenlue
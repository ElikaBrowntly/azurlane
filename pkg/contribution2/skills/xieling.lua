local xieling = fk.CreateSkill{
  name = "yyfy_xieling",
}

Fk:loadTranslationTable{
  ["yyfy_xieling"] = "挟令",
  [":yyfy_xieling"] = "你额定回合的出牌阶段，可以弃置一张牌并结束此阶段，然后在本回合结束后获得一个额外回合。",
  ["#yyfy_xieling"] = "你可以弃置一张牌并结束出牌阶段，然后获得一个额外回合",
}

xieling:addEffect("active", {
  prompt = "#yyfy_xieling",
  card_num = 1,
  card_filter = function (self, player, to_select, selected, selected_targets)
    return #selected == 0 and not player:prohibitDiscard(to_select)
  end,
  target_num = 0,
  target_filter = Util.FalseFunc,
  can_use = function(self, player)
    return player:getCurrentExtraTurnReason() == "game_rule"
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:throwCard(effect.cards, xieling.name, player, player)
    player:endPlayPhase()
    player:gainAnExtraTurn()
  end
})

return xieling
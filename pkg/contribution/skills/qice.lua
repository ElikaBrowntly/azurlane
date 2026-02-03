local qice = fk.CreateSkill {
  name = "yyfy_qice",
}

Fk:loadTranslationTable{
  ["yyfy_qice"] = "奇策",
  [":yyfy_qice"] = "出牌阶段限一次，你可以将任意张手牌当任意普通锦囊牌使用。",

  ["#yyfy_qice"] = "奇策：将任意张手牌当任意普通锦囊牌使用",

  ["$yyfy_qice1"] = "倾力为国，算无遗策。",
  ["$yyfy_qice2"] = "奇策在此，谁与争锋？"
}

qice:addEffect("viewas", {
  prompt = "#yyfy_qice",
  mute_card = false,
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("t")
    return UI.CardNameBox {
      choices = player:getViewAsCardNames(qice.name, all_names),
      all_choices = all_names,
      default_choice = "AskForCardsChosen",
    }
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return table.contains(player:getHandlyIds(), to_select) and #selected < #player:getCardIds("h")
  end,
  view_as = function(self, player, cards)
    if Fk.all_card_types[self.interaction.data] == nil then return end
    if #cards == 0 then return nil end
    
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcards(cards)
    card.skillName = self.name
    return card
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(qice.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
})

return qice
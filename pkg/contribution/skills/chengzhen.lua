local chengzhen = fk.CreateSkill {
  name = "yyfy_chengzhen",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable{
  ["yyfy_chengzhen"] = "成真",
  [":yyfy_chengzhen"] = "持恒技，每回合限X次，当你想要使用或打出非装备牌时，你可以视为使用或打出（X为你的体力值）。",

  ["#yyfy_chengzhen"] = "成真：你可以视为使用或打出一张非装备牌",
}

chengzhen:addEffect("viewas", {
  prompt = "#yyfy_chengzhen",
  mute_card = false,
  pattern = ".",
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("bt")
    return UI.CardNameBox {
      choices = player:getViewAsCardNames(chengzhen.name, all_names),
      all_choices = all_names,
      default_choice = "AskForCardsChosen",
    }
  end,
  handly_pile = false,
  card_num = 0,
  view_as = function(self, player, cards)
    if Fk.all_card_types[self.interaction.data] == nil then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    return card
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(chengzhen.name, Player.HistoryTurn) < player.hp
  end,
  enabled_at_response = function (self, player, response)
    return not response and player:usedSkillTimes(chengzhen.name, Player.HistoryTurn) < player.hp
  end,
  enabled_at_nullification = Util.TrueFunc
})

return chengzhen
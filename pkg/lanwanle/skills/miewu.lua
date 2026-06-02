local miewu = fk.CreateSkill {
  name = "lan__miewu",
}

Fk:loadTranslationTable{
  ["lan__miewu"] = "灭吴",
  [":lan__miewu"] = "你可以弃置1个“武库”，视为使用或打出一张基本牌或锦囊牌，并摸一张牌。",

  ["#lan__miewu"] = "灭吴：弃置1枚武库标记，视为使用或打出一张基本牌或锦囊牌，然后摸一张牌",

  ["$lan__miewu1"] = "倾荡之势已成，石城尽在眼下",
  ["$lan__miewu2"] = "吾军势如破竹，江东六郡唾手可得。",
}

miewu:addEffect("viewas", {
  pattern = ".",
  prompt = "#lan__miewu",
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("btd")
    local names = player:getViewAsCardNames(miewu.name, all_names)
    if #names == 0 then return end
    return UI.CardNameBox {choices = names, all_choices = all_names}
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    if not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = miewu.name
    return card
  end,
  before_use = function(self, player, use)
    player.room:removePlayerMark(player, "@lan__wuku")
  end,
  after_use = function (self, player, use)
    if not player.dead then
      player:drawCards(1, miewu.name)
    end
  end,
  enabled_at_play = function(self, player)
    return player:getMark("@lan__wuku") > 0
  end,
  enabled_at_response = function(self, player, response)
    return player:getMark("@lan__wuku") > 0
  end,
})

return miewu
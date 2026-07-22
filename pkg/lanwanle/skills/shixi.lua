local shixi = fk.CreateSkill {
  name = "lan__shixi"
}

Fk:loadTranslationTable {
  ["lan__shixi"] = "拾昔",
  [":lan__shixi"] = "当你需要使用普通锦囊牌时，你可以将一个花色的所有牌置入弃牌堆，视为使用之。",

  ["#lan__shixi"] = "拾昔：将一个花色的所有牌置入弃牌堆，视为使用一张普通锦囊牌",
  ["#lan__shixi-use"] = "拾昔：将一个花色的所有牌置入弃牌堆，视为使用【%arg】",

  ["$lan__shixi1"] = "满枝橘子香，小女窗前贴花黄。",
  ["$lan__shixi2"] = "提裙扑流萤，囊灯一盏照夜读。",
  ["$lan__shixi3"] = "竿儿起，竿儿落，小小竿儿两头卧。",
  ["$lan__shixi4"] = "三月三，跳竹竿，绣球要挂彩云端。"
}

shixi:addEffect("viewas", {
  pattern = ".|.|.|.|.|normal_trick",
  prompt = function(self)
    return self.interaction.data and "#lan__shixi-use:" .. ":" .. self.interaction.data or "#lan__shixi"
  end,
  interaction = function(self, player)
    local all = Fk:getAllCardNames("t")
    local names = player:getViewAsCardNames(shixi.name, all)
    if #names == 0 then return end
    return UI.CardNameBox { choices = names, all_choices = all }
  end,
  filter_pattern = {
    min_num = 0,
    max_num = 0,
    pattern = ".",
  },
  view_as = function(self, player, cards)
    if not self.interaction.data then return end
    local card_name = self.interaction.data
    local card = Fk:cloneCard(card_name, nil, nil, shixi.name)
    return card
  end,
  before_use = function(self, player, use)
    local room = player.room
    local choices = {}
    local all = { "log_spade", "log_heart", "log_club", "log_diamond" }
    for i, suit in pairs({ Card.Spade, Card.Heart, Card.Club, Card.Diamond }) do
      if table.find(player:getCardIds("he"), function(id)
            return Fk:getCardById(id).suit == suit
          end) then
        table.insert(choices, all[i])
      end
    end
    if #choices == 0 then return end
    local suit = room:askToChoice(player, {
      choices = choices,
      all_choices = all,
      skill_name = shixi.name,
      prompt = "拾昔：请将一个花色的所有牌置入弃牌堆",
      cancelable = false
    })
    local fake_cards = table.filter(player:getCardIds("he"), function(id)
      return Fk:getCardById(id):getSuitString() == suit
    end)
    use.card:addFakeSubcards(fake_cards)
    room:moveCardTo(use.card.fake_subcards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, shixi.name, nil,
      true, player)
  end,
  enabled_at_response = function(self, player, response)
    return not response
  end
})

return shixi
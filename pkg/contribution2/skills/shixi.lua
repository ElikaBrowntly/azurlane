
local shixi = fk.CreateSkill {
  name = "yyfy_shixi"
}

Fk:loadTranslationTable{
  ["yyfy_shixi"] = "拾昔",
  [":yyfy_shixi"] = "当你需要使用【无中生有】时，你可以将一种花色的所有牌置入弃牌堆，视为使用之。",

  ["#yyfy_shixi"] = "拾昔：将一个花色的所有牌置入弃牌堆，视为使用【无中生有】",

  ["$yyfy_shixi1"] = "满枝橘子香，小女窗前贴花黄。",
  ["$yyfy_shixi2"] = "提裙扑流萤，囊灯一盏照夜读。",
  ["$yyfy_shixi3"] = "竿儿起，竿儿落，小小竿儿两头卧。",
  ["$yyfy_shixi4"] = "三月三，跳竹竿，绣球要挂彩云端。"
}

shixi:addEffect("viewas", {
  pattern = ".|.|.|.|.|normal_trick",
  prompt = "#yyfy_shixi",
  interaction = function(self, player)
    local choices = {}
    local all = {"log_spade", "log_heart", "log_club", "log_diamond"}
    for i, suit in pairs({Card.Spade, Card.Heart, Card.Club, Card.Diamond}) do
      if table.find(player:getCardIds("he"), function (id)
        return Fk:getCardById(id).suit == suit
      end) then
        table.insert(choices, all[i])
      end
    end
    if #choices == 0 then return end
    return UI.ComboBox { choices = choices, all_choices = all }
  end,
  filter_pattern = {
    min_num = 0,
    max_num = 0,
    pattern = ".",
  },
  view_as = function(self, player, cards)
    local suit = self.interaction.data
    if not suit then return end
    local card = Fk:cloneCard("ex_nihilo")
    local subcards = table.filter(player:getCardIds("he"), function (id)
      return Fk:getCardById(id):getSuitString(true) == suit
    end)
    card:addFakeSubcards(subcards)
    card.skillName = shixi.name
    return card
  end,
  before_use = function (self, player, use)
    player.room:moveCardTo(use.card.fake_subcards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, shixi.name, nil, true, player)
  end,
  enabled_at_response = function (self, player, response)
    return not response
  end,
  enabled_at_nullification = Util.FalseFunc,
})

return shixi
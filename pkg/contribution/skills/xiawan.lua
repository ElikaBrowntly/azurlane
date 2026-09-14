local xiawan = fk.CreateSkill {
  name = "yyfy_xiawan",
}

Fk:loadTranslationTable {
  ["yyfy_xiawan"] = "瞎玩",
  [":yyfy_xiawan"] = "你使用牌无距离次数限制。当你使用牌时，你摸一张牌。"
}

xiawan:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return data.from == player and player:hasSkill(self)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, xiawan.name)
  end,
})

xiawan:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and player and player:hasSkill(self)
  end,
  bypass_distances = function(self, player, skill, card, to)
    return card and player and player:hasSkill(self)
  end
})

return xiawan
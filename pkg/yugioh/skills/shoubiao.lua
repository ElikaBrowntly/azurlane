local shoubiao = fk.CreateSkill{
  name = "yyfy_shoubiao",
}

Fk:loadTranslationTable{
  ["yyfy_shoubiao"] = "守表",
  [":yyfy_shoubiao"] = "你出场后的第一个自己回合结束前，不能使用伤害类牌。",

  ["@@yyfy_shoubiao"] = "守备表示"
}

shoubiao:addEffect(fk.AfterPropertyChange, {
  anim_type = "negative",
  can_trigger = function (self, event, target, player, data)
    return player and target == player and player:hasSkill(self, true, true)
    and (data.general == "yyfy_yunshitoken" or data.deputyGeneral == "yyfy_yunshitoken")
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@@yyfy_shoubiao", 1)
  end
})

shoubiao:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    return player:getMark("@@yyfy_shoubiao") > 0 and card.is_damage_card
  end,
})

shoubiao:addEffect(fk.TurnEnd, {
  priority = 0.01,
  can_refresh = function (self, event, target, player, data)
    return data.who == player and player:hasSkill(self, true, true) and player:getMark("@@yyfy_shoubiao") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@@yyfy_shoubiao", 0)
  end
})

return shoubiao
local skill = fk.CreateSkill {
  name = "yyfy_jiewu",
}

Fk:loadTranslationTable {
  ["yyfy_jiewu"] = "捷悟",
  [":yyfy_jiewu"] = "当你使用牌时，你可以摸一张牌。",

  ["$yyfy_jiewu1"] = "只此四字，绝、妙、好、辞。",
  ["$yyfy_jiewu2"] = "君侯，他日君若乘上高轩，我当为君揽辔策马！"
}

local F = require("packages.hidden-clouds.functions")

skill:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return data.from == player and player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, skill.name)
  end,
})

skill:addEffect(fk.TurnStart, {
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self, true)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:setEmotion(player, "./packages/hidden-clouds/image/anim/dengchang_ex__yyfy_yongyimoyi")
  end
})

return skill
local xinyan = fk.CreateSkill{
  name = "yyfy_xinyan"
}

Fk:loadTranslationTable{
  ["yyfy_xinyan"] = "心眼",
  [":yyfy_xinyan"] = "回合结束时，你可以获得1次[受到伤害前，使该回合回避受到的伤害]的状态，直到你的下个回合开始。",
  ["@yyfy_xinyan"] = "心眼",
  ["@@yyfy_xinyan-turn"] = "心眼",

  ["$yyfy_xinyan1"] = "只是余兴，来狩猎吧。",
  ["$yyfy_xinyan2"] = "人形的容器还真是不方便呢。",
  ["$yyfy_xinyan3"] = "那么，欢迎光临。"
}

xinyan:addEffect(fk.TurnEnd, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xinyan.name,
      prompt = "心眼：是否要获得一次一回合的回避状态？"
    })
  end,
  on_use = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@yyfy_xinyan", 1)
  end
})

xinyan:addEffect(fk.PreDamage, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return data.to == player and player:hasSkill(self) and
    (player:getMark("@@yyfy_xinyan-turn") > 0 or player:getMark("@yyfy_xinyan") > 0)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if player:getMark("@yyfy_xinyan") > 0 then
      room:setPlayerMark(player, "@yyfy_xinyan", 0)
      room:setPlayerMark(player, "@@yyfy_xinyan-turn", 1)
    end
    data:preventDamage()
  end
})

xinyan:addEffect(fk.TurnStart, {
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:getMark("@yyfy_xinyan") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@yyfy_xinyan", 0)
  end
})

return xinyan
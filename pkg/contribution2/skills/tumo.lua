local tumo = fk.CreateSkill {
  name = "yyfy__tumo"
}

Fk:loadTranslationTable {
  ["yyfy__tumo"] = "屠魔",
  [":yyfy__tumo"] = "当你造成伤害时，你可以令对方扣减等量点体力上限并且本回合非锁定技失效。当你杀死一名其他角色后，你加一点体力上限。",

  ["#yyfy__tumo-invoke"] = "屠魔：是否令%dest扣减体力上限且技能失效？",
}

tumo:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.to and data.to:isAlive() and data.damage > 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = tumo.name,
      prompt = "#yyfy__tumo-invoke::" .. data.to.id
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(data.to, MarkEnum.UncompulsoryInvalidity .. "-turn")
    room:changeMaxHp(data.to, -data.damage)
  end,
})

tumo:addEffect(fk.Deathed, {
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(tumo.name) and data.who ~= player and data.killer == player
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:changeMaxHp(player, 1)
  end
})

return tumo
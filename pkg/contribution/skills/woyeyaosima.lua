local woyeyaosima = fk.CreateSkill {
  name = "yyfy_woyeyaosima",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable {
  ["yyfy_woyeyaosima"] = "我也要死吗",
  [":yyfy_woyeyaosima"] = "持恒技，其他角色死亡后，你也可以死亡。你死亡后，令一名其他角色死亡。",
}

woyeyaosima:addEffect(fk.Death, {
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(self) and target ~= player
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = woyeyaosima.name,
      prompt = "我也要死吗：你可以死亡，然后令另一名其他角色死亡"
    })
  end,
  on_use = function(self, event, target, player, data)
    player.room:killPlayer({
      who = player,
      killer = player
    })
  end
})

woyeyaosima:addEffect(fk.Death, {
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(self, false, true) and target == player
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      targets = room:getOtherPlayers(player, false, false),
      min_num = 1,
      max_num = 1,
      skill_name = woyeyaosima.name,
      prompt = "我也要死吗：请选择一名角色一起死亡",
      cancelable = false
    })
    if #to ~= 1 then return false end
    room:killPlayer({
      who = to[1],
      killer = player
    })
  end
})

return woyeyaosima
local congyun = fk.CreateSkill {
  name = "yyfy_congyun"
}

Fk:loadTranslationTable {
  ["yyfy_congyun"] = "丛云",
  [":yyfy_congyun"] = "其他角色处于濒死状态时，你可以令其将体力值回复至上限，然后你死亡。",
  ["#yyfy_congyun-invoke"] = "丛云：是否要令%dest回复体力，然后你死亡？"
}

congyun:addEffect(fk.AskForPeaches, {
  anim_type = "big",
  can_trigger = function(self, event, target, player, data)
    return player and target ~= player and player:hasSkill(self)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = congyun.name,
      prompt = "#yyfy_congyun-invoke::"..target.id
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:recover({
      who = target,
      num = target.maxHp - target.hp,
      recoverBy = player,
      skillName = congyun.name
    })
    room:killPlayer({
      who = player
    })
  end
})

return congyun
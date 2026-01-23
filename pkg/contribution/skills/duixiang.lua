local duixiang = fk.CreateSkill {
  name = "yyfy_duixiang",
  anim_type = "defensive",
  tags = {Skill.Permanent}
}

Fk:loadTranslationTable{
  ["yyfy_duixiang"] = "对象",
  [":yyfy_duixiang"] = "永恒技，多目标牌对你无效。",
}

duixiang:addLoseEffect(function(self, player, is_death)
  local room = player.room
  room:handleAddLoseSkills(player, duixiang.name, nil, false, true)
end)

duixiang:addEffect(fk.TargetConfirmed, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(duixiang.name) and data.card and data.card.multiple_targets
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.use.nullifiedTargets = data.use.nullifiedTargets or {}
    table.insertIfNeed(data.use.nullifiedTargets, player)
  end,
})

return duixiang
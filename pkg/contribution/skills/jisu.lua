local jisu = fk.CreateSkill{
  name = "yyfy_jisu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["yyfy_jisu"] = "急速",
  [":yyfy_jisu"] = "锁定技，其他角色的额定回合开始前（每轮每名角色限一次），你执行一个只有摸牌阶段和出牌阶段的额外回合。",
  ["@@yyfy_jisu-turn"] = "急速",
}

jisu:addEffect(fk.TurnStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(self) and target ~= player and not
    table.contains(player:getTableMark("yyfy_jisu-round"), target.id) and data.reason == "game_rule"
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addTableMark(player, "yyfy_jisu-round", target.id)
    room:notifyMoveFocus(player, "出牌 思考中...")
    player:gainAnExtraTurn(false, jisu.name, {Player.Draw, Player.Play})
  end,
})

return jisu
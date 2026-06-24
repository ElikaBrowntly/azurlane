local bingruo = fk.CreateSkill{
  name = "yyfy_bingruo",
  tags = { Skill.Compulsory }
}

Fk:loadTranslationTable{
  ["yyfy_bingruo"] = "病弱",
  [":yyfy_bingruo"] = "锁定技，每轮结束时，你失去一点体力。出牌阶段限一次，你可以令一名其他角色获得此技能。"
}

bingruo:addEffect(fk.RoundEnd, {
  anim_type = "negative",
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self)
  end,
  on_use = function (self, event, target, player, data)
    player.room:loseHp(player, 1, bingruo.name)
  end
})

bingruo:addEffect("active", {
  anim_type = "negative",
  can_use = function (self, player)
    return player and player:hasSkill(self) and #Fk:currentRoom().alive_players > 1
    and player:usedSkillTimes(bingruo.name, Player.HistoryPhase) == 0
  end,
  target_num = 1,
  target_filter = function (self, player, to_select, selected, selected_cards, card, extra_data)
    return #selected == 0 and to_select ~= player
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  on_use = function (self, room, effect)
    room:handleAddLoseSkills(effect.tos[1], bingruo.name)
  end
})

return bingruo
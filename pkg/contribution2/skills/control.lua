local control = fk.CreateSkill {
  name = "yyfy_control",
}

Fk:loadTranslationTable {
  ["yyfy_control"] = "控制",
  [":yyfy_control"] = "出牌阶段限一次，你可以控制一名其他角色，直到你下次发动此技能。",
  ["$yyfy_control1"] = "战将临阵，斩关刈城！",
  ["$yyfy_control2"] = "区区数百魏军，看我一击灭之。",
}

control:addEffect("active", {
  anim_type = "control",
  can_use = function(self, player)
    return player:hasSkill(self) and player:usedSkillTimes(control.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  card_num = 0,
  target_filter = function(self, player, to_select, selected)
    return to_select ~= player and #selected == 0
  end,
  target_num = 1,
  on_use = function(self, room, effect)
    local from = effect.from
    local last = from:getMark(control.name)
    if #effect.tos ~= 1 or effect.tos[1].id == last then return end
    local to = room:getPlayerById(last)
    if last ~= 0 and from:isControlling(to) then
      from:uncontrol(to)
    end
    to = effect.tos[1]
    if not from:isControlling(to) then
      from:control(to)
    end
    room:setPlayerMark(from, control.name, to.id)
  end,
})

return control
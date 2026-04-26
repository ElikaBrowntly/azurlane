local qiyuan = fk.CreateSkill {
  name = "yyfy_qiyuan",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable {
  ["yyfy_qiyuan"] = "起源",
  [":yyfy_qiyuan"] = "持恒技，出牌阶段限一次，你可以触发一次“游戏开始时”的时机。"
}

qiyuan:addEffect("active", {
  prompt="起源：你可以触发一次“游戏开始时”的时机",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(qiyuan.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    room.logic:trigger(fk.GameStart, effect.from)
  end,
})

return qiyuan
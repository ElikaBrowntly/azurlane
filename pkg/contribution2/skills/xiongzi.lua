local xiongzi = fk.CreateSkill {
  name = "yyfy_xiongzi",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["yyfy_xiongzi"] = "雄姿",
  [":yyfy_xiongzi"] = "限定技，准备阶段开始时，你可以摸两张牌。",

  ["$yyfy_xiongzi1"] = "纵有波汹浪涌，岂阻江海奔流。",
  ["$yyfy_xiongzi2"] = "雄图尽展，坐待天下归吴。",
  ["$yyfy_xiongzi3"] = "以吾一人心火，焚汝百万庸贼",
  ["$yyfy_xiongzi4"] = "九州犹在，试问谁主沉浮？！",
}

xiongzi:addEffect(fk.EventPhaseStart, {
  can_trigger = function (self, event, target, player, data)
    return
      target == player and
      player.phase == Player.Start and
      player:hasSkill(xiongzi.name) and
      player:usedSkillTimes(xiongzi.name, Player.HistoryGame) == 0
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xiongzi.name,
      prompt = "雄姿：你可以摸两张牌"
    })
  end,
  on_use = function (self, event, target, player, data)
    player:drawCards(2, xiongzi.name)
  end,
})

return xiongzi
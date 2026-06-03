local yifa = fk.CreateSkill{
  name = "yyfy_yifa",
  tags = { Skill.Compulsory }
}

Fk:loadTranslationTable{
  ["yyfy_yifa"] = "仪法",
  [":yyfy_yifa"] = "锁定技，当你受到伤害时，你将〖博览〗中“出牌阶段限一次的技能”改为“受到伤害后的技能”直到回合结束，"..
  "然后你发动一次〖博览〗。",
  ["@@yyfy_yifa-turn"] = "仪法",
  ["$yyfy_yifa1"] = "仪法不明，则实不称名。",
  ["$yyfy_yifa2"] = "仪法明晰，则长治久安。",
}

yifa:addEffect(fk.DamageInflicted, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@@yyfy_yifa-turn")
    room:askToUseActiveSkill(player, {
      skill_name = "yyfy_bolan",
      cancelable = false
    })
  end
})

return yifa
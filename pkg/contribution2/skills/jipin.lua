local jipin = fk.CreateSkill {
  name = "yyfy_jipin",
  tags = { Skill.Wake },
}

Fk:loadTranslationTable{
  ["yyfy_jipin"] = "祭品",
  [":yyfy_jipin"] = "觉醒技，当你进入濒死状态时，你将武将牌替换为“丛雨”并将体力回复至上限。",

  ["$yyfy_jipin1"] = "得遇丞相，再生之德！",
  ["$yyfy_jipin2"] = "丞相大义，维岂有不从之理？",
}

jipin:addEffect(fk.EnterDying, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jipin.name) and player:usedSkillTimes(jipin.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return player.dying
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local deputy = (player.deputyGeneral or "") == "yyfy_Aya" and true or false
    room:changeHero(player, "yyfy_Murasame", true, deputy)
  end,
})

return jipin
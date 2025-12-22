local qiangfeng = fk.CreateSkill{
  name = "yyfy_qiangfeng", -- 强风
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  [":yyfy_qiangfeng"] = "你至其他角色的距离恒为1，你使用牌无次数限制且无法被响应",
}
qiangfeng:addEffect("distance", {
  correct_func = function(self, from, to)
    if from:hasSkill(self.name) then
      return 1 - from:distanceTo(to)
    end
  end,
})

qiangfeng:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card)
    if player:hasSkill(qiangfeng.name) and card and scope == Player.HistoryPhase then
      return true
    end
  end,
})

qiangfeng:addEffect(fk.CardUsing, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(qiangfeng.name) and not data.extraUse and
      (player:usedCardTimes("slash", Player.HistoryPhase) > 1
      or player:usedCardTimes("analeptic", Player.HistoryPhase) > 1)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:doAnimate("InvokeSkill", {
      name = "qiangfeng",
      player = player.id,
      skill_type = qiangfeng.name,
    })
  end,
})

return qiangfeng
local qiangfeng = fk.CreateSkill{
  name = "yyfy_qiangfeng", -- 强风
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["yyfy_qiangfeng"] = "强风",
  [":yyfy_qiangfeng"] = "你与其他角色的距离-10，你使用牌无次数限制且无法被响应",
}
qiangfeng:addEffect("distance", {
  correct_func = function(self, from, to)
    if from:hasSkill(self.name) then
      return -10
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

-- 仿照咆哮，额外出杀的时候显示特效
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

-- 不可被响应
qiangfeng:addEffect(fk.CardUsing, {
  mute = true,
  on_cost = function(self, event, target, player, data)
    return player:hasSkill(self.name) and data.card.type ~= Card.TypeEquip
    and data.card.name ~= "peach" and data.card.name ~= "jink"
  end,
  on_use = function(self, event, target, player, data)
    data.disresponsiveList = data.disresponsiveList or {}
    for _, p in ipairs(player.room.alive_players) do
      table.insertIfNeed(data.disresponsiveList, p)
    end
  end,
})

return qiangfeng
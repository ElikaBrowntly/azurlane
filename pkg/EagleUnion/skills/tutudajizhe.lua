local tutudajizhe = fk.CreateSkill{
  name = "yyfy_tutudajizhe",
}

-- 回合开始时印杀
tutudajizhe:addEffect(fk.TurnStart, {
  can_trigger = function(self, event, target, player, data)
    return player and player:getMark("@@yyfy_tutudajizhe") > 0
    and #player.room:getAlivePlayers() > 1
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    return room:askToSkillInvoke(player, {
      skill_name = "yyfy_tutudajizhe",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, "yyfy_tutudajizhe", "offensive")
    player:broadcastSkillInvoke("yyfy_zhanyijizeng", 1)
    
    -- 创建一张虚拟的杀
    local slash = Fk:cloneCard("slash")
    slash.skillName = "yyfy_tutudajizhe"
    
    -- 设置额外数据：无距离和次数限制
    local use = {
      from = player,
      card = slash,
      extraUse = true,  -- 不计入次数
      extra_data = {
        bypass_times = true,
        bypass_distances = true,
      },
    }
    
    -- 选择目标
    local targets = room:askToChoosePlayers(player, {
      targets = room:getOtherPlayers(player),
      min_num = 1,
      max_num = 1,
      prompt = "#yyfy_tutudajizhe-target",
      skill_name = "yyfy_tutudajizhe"}
    )
    
    if #targets > 0 then
      use.tos = {}
      table.insert(use.tos, targets[1])
      room:useCard(use)
    end
  end,
})

-- 印的杀造成伤害-1，本来用不到fk.DetermineDamageCaused时机，但设计者意图让此效果晚于战意激增触发
-- 战意激增是造成伤害时fk.DamageCaused，所以这里用了造成伤害时②即fk.DetermineDamageCaused
tutudajizhe:addEffect(fk.DetermineDamageCaused, {
  can_trigger = function(self, event, target, player, data)
    return player:isAlive() and player:hasSkill(self.name)
    and data.from == player and data.card and data.card.skillName == "yyfy_tutudajizhe"
  end,
  on_cost = function ()
    return true
  end,
  on_use = function (self, event, target, player, data)
    data.damage = math.max(1, data.damage - 1)
    player.room:sendLog{
      type = "由于兔兔打击者的效果，此杀造成的伤害-1，最低为1。",
    }
  end
})

return tutudajizhe
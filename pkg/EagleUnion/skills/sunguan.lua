local sunguan_skill = fk.CreateSkill{
  name = "yyfy_sunguan",
}

-- 先写一个比较早的时机，因为后面的时机fk.Death还没来得及复活主公，游戏就已经结束了
-- 但是这个时机没办法复活减体力上限的死法和神关羽武魂秒杀死法，所以需要后面的Death时机
sunguan_skill:addEffect(fk.AskForPeachesDone, {
  can_trigger = function(self, event, target, player, data)
    return target == player and
           player:getMark("@@yyfy_sunguan") > 0 and
           data.who == player and
           player.hp <= 0
  end,
  on_cost = function(self, event, target, player, data)
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    room:notifySkillInvoked(player, "yyfy_sunguan", "support")
    player:broadcastSkillInvoke("yyfy_zhanyijizeng", 2)
    
    -- 复活，目前无法复活秒杀和扣上限
    room:revivePlayer(player, true)
    if player.maxHp <= 0 then
      room:changeMaxHp(player, 2 - player.maxHp) -- 若体力上限在0以下，则回到2
    end
    room:setPlayerMark(player, "@yyfy_AL_zhanyi", 0)  -- 清除战意标记
    room:setPlayerMark(player, "@yyfy_beishuizhizhan", 0)  -- 背水之战次数清零
    
    -- 移除白鹰精英损管标记
    room:setPlayerMark(player, "@@yyfy_sunguan", 0)
    if player:hasSkill("yyfy_sunguan") then
      room:handleAddLoseSkills(player, "-yyfy_sunguan", self.name)
    end
    -- 恢复体力到2点
    room:recover({
      who = player,
      num = 2 - player.hp,
      skillName = "yyfy_sunguan",
    })
    
    -- 发送日志
    room:sendLog{
      type = "#yyfy_sunguan_trigger",
      from = player.id,
      arg = "yyfy_sunguan",
    }
  end,
})

-- 其他复活
sunguan_skill:addEffect(fk.Death, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@yyfy_sunguan") > 0 and data.who == player
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    room:notifySkillInvoked(player, "yyfy_sunguan", "support")
    player:broadcastSkillInvoke("yyfy_zhanyijizeng", 2)
    
    -- 复活，目前无法复活神关羽武魂秒杀
    room:revivePlayer(player, true)
    if player.maxHp <= 0 then
      room:changeMaxHp(player, 2 - player.maxHp) -- 若体力上限在0以下，则回到2
    end
    room:setPlayerMark(player, "@yyfy_AL_zhanyi", 0)  -- 清除战意标记
    room:setPlayerMark(player, "@yyfy_beishuizhizhan", 0)  -- 背水之战次数清零
    
    -- 移除白鹰精英损管标记
    room:setPlayerMark(player, "@@yyfy_sunguan", 0)
    if player:hasSkill("yyfy_sunguan") then
      room:handleAddLoseSkills(player, "-yyfy_sunguan", self.name)
    end
    -- 恢复体力到2点
    room:recover({
      who = player,
      num = 2 - player.hp,
      skillName = "yyfy_sunguan",
    })
    
    -- 发送日志
    room:sendLog{
      type = "#yyfy_sunguan_trigger",
      from = player.id,
      arg = "yyfy_sunguan",
    }
  end,
})

return sunguan_skill
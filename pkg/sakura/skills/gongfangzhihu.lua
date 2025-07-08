local skill = fk.CreateSkill{
  name = "gongfangzhihu",
  events = {fk.DamageInflicted, fk.EventPhaseStart, fk.DamageFinished},
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  global = false
}

Fk:loadTranslationTable{
  ["gongfangzhihu"] = "公方之护",
  [":gongfangzhihu"] = "锁定技，若你不处于一号位，或有一半的角色位于你的攻击范围内，"..
  "你受到的伤害减半（向下取整）;你每以此法防止2次伤害，则失去1点体力。"..
  "每局限两次，其他角色的回合开始时，若其确定与你阵营相同，你可以召唤3道落雷",
  
  ["#gongfangzhihu-ask"] = "公方之护：是否召唤3道落雷？",
  ["#gongfangzhihu-choose"] = "公方之护：请选择第 %arg 道落雷的目标",
  ["#gongfangzhihu-reduce"] = "「公方之护」效果触发，%from 受到的伤害从 %arg 点减至 %arg2 点",
  ["#gongfangzhihu-prevent"] = "「公方之护」效果触发，%from 防止了 %arg 点伤害",
  ["#gongfangzhihu-losehp"] = "「公方之护」效果触发，%from 因防止了2次伤害而失去体力",
  
  ["$gongfangzhihu1"] = "可不能被胜利冲昏了头脑……",
  ["$gongfangzhihu2"] = "你只要安心享受胜利的喜悦就好，呵呵~",
}

skill:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and not player.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local canReduce = false
    local seatCount = #room:getAlivePlayers()
    
    if player.seat ~= 1 then
      canReduce = true
    else
      local attackRange = player:getAttackRange()
      local inRangeCount = 0
      
      for _, p in ipairs(room:getAlivePlayers()) do
        if player:distanceTo(p) <= attackRange then
          inRangeCount = inRangeCount + 1
        end
      end
      
      if inRangeCount >= math.ceil(seatCount / 2) then
        canReduce = true
      end
    end
    
    if not canReduce then return false end
    
    local reducedDamage = math.floor(data.damage / 2)
    
    if reducedDamage <= 0 then
      room:sendLog{
        type = "#gongfangzhihu-prevent",
        from = player.id,
        arg = data.damage,
        arg2 = self.name
      }
      
      player:addMark("gongfangzhihu_prevent_count", 1)
      data.damage = 0
      return true
    end
    
    room:sendLog{
      type = "#gongfangzhihu-reduce",
      from = player.id,
      arg = data.damage,
      arg2 = reducedDamage,
      arg3 = self.name
    }
    data.damage = reducedDamage
  end,
})

-- 防止伤害后失去体力
skill:addEffect(fk.DamageFinished, {
  can_trigger = function(self, event, target, player, data)
    return data.to == player and player:hasSkill(self.name) and not player.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local preventCount = player:getMark("gongfangzhihu_prevent_count")
    
    if preventCount >= 2 then
      room:sendLog{
        type = "#gongfangzhihu-losehp",
        from = player.id,
        arg = preventCount,
        arg2 = self.name
      }
      
      room:loseHp(player, math.floor(preventCount / 2))
      player:setMark("gongfangzhihu_prevent_count", preventCount % 2)
    end
  end,
})

-- 召唤3道落雷
skill:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    if target == player then return false end  -- 自己的回合不触发
    if player:getMark("gongfangzhihu_used_global") >= 2 then return false end  -- 每局限两次
    if not player:hasSkill(self.name) or player.dead then return false end  -- 确保玩家拥有技能且存活
    
    -- 检查游戏模式
    local room = player.room
    if not (room:isGameMode("1v2_mode") or room:isGameMode("2v2_mode")) then
      return false
    end
    
    local sameCamp = (player.role == target.role)
    return sameCamp
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    return room:askToSkillInvoke(player, { 
      skill_name = self.name,
      target = target, 
      prompt = "#gongfangzhihu-ask::"..target.general
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    player:addMark("gongfangzhihu_used_global", 1)
    local soundIndex = math.random(1, 2)
    player:broadcastSkillInvoke(self.name, soundIndex)
    
    for i = 1, 3 do
      local available = room:getOtherPlayers(player, true)
      if #available == 0 then break end

      local target_list = room:askToChoosePlayers(player, {
        targets=available, 
        min_num=1, 
        max_num=1, 
        prompt="#gongfangzhihu-choose",
        skill_name=self.name,
        cancelable=true,
        { arg = tostring(i) },
      })
      
      if #target_list == 0 then break end
      local t = target_list[1]
      
      -- 50%概率暴击
      local damage = 1
      if math.random() < 0.5 then
        damage = 2
      end
      
      room:damage{
        from = player,
        to = t,
        damage = damage,
        damageType = fk.ThunderDamage,
        skillName = self.name,
      }
    end
  end,
})

return skill
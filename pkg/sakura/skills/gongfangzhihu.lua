local skill = fk.CreateSkill{
  name = "gongfangzhihu",
  events = {fk.DamageInflicted, fk.EventPhaseStart, fk.DamageFinished, fk.GameStart, fk.Death},
  anim_type = "defensive",
  frequency = Skill.Compulsory,
}

Fk:loadTranslationTable{
  ["gongfangzhihu"] = "公方之护",
  [":gongfangzhihu"] = "锁定技，若你不处于一号位，或有一半的角色位于你的攻击范围内，"..
  "你受到的伤害减半（向下取整）；你未以此法受到伤害每有2次，则失去1点体力。"..
  "游戏开始时，你可以选择至多两名其他角色，这些角色受到伤害时，你可代为承受。"..
  "每局游戏限2次，友方角色的回合开始时，你可以召唤3道落雷" ,
  
  ["@@gongfangzhihu_protected"] = "公方之护",
  ["#gongfangzhihu-ask"] = "公方之护：是否召唤3道落雷？",
  ["#gongfangzhihu-choose"] = "公方之护：请选择本次落雷的目标",
  ["#gongfangzhihu-reduce"] = "「公方之护」效果触发，%from 受到的伤害从 %arg 点减至 %arg2 点",
  ["#gongfangzhihu-prevent"] = "「公方之护」效果触发，%from 防止了 %arg 点伤害",
  ["#gongfangzhihu-losehp"] = "「公方之护」效果触发，%from 因防止了2次伤害而失去体力",
  ["#gongfangzhihu-protect-ask"] = "公方之护：请选择至多两名其他角色组成舰队",
  ["#gongfangzhihu-protect-trigger"] = "公方之护：是否要代为承受伤害？",
  ["#gongfangzhihu-protect"] = "%from 发动「公方之护」，为 %to 承受伤害",
  
  ["$gongfangzhihu1"] = "可不能被胜利冲昏了头脑……",
  ["$gongfangzhihu2"] = "你只要安心享受胜利的喜悦就好，呵呵~",
}

-- 游戏开始时
skill:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local available = room:getOtherPlayers(player, true)
    
    if #available == 0 then return end
    
    local target_list = room:askToChoosePlayers(player, {
      targets = available,
      min_num = 0,
      max_num = 2,
      prompt = "#gongfangzhihu-protect-ask",
      skill_name = self.name,
      cancelable = true
    })
    
    if #target_list > 0 then
      local protect_ids = {}
      for _, p in ipairs(target_list) do
        table.insert(protect_ids, p.id)
        p.room:addPlayerMark(p,"@@gongfangzhihu_protected",1)
      end
      room:setTag("gongfangzhihu_protect_"..player.id, protect_ids)
    end
  end,
})

-- 死亡时清除
skill:addEffect(fk.Death, {
  on_cost = function(self, event, target, player, data)
    return data.who:hasSkill(skill.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local protect_ids = room:getTag("gongfangzhihu_protect_"..player.id) or {}
    
    for _, id in ipairs(protect_ids) do
      local p = room:getPlayerById(id)
      if p then
        p.room:removePlayerMark(p,"@@gongfangzhihu_protected")
      end
    end
    
    room:removeTag("gongfangzhihu_protect_"..player.id)
  end,
})

-- 转移伤害
skill:addEffect(fk.DamageInflicted, {
  global = true,
  can_trigger = function(self, event, target, player, data)
    if target == player then return false end
    
    local room = player.room
    local protect_ids = room:getTag("gongfangzhihu_protect_"..player.id) or {}
    
    local protected = false
    for _, id in ipairs(protect_ids) do
      if id == target.id then
        protected = true
        break
      end
    end
    
    return protected and player:hasSkill(self.name) and not player.dead
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    return room:askToSkillInvoke(player, {
      skill_name = self.name,
      target = target,
      prompt = "#gongfangzhihu-protect-trigger::"..target.id
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    room:sendLog{
      type = "#gongfangzhihu-protect",
      from = player.id,
      to = {target.id},
      arg = self.name
    }

    data.to = player
  end,
})
--减伤
skill:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return data.to == player and data.to:hasSkill(self.name) and not player.dead
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
      
      player.room:addPlayerMark(player,"gongfangzhihu_prevent_count", 1)
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
  on_cost = function(self, event, target, player, data)
    return data.to == player and player:hasSkill(self.name) and not player.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local preventCount = player:getMark("gongfangzhihu_prevent_count")
    
    if preventCount >= 2 and preventCount % 2 == 0 then
      room:sendLog{
        type = "#gongfangzhihu-losehp",
        from = player.id,
        arg = preventCount,
        arg2 = self.name
      }
      
      room:loseHp(player, 1)
    end
  end,
})

-- 召唤3道落雷
skill:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    if target == player then return false end
    if player:getMark("gongfangzhihu_used_global") >= 2 then return false end
    if not player:hasSkill(self.name) or player.dead then return false end
    
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
    
    player.room:addPlayerMark(player,"gongfangzhihu_used_global", 1)
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
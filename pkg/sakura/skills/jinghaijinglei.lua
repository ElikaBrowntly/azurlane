local skill = fk.CreateSkill{
  name = "jinghaijinglei",
  events = {fk.TargetSpecified, fk.CardEffectFinished, fk.DamageInflicted, fk.EventPhaseEnd},
  anim_type = "offensive",
  frequency = Skill.Limited,
  limit_mark = "@jinghaijinglei_used-turn",
  global = true,
}

Fk:loadTranslationTable{
  ["jinghaijinglei"] = "静海惊雷",
  [":jinghaijinglei"] = "每回合限一次，你使用【杀】指定目标后，可召唤7道落雷"..
  "（每道落雷可对一名其他角色造成1点雷电伤害，有50%概率暴击）；"..
  "结算完成后，你可令被落雷击中的角色本回合受到的伤害+1",
  
  ["#jinghaijinglei-ask"] = "静海惊雷：是否召唤7道落雷？",
  ["#jinghaijinglei-choose"] = "静海惊雷：请选择第 %arg 次伤害的目标",
  ["#jinghaijinglei-ask2"] = "静海惊雷：是否令落雷击中角色本回合受伤+1？",
  ["#jinghaijinglei-add"] = "由于「静海惊雷」的效果，%from 受到的伤害+%arg2",

  ["$jinghaijinglei1"] = "时机已至！",
  ["$jinghaijinglei2"] = "分段射击，御敌绸缪。",
}

skill:addEffect(fk.TargetSpecified, {
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(self.name) and 
           data.card.trueName == "slash" 
           --and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name=self.name,
      target=target,
      prompt="#jinghaijinglei-ask"})
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    local index = math.random(1, 2)
    player:broadcastSkillInvoke(self.name, index)
    
    player:setMark("jinghaijinglei_card_id", data.card.id)
    local damaged = {}
    
    for i = 1, 7 do
      local available = room:getOtherPlayers(player, true)
      if #available == 0 then break end

      local target_list = room:askToChoosePlayers(player, {
        targets=available,
        min_num=1,
        max_num=1, 
        prompt="#jinghaijinglei-choose",
        skill_name=self.name,
        cancelable=true,
        { arg = tostring(i) }
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
      
      if not table.contains(damaged, t.id) then
        table.insert(damaged, t.id)
      end
    end
    
    if #damaged > 0 then
      room:setTag("jinghaijinglei_damaged_"..player.id, damaged)
    end
    
    player:addMark("@jinghaijinglei_used-turn",1)
  end,
})

-- 易伤标记
skill:addEffect(fk.CardEffectFinished, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and 
           player:getMark("jinghaijinglei_card_id") == data.card.id
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local damaged = room:getTag("jinghaijinglei_damaged_"..player.id) or {}
    
    local aliveDamaged = {}
    for _, id in ipairs(damaged) do
      local p = room:getPlayerById(id)
      if p and not p.dead then
        table.insert(aliveDamaged, p)
      end
    end
    
    if #aliveDamaged == 0 then return false end
    
    return room:askToSkillInvoke(player, {
      skill_name=self.name,
      nil,
      "#jinghaijinglei-ask2"})
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local damaged = room:getTag("jinghaijinglei_damaged_"..player.id) or {}
    room:removeTag("jinghaijinglei_damaged_"..player.id)
    
    local debuffed = {}
    for _, id in ipairs(damaged) do
      local p = room:getPlayerById(id)
      if p and not p.dead then
        p:addMark("jinghaijinglei_debuff",1)
        table.insert(debuffed, p.id)
      end
    end
    
    room:setTag("jinghaijinglei_debuffed_"..player.id, debuffed)
  end,
})

-- 易伤
skill:addEffect(fk.DamageInflicted, {
  global = true,
  can_trigger = function(self, event, target, player, data)
    return target:getMark("jinghaijinglei_debuff") > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = target.room
    room:sendLog{
      type = "#jinghaijinglei-add",
      from = target.id,
      arg = self.name,
      arg2 = 1
    }
    data.damage = data.damage + 1
  end,
})

-- 清除标记
skill:addEffect(fk.EventPhaseEnd, {
  can_trigger = function(self, event, target, player, data)
    return target.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    local room = target.room
    
    target:removeMark("@jinghaijinglei_used-turn")
    target:removeMark("jinghaijinglei_card_id")
    
    local debuffed = room:getTag("jinghaijinglei_debuffed_"..target.id) or {}
    for _, id in ipairs(debuffed) do
      local p = room:getPlayerById(id)
      if p then
        p:removeMark("jinghaijinglei_debuff")
      end
    end
    room:removeTag("jinghaijinglei_debuffed_"..target.id)
  end,
})

return skill
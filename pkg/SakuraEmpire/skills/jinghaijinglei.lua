local skill = fk.CreateSkill{
  name = "jinghaijinglei",
  anim_type = "offensive",
  limit_mark = "@jinghaijinglei_used-turn",
}

Fk:loadTranslationTable{
  ["jinghaijinglei"] = "静海惊雷",
  [":jinghaijinglei"] = "每回合限一次，你使用【杀】指定目标后，可召唤7道"..
  "<a href = 'jinghaijinglei-luolei'>落雷</a>，然后你可令被落雷击中的角色本回合受到的伤害+1。",
  
  ["#jinghaijinglei-ask"] = "静海惊雷：是否召唤7道落雷？",
  ["#jinghaijinglei-choose"] = "静海惊雷：请选择本次落雷的目标",
  ["#jinghaijinglei-ask2"] = "静海惊雷：是否令落雷击中角色本回合受伤+1？",
  ["#jinghaijinglei-add"] = "由于「静海惊雷」的效果，%from 受到的伤害+%arg2",
  ["@@jinghaijinglei_debuff"] = "破甲",
  ["jinghaijinglei-luolei"] = "每道落雷可对一名其他角色造成1点雷电伤害，有50%概率暴击。",

  ["$jinghaijinglei1"] = "时机已至！",
  ["$jinghaijinglei2"] = "分段射击，御敌绸缪。",
}

skill:addEffect(fk.TargetSpecified, {
  on_cost = function(self, event, target, player, data)
    if (player and data.from:hasSkill(self.name) and 
           data.card.trueName == "slash"
           and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0) then
      return player.room:askToSkillInvoke(player, {
        skill_name=self.name,
        target=target,
        prompt="#jinghaijinglei-ask"})
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    local index = math.random(1, 2)
    player:broadcastSkillInvoke(self.name, index)
    
    local damagedIds = {}
    
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

      if not table.contains(damagedIds, t.id) then
        table.insert(damagedIds, t.id)
      end
    end
    
    player.room:addPlayerMark(player,"jinghaijinglei_used-turn",1)
    
    if #damagedIds > 0 then

      if room:askToSkillInvoke(player, {
        skill_name=self.name,
        prompt="#jinghaijinglei-ask2"}) then
        
        for _, id in ipairs(damagedIds) do
          local p = room:getPlayerById(id)
          if p and not p.dead then
            p.room:addPlayerMark(p,"@@jinghaijinglei_debuff",1)
          end
        end
      end
    end
  end,
})

-- 易伤
skill:addEffect(fk.DamageInflicted, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return data.to:getMark("@@jinghaijinglei_debuff") > 0 and player:hasSkill(skill.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = target.room
    room:sendLog{
      type = "#jinghaijinglei-add",
      from = target.id,
      arg = self.name,
      arg2 = 1
    }
    data:changeDamage(1)
  end,
})

-- 清除标记
skill:addEffect(fk.EventPhaseEnd, {
  mute = true,
  on_cost = function(self, event, target, player, data)
    if target.phase ~= Player.Finish then return false end
    for _, p in ipairs(target.room:getAlivePlayers()) do
      if p:getMark("@@jinghaijinglei_debuff") > 0 then
        return true
      end
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = target.room

    if target:getMark("@jinghaijinglei_used-turn") > 0 then
      target.room:removePlayerMark(target,"@jinghaijinglei_used-turn",1)
    end

    for _, p in ipairs(room:getAlivePlayers()) do
      if p:getMark("@@jinghaijinglei_debuff") > 0 then
        p.room:removePlayerMark(p,"@@jinghaijinglei_debuff", 1)
      end
    end
  end,
})

return skill
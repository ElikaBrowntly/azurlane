local skill = fk.CreateSkill{
  name = "wuyingrenhao",
  tags = {Skill.Compulsory},
}

Fk:loadTranslationTable({
  ["wuyingrenhao"] = "舞樱刃豪",
  [":wuyingrenhao"] = "锁定技，你对其他角色造成伤害时，若大于1点，则你可令该伤害+1。"..
  "若你装备了武器牌，你的【杀】不可被响应，出牌阶段可使用杀的次数+1。",
  
  ["$wuyingrenhao"] = "我就在这里，无需怯战，不要冒进，出击吧——",
  ["#wuyingrenhao-ask"] = "舞樱刃豪：是否令此伤害+1？",
  ["#WuyingrenhaoDamage"] = "%from 的「%arg」效果触发，对 %to 的伤害由 %arg2 点增加至 %arg3 点",
  ["#WuyingrenhaoUnresponse"] = "%from 的「%arg」效果触发，%to 不可响应此【杀】",
})

---@class DamageData
---@field wuyingrenhao_triggered boolean

--多刀
skill:addEffect("targetmod", {
  times = function(self, player, skillObj, scope, card)
    if player:getEquipment(Player.WeaponSlot) and
       scope == Player.HistoryPhase and 
       skillObj.trueName == "slash_skill" 
       and player:hasSkill(skill.name) then
      return 1
    end
  end,
})

-- 强中
skill:addEffect(fk.CardUsing, {
  mute = true,
  on_cost = function(self, event, target, player, data)
    return player:hasSkill(skill.name) and 
           player:getEquipment(Card.SubtypeWeapon) and
           data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    data.disresponsiveList = data.disresponsiveList or {}
    for _, p in ipairs(player.room.alive_players) do
      table.insert(data.disresponsiveList, p)
    end

    player.room:sendLog{
      type = "#WuyingrenhaoUnresponse",
      from = player.id,
      arg = self.name,
    }
  end,
})

-- 加伤
skill:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
    return data.from and data.from == player and player:hasSkill(skill.name) and
           data.to and data.to ~= player and
           data.damage > 1 and
           not data.wuyingrenhao_triggered
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    return room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "#wuyingrenhao-ask:::"..data.to.id
    })
  end,
  on_use = function(self, event, target, player, data)

    data.wuyingrenhao_triggered = true
    
    data.damage = data.damage + 1
    
    player.room:notifySkillInvoked(player, self.name)
    player:broadcastSkillInvoke(self.name)
    
    player.room:sendLog{
      type = "#WuyingrenhaoDamage",
      from = player.id,
      to = {data.to.id},
      arg = self.name,
      arg2 = data.damage - 1,
      arg3 = data.damage,
    }
  end,
})

return skill
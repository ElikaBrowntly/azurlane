local yyfy_zhiti = fk.CreateSkill{
  name = "yyfy_zhiti",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["yyfy_zhiti"] = "止啼",
  [":yyfy_zhiti"] = "锁定技，若场上已受伤的角色数不小于：1，你使用装备牌时摸一张牌；2，你拥有技能〖忘隙〗；3，你跳过弃牌阶段；"..
  "4，出牌阶段限一次，你可以令一名角色增加1点体力上限并恢复所有装备栏；5，结束阶段，你可以废除一名其他角色一个指定的装备栏。",

  ["#yyfy_zhiti-choose"] = "止啼：你可以废除一名其他角色的一个装备栏",
  ["#yyfy_zhiti-recover"] = "止啼：选择一名角色，增加其体力上限并恢复所有装备栏",
  ["@yyfy_zhiti-recover"] = "止啼",

  ["$yyfy_zhiti1"] = "江东小儿，安敢啼哭？",
  ["$yyfy_zhiti2"] = "娃闻名止啼，孙损十万休。",
}

-- 获取场上受伤角色数
local function getWoundedCount(room)
  return #table.filter(room.alive_players, function(p) return p:isWounded() end)
end

-- 1. 使用装备牌时摸一张牌
yyfy_zhiti:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yyfy_zhiti.name) and 
      data.card.type == Card.TypeEquip and
      getWoundedCount(player.room) >= 1
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, yyfy_zhiti.name)
  end,
})

-- 2. 拥有技能"忘隙"
local wangxiRefresh = {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(yyfy_zhiti.name) and
      ((player:hasSkill("ty__wangxi", true) and getWoundedCount(player.room) < 2) or
      (not player:hasSkill("ty__wangxi", true) and getWoundedCount(player.room) >= 2 ))
  end,
  on_refresh = function(self, event, target, player, data)
    if player:hasSkill("ty__wangxi", true) then
      player.room:handleAddLoseSkills(player, "-ty__wangxi")
    else
      player.room:handleAddLoseSkills(player, "ty__wangxi")
    end
  end,
}

yyfy_zhiti:addEffect(fk.HpChanged, wangxiRefresh)
yyfy_zhiti:addEffect(fk.MaxHpChanged, wangxiRefresh)
yyfy_zhiti:addEffect(fk.Death, wangxiRefresh)

-- 3. 跳过弃牌阶段
yyfy_zhiti:addEffect(fk.EventPhaseChanging, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yyfy_zhiti.name) and 
      data.phase == Player.Discard and
      getWoundedCount(player.room) >= 3 and
      not data.skipped
  end,
  on_use = function(self, event, target, player, data)
    data.skipped = true
  end,
})

-- 4. 恢复体力上限和区域
yyfy_zhiti:addEffect("active", {
  anim_type = "support",
  prompt = "#yyfy_zhiti-recover",
  card_num = 0,
  min_target_num = 1,
  max_target_num = 1,
  max_phase_use_time = 1,
  on_cost = function(self, player)
    return player:hasSkill(yyfy_zhiti.name) and 
      getWoundedCount(player.room) >= 4 and
      player.phase == Player.Play
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    
    room:changeMaxHp(target, 1)
    
    if #target.sealedSlots > 0 then
      room:resumePlayerArea(target, target.sealedSlots)
    end
  end,
})

-- 5. 废除指定装备栏
yyfy_zhiti:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yyfy_zhiti.name) and 
      player.phase == Player.Finish and
      getWoundedCount(player.room) >= 5
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p)
      return p ~= player and #p:getAvailableEquipSlots() > 0
    end)
    
    if #targets == 0 then return false end
    
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = yyfy_zhiti.name,
      prompt = "#yyfy_zhiti-choose",
      cancelable = true,
    })
    
    if #to > 0 then
      local targetPlayer = to[1]
      local availableSlots = targetPlayer:getAvailableEquipSlots()
      
      if #availableSlots > 0 then
        local choices = {}
        for _, slot in ipairs(availableSlots) do
          table.insert(choices, tostring(slot))
        end
        
        local slotChoice = room:askToChoice(player, {
            choices = choices,
            skill_name = yyfy_zhiti.name,
            "@yyfy_zhiti-choose"})
        event:setCostData(self, {
          target = targetPlayer,
          slot = slotChoice
        })
        return true
      end
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local costData = event:getCostData(self)
    local targetPlayer = costData.target
    room:abortPlayerArea(targetPlayer, {costData.slot})
  end,
})

return yyfy_zhiti
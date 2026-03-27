local yyfy_zhiti = fk.CreateSkill{
  name = "yyfy_zhiti",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["yyfy_zhiti"] = "止啼",
  [":yyfy_zhiti"] = "锁定技，若场上已受伤的角色数不小于：1，你使用装备牌时摸一张牌；2，你拥有技能"..
  "〖<a href = 'yyfy_zhiti-wangxi'>忘隙</a>〗；3，你跳过弃牌阶段；4，出牌阶段限一次，"..
  "你可以令一名角色增加1点体力上限并恢复所有装备栏；5，结束阶段，你可以废除一名其他角色一个指定的装备栏。",

  ["yyfy_zhiti-wangxi"] = "<br>游戏开始时，可以自选本局游戏要获得标·忘隙还是界·忘隙<br><br>"..
  "<b>标·忘隙:</b>  操作简便，适合pve<br><b>界·忘隙:</b>  效果强力，适合pvp",

  ["#yyfy_zhiti-choose"] = "止啼：你可以废除一名其他角色的一个装备栏",
  ["#yyfy_zhiti-recover"] = "止啼：选择一名角色，增加其体力上限并恢复所有装备栏",
  ["@yyfy_zhiti-recover"] = "止啼",

  ["$yyfy_zhiti1"] = "江东小儿，安敢啼哭？",
  ["$yyfy_zhiti2"] = "娃闻名止啼，孙损十万休。"
}

-- 获取场上受伤角色数
local function getWoundedCount(room)
  return #table.filter(room.alive_players, function(p) return p:isWounded() end)
end

yyfy_zhiti:addEffect(fk.GameStart, {
  can_refresh = function (self, event, target, player, data)
    return player and player:hasSkill(self)
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    if room:askToChoice(player, {
      choices = {"界·忘隙（效果强力，适合pvp）", "标·忘隙（操作简单，适合pve）"},
      cancelable = false,
      skill_name = yyfy_zhiti.name,
      prompt = "止啼：请选择本局游戏要获得的〖忘隙〗版本"
    }) == "标·忘隙（操作简单，适合pve）" then
      room:setPlayerMark(player, "yyfy_zhiti-wangxi", 1)
    end
  end
})

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
      ((player:hasSkill("yyfy_wangxi", true) and getWoundedCount(player.room) < 2) or
      (not player:hasSkill("yyfy_wangxi", true) and getWoundedCount(player.room) >= 2 ))
  end,
  on_refresh = function(self, event, target, player, data)
    local wangxi = "yyfy_wangxi"
    if player:getMark("yyfy_zhiti-wangxi") == 1 and Fk.skills["wangxi"] then
      wangxi = "wangxi"
    end
    if player:hasSkill("yyfy_wangxi", true) then
      player.room:handleAddLoseSkills(player, "-"..wangxi)
    else
      player.room:handleAddLoseSkills(player, wangxi)
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
  can_use = function(self, player)
    return player:hasSkill(yyfy_zhiti.name) and 
      getWoundedCount(Fk:currentRoom()) >= 4 and
      player.phase == Player.Play
      and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
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
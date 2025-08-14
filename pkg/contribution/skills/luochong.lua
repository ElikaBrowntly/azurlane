local luochong = fk.CreateSkill{
  name = "lan__luochong",
}

Fk:loadTranslationTable{
  ["lan__luochong"] = "落宠",
  [":lan__luochong"] = "每轮开始时、准备阶段或当你受到伤害后，你可以任意顺序执行："
    .. "<br>\n<font color='green'>①令一名角色回复1点体力</font>；"
    .. "<br>\n<font color='red'>②令一名角色失去1点体力</font>；"
    .. "<br>\n<font color='purple'>③令一名角色摸两张牌</font>；"
    .. "<br>\n<font color='blue'>④重复此流程至多4次：弃置一名角色的一张牌</font>。",

  ["#lan__luochong-invoke"] = "落宠：选择一项并指定目标",
  ["#lan__luochong-discard"] = "落宠：请选择要弃置的角色（还可弃置 %arg 次）",
  ["#lan__luochong-discard-card"] = "落宠：请选择要弃置的牌",
  ["Cancel"] = "结束",
  
  ["lan__luochong1"] = "回复1点体力",
  ["lan__luochong2"] = "失去1点体力",
  ["lan__luochong3"] = "摸2张牌",
  ["lan__luochong4"] = "弃置1张牌",
  
  ["$lan__luochong1"] = "宠至莫言非，恩移难恃貌。",
  ["$lan__luochong2"] = "君王一时情，安有恩长久。",
  ["$lan__luochong3"] = "陛下独宠他人，奈何雨露不均？",
  ["$lan__luochong4"] = "妾贵于佳丽，然宠不及三千。",
  ["$lan__luochong5"] = "琴筝夜久殷勤弄，心怯空房不忍归。",
  ["$lan__luochong6"] = "西宫夜静百花香，欲卷珠帘春恨长。"
}

local function triggerLuochong(player, event)
  local room = player.room
  local usedOptions = {}
  local allPlayers = room.alive_players
  
  local all_choices = {
    Fk:translate("lan__luochong1"),
    Fk:translate("lan__luochong2"),
    Fk:translate("lan__luochong3"),
    Fk:translate("lan__luochong4"),
    Fk:translate("Cancel")
  }
  
  -- 主循环
  while true do

    local choices = {}
    for i, text in ipairs(all_choices) do
      if i < 5 then
        if not table.contains(usedOptions, i) then
          table.insert(choices, text)
        end
      else
        table.insert(choices, text)
      end
    end
    
    -- 询问选择
    local choiceText = room:askToChoice(player, {
      choices = choices,
      all_choices = all_choices,
      skill_name = luochong.name,
      prompt = "#lan__luochong-invoke",
      cancelable = true
    })
    
    if choiceText == Fk:translate("Cancel") then
      break
    end
    
    local choice
    if choiceText == Fk:translate("lan__luochong1") then
      choice = 1
    elseif choiceText == Fk:translate("lan__luochong2") then
      choice = 2
    elseif choiceText == Fk:translate("lan__luochong3") then
      choice = 3
    elseif choiceText == Fk:translate("lan__luochong4") then
      choice = 4
    else
      break
    end
    
    table.insert(usedOptions, choice)
    
    -- 选项1-3
    if choice <= 3 then
      local validTargets = table.filter(allPlayers, function(p)
        if choice == 1 then
          return p:isWounded()
        else
          return true
        end
      end)
      
      if #validTargets == 0 then
        room:sendlog("没有有效目标")
        table.remove(usedOptions)
        goto continue
      end
      
      -- 选择目标
      local target = room:askToChoosePlayers(player, {
        targets = validTargets,
        min_num = 1,
        max_num = 1,
        prompt = "#lan__luochong-invoke",
        skill_name = luochong.name
      })
      if #target == 0 then
        table.remove(usedOptions)
        goto continue
      end
      target = target[1]
      
      -- 执行效果
      if choice == 1 then
        player:broadcastSkillInvoke(luochong.name, 2)
        room:recover{
          who = target,
          num = 1,
          recoverBy = player,
          skillName = luochong.name,
        }
      elseif choice == 2 then
        player:broadcastSkillInvoke(luochong.name, math.random(5,6))
        room:loseHp(target, 1, luochong.name)
      elseif choice == 3 then
        player:broadcastSkillInvoke(luochong.name, 1)
        target:drawCards(2, luochong.name)
      end
    
    -- 选项4
    elseif choice == 4 then
      local discardCount = 0
      local maxDiscards = 4
      player:broadcastSkillInvoke(luochong.name, math.random(3,4))
      
      for _ = 1, maxDiscards do
        local discardTargets = table.filter(allPlayers, function(p)
          return not p:isAllNude()
        end)
        
        if #discardTargets == 0 then break end
        
        local prompt = "#lan__luochong-discard:::" .. (maxDiscards - discardCount)

        local target = room:askToChoosePlayers(player, {
        targets = discardTargets,
        min_num = 1,
        max_num = 1,
        prompt = prompt,
        skill_name = luochong.name
      })
        if #target == 0 then break end
        target = target[1]
        
        local cardIds = table.filter(target:getCardIds("hej"), function(id)
          return not target:prohibitDiscard(id)
        end)
        
        if #cardIds == 0 then
          room:sendMessage(target.general .. "没有可弃置的牌")
          goto discard_continue
        end
        
        local discardCard = room:askForCardChosen(player, target, "hej", luochong.name, false, "#lan__luochong-discard-card")
        if discardCard < 0 then break end

        room:throwCard({discardCard}, luochong.name, target, player)
        discardCount = discardCount + 1
        
        ::discard_continue::
      end
    end
    
    ::continue::
    
    -- 检查是否还有可用选项
    if #choices <= 1 then
      break
    end
  end
end

-- 准备阶段
luochong:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and 
           player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    triggerLuochong(player, event)
  end,
})

-- 卖血
luochong:addEffect(fk.Damaged, {
  mute = true,
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_use = function(self, event, target, player, data)
    triggerLuochong(player, event)
  end,
})

-- 每轮开始时
luochong:addEffect(fk.RoundStart, {
  mute = true,
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name)
  end,
  on_use = function(self, event, target, player, data)
    triggerLuochong(player, event)
  end,
})

return luochong
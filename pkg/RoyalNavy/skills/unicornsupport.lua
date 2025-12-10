local support = fk.CreateSkill{
  name = "unicornsupport",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable({
  ["unicornsupport"] = "独角兽的应援",
  [":unicornsupport"] = "锁定技，游戏开始时，你获得1个「空袭」标记。每当你使用或打出一张【杀】后，你可以令任意名角色各回复1点体力，"..
  "然后你可令其中一个体力值最低的角色额外回复1点体力（若体力已满则增加等量护甲和手牌上限）。",
  
  ["#unicornsupport-choose"] = "独角兽的应援：请选择要回复体力的角色",
  ["#unicornsupport-choose-extra"] = "独角兽的应援：请选择要额外回复体力的角色",
  ["#UnicornSupportArmor"] = "%to 因体力已满，改为获得 %arg2 点护甲和手牌上限",
  ["$unicornsupport1"] = "后方支援就交给我吧…独角兽…会加油的…",
  ["$unicornsupport2"] = "独角兽……会努力的！",
})

local maxCardSkill = fk.CreateSkill{
  name = "unicornsupport_maxcard",
  status_skill = true, 
}

support:addEffect("maxcards", {
  correct_func = function(self, player)
    return player:getMark("unicorn_maxcard_bonus")
  end,
})

support:addEffect(fk.GameStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(support.name)
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@kongxi", 1)
  end,
})

local function applySupportEffect(room, player, targetPlayer, num, skillName)
  if targetPlayer:isAlive() then
    if targetPlayer.hp >= targetPlayer.maxHp then
      room:changeShield(targetPlayer, num)
      
      local currentBonus = targetPlayer:getMark("unicorn_maxcard_bonus") or 0
      room:setPlayerMark(targetPlayer, "unicorn_maxcard_bonus", currentBonus + num)
      
      room:sendLog{
        type = "#UnicornSupportArmor",
        from = player.id,
        to = {targetPlayer.id},
        arg = skillName,
        arg2 = num,
      }
      return "armor"
    else

      room:recover({
        who = targetPlayer,
        num = num,
        recoverBy = player,
        skillName = skillName,
      })
      return "recover"
    end
  end
  return nil
end

--使用杀
support:addEffect(fk.CardUsing, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and 
           data.card.trueName == "slash" and
           player:hasSkill(support.name)
  end,
  on_cost = function(self, event, target, player, data)
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local all_players = room:getAlivePlayers()
    
    local choices = room:askToChoosePlayers(player, {
      targets=all_players,
      min_num=0,
      max_num=#all_players, 
      prompt="#unicornsupport-choose",
      skill_name=support.name,
      cancelable=true})
    
    if #choices == 0 then
      return
    end
    
    local min_hp_players = {}
    local min_hp = 100
    local hp_values = {}
    for _, targetPlayer in ipairs(choices) do
      hp_values[targetPlayer] = targetPlayer.hp
    end
    
    for _, targetPlayer in ipairs(choices) do
      applySupportEffect(room, player, targetPlayer, 1, support.name)
    end

    for _, targetPlayer in ipairs(choices) do
      local hp = targetPlayer.hp
      if hp < min_hp then
        min_hp = hp
        min_hp_players = {targetPlayer}
      elseif hp == min_hp then
        table.insert(min_hp_players, targetPlayer)
      end
    end
    
    if #min_hp_players > 0 then
      local choice = room:askToChoosePlayers(player, {
        targets=min_hp_players,
        min_num=0,
        max_num=1, 
        prompt="#unicornsupport-choose-extra", 
        skill_name=support.name,
        cancelable=true}
      )
      
      if #choice > 0 then
        applySupportEffect(room, player, choice[1], 1, support.name)
      end
    end
  end,
})

--打出杀
support:addEffect(fk.CardResponding, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and 
           data.card.trueName == "slash" and
           player:hasSkill(support.name)
  end,
  on_cost = function(self, event, target, player, data)
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local all_players = room:getAlivePlayers()
    
    local choices = room:askToChoosePlayers(player,{ 
      targets=all_players,
      min_num=0,
      max_num=#all_players, 
      prompt="#unicornsupport-choose", 
      skill_name=support.name,
      cancelable=true})
    
    if #choices == 0 then
      return
    end
    
    local min_hp_players = {}
    local min_hp = 100
    local hp_values = {}
    for _, targetPlayer in ipairs(choices) do
      hp_values[targetPlayer] = targetPlayer.hp
    end
    
    for _, targetPlayer in ipairs(choices) do
      applySupportEffect(room, player, targetPlayer, 1, support.name)
    end
    
    for _, targetPlayer in ipairs(choices) do
        local hp = targetPlayer.hp
        if hp < min_hp then
            min_hp = hp
            min_hp_players = {targetPlayer} 
        elseif hp == min_hp then
            table.insert(min_hp_players, targetPlayer) 
        end
    end
    
    if #min_hp_players > 0 then
      local choice = room:askToChoosePlayers(player,{
        targets=min_hp_players, 
        min_num=0,
        max_num=1, 
        prompt="#unicornsupport-choose-extra",
        skill_name=support.name, 
        cancelable=true} )
      
      if #choice > 0 then
        applySupportEffect(room, player, choice[1], 1, support.name)
      end
    end
  end,
})

return support
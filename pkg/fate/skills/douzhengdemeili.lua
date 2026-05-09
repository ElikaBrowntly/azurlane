local yyfy_douzhengdemeili = fk.CreateSkill{
  name = "yyfy_douzhengdemeili",
  anim_type = "support",
}

Fk:loadTranslationTable{
  ["yyfy_douzhengdemeili"] = "斗争的魅力",
  [":yyfy_douzhengdemeili"] = "出牌阶段限一次，你可以选择任意名角色，这些角色造成的伤害+1"..
  "（处于「毅力」状态的角色额外+1）直到各自的下个结束阶段。",
  
  ["@!fate_attack_end"] = "斗争的魅力",
  
  ["#yyfy_douzhengdemeili-choose"] = "斗争的魅力：请选择任意名角色",
  ["#yyfy_douzhengdemeili_damage_boost"] = "%from 的「%arg」效果触发，伤害+%arg2",
  
  ["$yyfy_douzhengdemeili1"] = "祭祀吧。开启战士的时间吧。",
  ["$yyfy_douzhengdemeili2"] = "——不错，非常好。",
  ["$yyfy_douzhengdemeili3"] = "来吧！来吧！来吧！",
  ["$yyfy_douzhengdemeili4"] = "前往特特奥坎以北吧。"
}

-- 主动效果：选择角色加伤
yyfy_douzhengdemeili:addEffect("active", {
  anim_type = "support",
  prompt = "#yyfy_douzhengdemeili-choose",
  card_num = 0,
  max_phase_use_time = 1,
  target_filter = function(self, to_select, selected)
    return to_select:isAlive()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local targets = effect.tos
    
    -- 为每个目标添加伤害加成标记
    for _, target in ipairs(targets) do
      -- 有毅力标记的角色额外+1
      local boostValue = 1
      if target:getMark("@!fate_yili") > 0 then
        boostValue = 2
      end
      
      -- 设置伤害加成标记，标记值为加成数值
      room:setPlayerMark(target, "@!fate_attack_end", boostValue)
    end
  end,
})

-- 伤害加成效果
yyfy_douzhengdemeili:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target and target:getMark("@!fate_attack_end") > 0
    and player and player:hasSkill(self.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local boostValue = data.from:getMark("@!fate_attack_end") or 0
    
    if boostValue > 0 then
      -- 增加伤害
      data:changeDamage(boostValue)
      
      -- 发送日志
      room:sendLog{
        type = "#yyfy_douzhengdemeili_damage_boost",
        from = player.id,
        arg = "yyfy_douzhengdemeili",
        arg2 = tostring(boostValue),
      }
    end
  end,
})

-- 在目标的下个结束阶段清除标记
yyfy_douzhengdemeili:addEffect(fk.TurnEnd, {
  can_refresh = function(self, event, target, player, data)
    -- 检查当前回合结束的角色是否有伤害加成标记
    return target == player and 
           player:getMark("@!fate_attack_end") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@!fate_attack_end", 0)
  end,
})

-- 技能失去时清理标记
yyfy_douzhengdemeili:addLoseEffect(function(self, player, is_death)
  -- 只清理技能拥有者自身的标记，其他角色的标记继续存在直到他们自己的结束阶段
  local room = player.room
  if player:getMark("@!fate_attack_end") > 0 then
    room:setPlayerMark(player, "@!fate_attack_end", 0)
  end
end)

return yyfy_douzhengdemeili
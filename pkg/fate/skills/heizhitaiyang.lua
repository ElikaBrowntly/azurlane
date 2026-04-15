local yyfy_heizhitaiyang = fk.CreateSkill{
  name = "yyfy_heizhitaiyang",
  anim_type = "support",
}

Fk:loadTranslationTable{
  ["yyfy_heizhitaiyang"] = "黑之太阳",
  [":yyfy_heizhitaiyang"] = "出牌阶段限一次，你可以赋予任意名角色<a href=':fate_wudi_1*3'>无敌状态</a>"..
  "(1次·3回合)。然后，你获得5点蓄力点，这些角色中除你以外有蓄力技的角色各获得3点蓄力点。",

  ["#yyfy_heizhitaiyang-choose"] = "黑之太阳：请选择任意名角色",
  ["#yyfy_heizhitaiyang-charge"] = "黑之太阳：请选择任意名有蓄力技的其他角色，这些角色将各获得3点蓄力点",
  ["#yyfy_heizhitaiyang-shield"] = "由于「黑之太阳」的效果，%from 防止了受到的伤害",
  
  ["$yyfy_heizhitaiyang1"] = "太阳变得模糊了。",
  ["$yyfy_heizhitaiyang2"] = "这是毁灭世界之战。",
  ["$yyfy_heizhitaiyang3"] = "不要骄傲，不要欺瞒，一目了然……！",
  ["$yyfy_heizhitaiyang4"] = "是不是热过头了？",
}

local U = require "packages/utility/utility"

yyfy_heizhitaiyang:addEffect("active", {
  prompt = "#yyfy_heizhitaiyang-choose",
  card_num = 0,
  max_phase_use_time = 1,
  target_filter = function(self, to_select, selected)
    return to_select:isAlive()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local targets = effect.tos
    
    -- 赋予无敌状态：护盾标记和回合计数标记
    for _, target in ipairs(targets) do
      room:addPlayerMark(target, "@!fate_wudi", 1)
      room:setPlayerMark(target, "yyfy_heizhitaiyang_shield_turns", 3) -- 剩余3个回合
    end
    
    -- 自己获得5点蓄力点
    U.skillCharged(player, 5)

    local availableTargets = table.filter(targets, function(p)
      if p ~= player then
        local hasCharge = false
        
        -- 检查是否有蓄力技
        local hasChargeSkill = table.find(p:getSkillNameList(), function(s)
          return Fk.skills[s]:hasTag(Skill.Charge)
        end)
        
        if hasChargeSkill then hasCharge = true end
        
        return hasCharge
      end
      return false
    end)
    
    -- 获得3点蓄力点
    if #availableTargets > 0 then
        for _, p in ipairs(availableTargets) do
          U.skillCharged(p, 3)
      end
    end
  end,
})

-- 无敌效果
yyfy_heizhitaiyang:addEffect(fk.DetermineDamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return data.to:getMark("@!fate_wudi") > 0
    and player and player:hasSkill(self.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local t = data.to
    data:preventDamage()
    -- 防止伤害
    room:sendLog{
      type = "#yyfy_heizhitaiyang-shield",
      from = t.id,
    }
    
    -- 移除护盾
    room:setPlayerMark(t, "@!fate_wudi", 0)
    room:setPlayerMark(t, "yyfy_heizhitaiyang_shield_turns", 0)
    
    return true
  end,
})

-- 减少护盾剩余回合数
yyfy_heizhitaiyang:addEffect(fk.TurnEnd, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("yyfy_heizhitaiyang_shield_turns") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local remainingTurns = player:getMark("yyfy_heizhitaiyang_shield_turns") - 1
    
    if remainingTurns <= 0 then
      -- 回合数用完，移除护盾
      room:setPlayerMark(player, "@!fate_wudi", 0)
      room:setPlayerMark(player, "yyfy_heizhitaiyang_shield_turns", 0)
    else
      -- 更新剩余回合数
      room:setPlayerMark(player, "yyfy_heizhitaiyang_shield_turns", remainingTurns)
    end
  end,
})

-- 目标提示：显示哪些角色有蓄力技
Fk:addTargetTip{
  name = "yyfy_heizhitaiyang",
  target_tip = function(_, _, to_select)
    if table.find(to_select:getSkillNameList(), function(s)
      return Fk.skills[s]:hasTag(Skill.Charge)
    end) then
      return "fate_has_charge"
    end
  end,
}

-- 技能失去时清理自己的无敌标记
yyfy_heizhitaiyang:addLoseEffect(function(self, player, is_death)
  local room = player.room
  if player:getMark("@!fate_wudi") > 0 then
    room:setPlayerMark(player, "@!fate_wudi", 0)
  end
  if player:getMark("yyfy_heizhitaiyang_shield_turns") > 0 then
    room:setPlayerMark(player, "yyfy_heizhitaiyang_shield_turns", 0)
  end
end)

return yyfy_heizhitaiyang
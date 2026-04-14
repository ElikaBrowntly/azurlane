local yyfy_FunnyVamp = fk.CreateSkill{
  name = "yyfy_FunnyVamp",
  anim_type = "support",
  limit_mark = "@yyfy_FunnyVamp_used-turn",
}

Fk:loadTranslationTable{
  ["yyfy_FunnyVamp"] = "Funny Vamp",
  [":yyfy_FunnyVamp"] = "出牌阶段限一次，你可以赋予任意名角色<a href=':fate_wudi_1*3'>无敌状态</a>"
  .."(1次·3回合)。然后，这些角色中除你以外有蓄力技的角色各获得3点蓄力点。",
  
  [":fate_wudi_1*3"] = "<b>「无敌」状态 (1次·3回合):</b><br>防止此后受到的第1次伤害，经过3个回合后无论是否使用都会失效。",
  ["#yyfy_FunnyVamp-choose"] = "Funny Vamp：请选择任意名角色",
  ["#yyfy_FunnyVamp-charge"] = "Funny Vamp：请选择任意名有蓄力技的其他角色，这些角色将各获得3点蓄力点",
  ["fate_has_charge"] = "有蓄力技",
  ["@!fate_wudi"] = "无敌",
  ["#yyfy_FunnyVamp-shield"] = "由于「Funny Vamp」的效果，%from 防止了受到的伤害",

  ["$yyfy_FunnyVamp1"] = "只是余兴，来狩猎吧。",
  ["$yyfy_FunnyVamp2"] = "人形的容器还真是不方便呢。",
  ["$yyfy_FunnyVamp3"] = "那么，欢迎光临。"
}

local U = require "packages/utility/utility"

yyfy_FunnyVamp:addEffect("active", {
  prompt = "#yyfy_FunnyVamp-choose",
  card_num = 0,
  max_phase_use_time = 1,
  target_filter = function(self, to_select, selected)
    return to_select:isAlive()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local targets = effect.tos
    
    -- 护盾标记和回合计数标记
    for _, target in ipairs(targets) do
      room:setPlayerMark(target, "@!fate_wudi", 1)
      room:setPlayerMark(target, "yyfy_FunnyVamp_shield_turns", 3) -- 剩余3个回合
    end
    
    -- 获得3点蓄力点
    local availableTargets = table.filter(targets, function(p)
      if p ~= player and table.find(p:getSkillNameList(), function(s) return Fk.skills[s]:hasTag(Skill.Charge) end)
      then return true end
    end)
    
    if #availableTargets > 0 then
      local chargeTargets = room:askToChoosePlayers(player, {
        targets = availableTargets,
        min_num = 0,
        max_num = #availableTargets,
        prompt = "#yyfy_FunnyVamp-charge",
        skill_name = self.name,
        cancelable = true,
        target_tip_name = "yyfy_FunnyVamp",
      })
      
      if #chargeTargets > 0 then
        for _, p in ipairs(chargeTargets) do
          U.skillCharged(p, 3)
        end
      end
    end
  end,
})

-- 防止伤害
yyfy_FunnyVamp:addEffect(fk.DetermineDamageInflicted, {
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
      type = "#yyfy_FunnyVamp-shield",
      from = t.id,
    }
    -- 移除护盾
    room:setPlayerMark(t, "@!fate_wudi", 0)
    return true
  end,
})

-- 减少护盾剩余回合数
yyfy_FunnyVamp:addEffect(fk.TurnEnd, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("yyfy_FunnyVamp_shield_turns") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local remainingTurns = player:getMark("yyfy_FunnyVamp_shield_turns") - 1
    
    if remainingTurns <= 0 then
      -- 回合数用完，移除护盾
      room:setPlayerMark(player, "@!fate_wudi", 0)
      room:setPlayerMark(player, "yyfy_FunnyVamp_shield_turns", 0)
    else
      -- 更新剩余回合数
      room:setPlayerMark(player, "yyfy_FunnyVamp_shield_turns", remainingTurns)
    end
  end,
})

-- 目标提示：显示哪些角色有蓄力技
Fk:addTargetTip{
  name = "yyfy_FunnyVamp",
  target_tip = function(_, _, to_select)
    if table.find(to_select:getSkillNameList(), function(s) 
      return Fk.skills[s]:hasTag(Skill.Charge) 
    end) then
      return "fate_has_charge"
    end
  end,
}

return yyfy_FunnyVamp
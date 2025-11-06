local fate_FunnyVamp = fk.CreateSkill{
  name = "fate_FunnyVamp",
  anim_type = "support",
  limit_mark = "@fate_FunnyVamp_used-turn",
}

Fk:loadTranslationTable{
  ["fate_FunnyVamp"] = "Funny Vamp",
  [":fate_FunnyVamp"] = "出牌阶段限一次，你可令任意名角色防止此后受到的第一次伤害，在接下来的3个回合内，"
  .."若未触发则失效。然后，这些角色中除你以外有蓄力技的角色各获得1点蓄力点。",
  
  ["#fate_FunnyVamp-choose"] = "Funny Vamp：请选择任意名角色",
  ["#fate_FunnyVamp-charge-choose"] = "Funny Vamp：请选择任意名有蓄力技的其他角色，这些角色将各获得1点蓄力点",
  ["fate_FunnyVamp_has_charge"] = "有蓄力技",
  ["@@fate_FunnyVamp_shield"] = "无敌(1次)",
  ["#fate_FunnyVamp-shield"] = "由于「Funny Vamp」的效果，%from 防止了受到的伤害",

  ["$fate_FunnyVamp1"] = "只是余兴，来狩猎吧。",
  ["$fate_FunnyVamp2"] = "人形的容器还真是不方便呢。",
  ["$fate_FunnyVamp3"] = "那么，欢迎光临。"
}

local U = require "packages/utility/utility"

fate_FunnyVamp:addEffect("active", {
  prompt = "#fate_FunnyVamp-choose",
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
      room:setPlayerMark(target, "@@fate_FunnyVamp_shield", 1)
      room:setPlayerMark(target, "fate_FunnyVamp_shield_turns", 3) -- 剩余3个回合
    end
    
    -- 获得1点蓄力点
    local availableTargets = table.filter(targets, function(p)
      if p ~= player and table.find(p:getSkillNameList(), function(s) return Fk.skills[s]:hasTag(Skill.Charge) end)
      then return true end
    end)
    
    if #availableTargets > 0 then
      local chargeTargets = room:askToChoosePlayers(player, {
        targets = availableTargets,
        min_num = 0,
        max_num = #availableTargets,
        prompt = "#fate_FunnyVamp-charge-choose",
        skill_name = self.name,
        cancelable = true,
        target_tip_name = "fate_FunnyVamp",
      })
      
      if #chargeTargets > 0 then
        for _, p in ipairs(chargeTargets) do
          U.skillCharged(p, 1)
        end
      end
    end
  end,
})

-- 防止伤害
fate_FunnyVamp:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return data.to:getMark("@@fate_FunnyVamp_shield") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local t = data.to
    data.damage = 0
    -- 防止伤害
    room:sendLog{
      type = "#fate_FunnyVamp-shield",
      from = t.id,
    }
    -- 移除护盾
    room:setPlayerMark(t, "@@fate_FunnyVamp_shield", 0)
    return true
  end,
})

-- 减少护盾剩余回合数
fate_FunnyVamp:addEffect(fk.TurnEnd, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("fate_FunnyVamp_shield_turns") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local remainingTurns = player:getMark("fate_FunnyVamp_shield_turns") - 1
    
    if remainingTurns <= 0 then
      -- 回合数用完，移除护盾
      room:setPlayerMark(player, "@@fate_FunnyVamp_shield", 0)
      room:setPlayerMark(player, "fate_FunnyVamp_shield_turns", 0)
    else
      -- 更新剩余回合数
      room:setPlayerMark(player, "fate_FunnyVamp_shield_turns", remainingTurns)
    end
  end,
})

-- 目标提示：显示哪些角色有蓄力技
Fk:addTargetTip{
  name = "fate_FunnyVamp",
  target_tip = function(_, _, to_select)
    if table.find(to_select:getSkillNameList(), function(s) 
      return Fk.skills[s]:hasTag(Skill.Charge) 
    end) then
      return "fate_FunnyVamp_has_charge"
    end
  end,
}

return fate_FunnyVamp
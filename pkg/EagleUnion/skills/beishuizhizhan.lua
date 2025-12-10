local beishuizhizhan = fk.CreateSkill {
  name = "yyfy_beishuizhizhan",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable {
  ["yyfy_beishuizhizhan"] = "背水之战",
  [":yyfy_beishuizhizhan"] = "持恒技，你不会流失体力，受到的伤害-x/2且至多为1，造成的伤害+x/2。"..
  "每局游戏限5次，当你进入濒死状态时，你可以将体力值改为1并获得x点护甲（x为战意标记数）。",
  
  ["@yyfy_beishuizhizhan"] = "背水之战 剩余",
  
  ["#yyfy_beishuizhizhan_trigger"] = "是否发动「背水之战」？将体力值改为1，获得%arg点护甲",
  ["#yyfy_beishuizhizhan_damage_reduce"] = "%from 的「%arg」效果触发，受到伤害-%arg2",
  ["#yyfy_beishuizhizhan_damage_increase"] = "%from 的「%arg」效果触发，造成伤害+%arg2",
  ["#yyfy_beishuizhizhan_hplost_prevent"] = "%from 的「%arg」效果触发，防止了体力流失",
  
  ["$yyfy_beishuizhizhan1"] = "只要还能开火，我就不会放弃。",
  ["$yyfy_beishuizhizhan2"] = "拉菲……要滑倒了……好险……！",
}

-- 四舍五入函数
local function round(num)
  return math.floor(num + 0.5)
end

-- 防止体力流失
beishuizhizhan:addEffect(fk.PreHpLost, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(beishuizhizhan.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    -- 防止体力流失
    data:preventHpLost()
    -- 发送日志
    player.room:sendLog{
      type = "#yyfy_beishuizhizhan_hplost_prevent",
      from = player.id,
      arg = self.name,
    }
  end,
})

-- 受到伤害减少
beishuizhizhan:addEffect(fk.DetermineDamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return data.to == player and player:hasSkill(beishuizhizhan.name) and data.damage > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local x = player:getMark("@yyfy_AL_zhanyi") or 0
    local reduceAmount = round(x / 2)
    
    if reduceAmount > 0 then
      -- 计算减少后的伤害
      local newDamage = data.damage - reduceAmount
      
      -- 减伤后仍大于1点，则固定为1点伤害
      if newDamage >= 1 then newDamage = 1
      else newDamage = 0 --否则防止伤害
      end
      
      -- 如果伤害值发生变化
      if newDamage ~= data.damage then
        local room = player.room
        
        -- 记录日志
        room:sendLog{
          type = "#yyfy_beishuizhizhan_damage_reduce",
          from = player.id,
          arg = self.name,
          arg2 = reduceAmount,
        }
        
        -- 改变伤害值
        data:changeDamage(newDamage - data.damage)
      end
    end
  end,
})

-- 造成伤害增加
beishuizhizhan:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
    return data.from == player and player:hasSkill(beishuizhizhan.name) and data.damage > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local x = player:getMark("@yyfy_AL_zhanyi") or 0
    local increaseAmount = round(x / 2)
    
    if increaseAmount > 0 then
      local room = player.room
      
      -- 记录日志
      room:sendLog{
        type = "#yyfy_beishuizhizhan_damage_increase",
        from = player.id,
        arg = self.name,
        arg2 = increaseAmount,
      }
      
      -- 增加伤害
      data:changeDamage(increaseAmount)
    end
  end,
})

-- 进入濒死时，触发背水之战，早于求桃
beishuizhizhan:addEffect(fk.EnterDying, {
  can_trigger = function(self, event, target, player, data)
    -- 检查：1. 技能持有者 2. 正在求桃的角色是自己 3.还有使用次数
    return player:hasSkill(beishuizhizhan.name) and
           data.who == player and
           player:getMark("@yyfy_beishuizhizhan") > 0
  end,
  on_cost = function(self, event, target, player, data)
    local x = player:getMark("@yyfy_AL_zhanyi") or 0
    local room = player.room
    return room:askToSkillInvoke(player, {
      skill_name = "yyfy_beishuizhizhan",
      prompt = "#yyfy_beishuizhizhan_trigger:::" .. x
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local x = player:getMark("@yyfy_AL_zhanyi") or 0
    
    -- 减少使用次数
    local currentCount = player:getMark("@yyfy_beishuizhizhan")
    room:setPlayerMark(player, "@yyfy_beishuizhizhan", currentCount - 1)
    
    -- 将体力值改为1，效仿武诸葛亮
    player.hp = 1
    room:broadcastProperty(player, "hp")
    -- 获得x点护甲
    room:changeShield(player, x)
    -- 发送日志
    room:sendLog{
      type = "#背水之战触发",
      from = player.id,
      arg = "yyfy_beishuizhizhan",
      arg2 = tostring(x),
    }
  end,
})

-- 技能获得时初始化使用次数
beishuizhizhan:addAcquireEffect(function(self, player)
  player.room:setPlayerMark(player, "@yyfy_beishuizhizhan", 5)
  end
)

-- 技能失去时清理标记
beishuizhizhan:addLoseEffect(function(self, player, is_death)
  player.room:setPlayerMark(player, "@yyfy_beishuizhizhan", 0)
end)

return beishuizhizhan
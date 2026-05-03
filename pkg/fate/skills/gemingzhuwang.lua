local zhuwang = fk.CreateSkill {
  name = "yyfy_gemingzhuwang",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable {
  ["yyfy_gemingzhuwang"] = "革命蛛网",
  [":yyfy_gemingzhuwang"] = "持恒技，所有角色无法改变座次；敌方角色无法修整或自尽。",
}

local F = require "packages.hidden-clouds.functions"

local function isStrictlyEqual(t1, t2)
  if #t1 ~= #t2 then return false end
  for i = 1, #t1 do
    if t1[i] ~= t2[i] then return false end
  end
  return true
end

local function getElementCountMap(t)
  local map = {}
  for _, v in ipairs(t) do
    map[v] = (map[v] or 0) + 1
  end
  return map
end

zhuwang:addAcquireEffect(function(self, player, is_start, src)
  local room = player.room
  for _, p in ipairs(room:getAllPlayers()) do
    room:addTableMark(player, "yyfy_gemingzhuwang", p)
  end
end)

zhuwang:addEffect(fk.AfterSkillEffect, {
  can_refresh = function(self, event, target, player, data)
    return player and player:hasSkill(self) and not
        isStrictlyEqual(player:getTableMark("yyfy_gemingzhuwang"), player.room:getAlivePlayers())
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local countA = getElementCountMap(player:getTableMark("yyfy_gemingzhuwang"))
    local countB = getElementCountMap(room:getAlivePlayers())
    local sameElements = true
    -- 检查 A 中每个元素在 B 中的数量是否一致
    for k, v in pairs(countA) do
      if countB[k] ~= v then
        sameElements = false
        break
      end
    end
    if sameElements then
      -- 还需要检查 B 中是否有 A 没有的元素
      for k, _ in pairs(countB) do
        if not countA[k] then
          sameElements = false
          break
        end
      end
    end
    if sameElements then -- 玩家一样，仅座位变了：变回去
      room:arrangeSeats(player:getTableMark("yyfy_gemingzhuwang"))
      return
    end
    -- 否则更新记录的玩家表
    room:setPlayerMark(player, "yyfy_gemingzhuwang", {})
    for _, p in ipairs(room:getAlivePlayers()) do
      room:addTableMark(player, "yyfy_gemingzhuwang", p)
    end
  end
})

-- 有人死了，更新记录的玩家表
zhuwang:addEffect(fk.BuryVictim, {
  can_refresh = function (self, event, target, player, data)
    return player and player:hasSkill(self)
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "yyfy_gemingzhuwang", {})
    for _, p in ipairs(room:getAlivePlayers()) do
      room:addTableMark(player, "yyfy_gemingzhuwang", p)
    end
  end
})

zhuwang:addEffect(fk.AskForPeachesDone, {
  anim_type = "control",
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
    return player and target.hp <= 0 and target.dying and player:hasSkill(self)
    and F.isEnemy(player, target) and data.damage.from == target
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    data.ignoreDeath = true
    room:setPlayerProperty(target, "maxHp", math.max(target.maxHp, 1))
    room:setPlayerProperty(target, "hp", 1)
  end,
})

zhuwang:addEffect(fk.BeforeGameOverJudge, {
  can_refresh = function (self, event, target, player, data)
    return player and player:hasSkill(self) and F.isEnemy(player, target) and data.killer == target
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    room:setPlayerProperty(target, "dead", false)
    target._splayer:setDied(false)
    room:setPlayerProperty(target, "dying", false)
    room:setPlayerProperty(target, "maxHp", math.max(target.maxHp, 1))
    room:setPlayerProperty(target, "hp", 1)
  end
})

return zhuwang
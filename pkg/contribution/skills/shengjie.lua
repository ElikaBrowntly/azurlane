local shengjie = fk.CreateSkill {
  name = "yyfy_shengjie",
  tags = { Skill.Permanent, Skill.Compulsory },
  anim_type = "defensive",
}

Fk:loadTranslationTable{
  ["yyfy_shengjie"] = "圣洁",
  [":yyfy_shengjie"] = "永恒技，锁定技，你武将牌上的技能即将失去或失效时，取消之。"..
  "你无法被翻面/横置/操控/替换武将牌。你的阶段不能被跳过。有角色发动技能时，清除你武将牌上的所有标记。",
}

local all_generals = {"yyfy_shenglingpuni"}
local j = 1
while j <= 7 do
  table.insert(all_generals, "yyfy_shenglingpuni"..tostring(j))
  j = j + 1
end

shengjie:addLoseEffect(function(self, player, is_death)
  player.room:handleAddLoseSkills(player, self.name, nil, false, true)
end)

-- 获得此技能时，把玩家当前所有技能变成持恒技
shengjie:addAcquireEffect(function (self, player, is_start, src)
  for _, skill in ipairs(player.player_skills) do
    if skill:isPlayerSkill(player, false) then
      table.insertIfNeed(skill.skeleton.tags, Skill.Permanent)
    end
  end
end)

-- 玩家此后获得的新技能也变成持恒技
shengjie:addEffect(fk.EventAcquireSkill, {
  can_refresh = function (self, event, target, player, data)
    return player and player:hasSkill(self, true, true) and target == player
    and data.skill:isPlayerSkill(player, false)
  end,
  on_refresh = function (self, event, target, player, data)
    for _, skill in ipairs(player.player_skills) do
      if skill:isPlayerSkill(player, false) then
        table.insertIfNeed(skill.skeleton.tags, Skill.Permanent)
      end
    end
  end
})
-- 到此为止，实现了无法被失效

shengjie:addEffect(fk.EventLoseSkill, {
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self, true, true) and target == player
  end,
  on_trigger = function (self, event, target, player, data)
    player.room:handleAddLoseSkills(player, data.skill.name, nil, false, true)
  end
})
-- 到此为止，实现了无法被失去

-- 无法被翻面
shengjie:addEffect(fk.BeforeTurnOver, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.faceup
  end,
  on_trigger = function (self, event, target, player, data)
    data.prevented = true
  end
})

-- 无法被横置
shengjie:addEffect(fk.BeforeChainStateChange, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and not player.chained
  end,
  on_trigger = function (self, event, target, player, data)
    data.prevented = true
  end
})

-- 无法被操控
shengjie:addEffect(fk.AfterSkillEffect, {
  can_refresh = function (self, event, target, player, data)
    return player and player:hasSkill(self) and not player:isControlling(player)
  end,
  on_refresh = function (self, event, target, player, data)
    player:control(player)
  end
})

-- 无法被换将
shengjie:addEffect(fk.BeforePropertyChange, {
  is_delay_effect = true,
  can_refresh = function (self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      return data.from == player and ((data.general and not table.contains(all_generals, data.general) and table.contains(all_generals, player.general))
      or (data.deputyGeneral and not table.contains(all_generals, data.deputyGeneral) and table.contains(all_generals, player.deputyGeneral)))
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if not table.contains(all_generals, data.general) and table.contains(all_generals, player.general) then
      data.general = player.general
    end
    if not table.contains(all_generals, data.deputyGeneral) and table.contains(all_generals, player.deputyGeneral) then
      data.deputyGeneral = player.deputyGeneral
    end
  end,
})

-- 无法跳过阶段
shengjie:addEffect(fk.EventPhaseSkipping, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_use = function (self, event, target, player, data)
    data.skipped = false
  end,
})

-- 清楚所有标记
shengjie:addEffect(fk.SkillEffect, {
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self)
  end,
  on_trigger = function (self, event, target, player, data)
    local marks = player:getMarkNames()
    for _, mark in ipairs(marks) do
      player.room:setPlayerMark(player, mark, 0)
    end
  end
})

return shengjie
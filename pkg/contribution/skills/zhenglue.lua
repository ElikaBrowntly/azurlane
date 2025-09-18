local zhenglue = fk.CreateSkill {
  name = "lan__zhenglue",
}

Fk:loadTranslationTable{
  ["lan__zhenglue"] = "政略",
  [":lan__zhenglue"] = "每名角色的回合结束时，你可以摸一张牌，然后令一名没有“猎”的角色获得“猎”，"..
  "若当前回合角色为主公且未于此回合内造成过伤害，则改为令至多两名没有“猎”的角色获得“猎”。"..
  "你对有“猎”的角色使用牌无距离和次数限制。每回合限一次，当你对有“猎”的角色造成伤害后，"..
  "你可以摸一张牌并获得造成伤害的牌。准备阶段，若有“猎”的角色数不小于2，你获得〖平戎〗和〖飞影〗。",

  ["#lan__zhenglue-choose"] = "政略：令至多%arg名角色获得“猎”标记",
  ["#lan__zhenglue1-invoke"] = "政略：是否摸一张牌并令角色获得“猎”？",
  ["#lan__zhenglue2-invoke"] = "政略：你可以摸一张牌并获得造成伤害的牌",
  ["#lan__zhenglue-wake"] = "政略：有猎的角色数不小于2，你获得〖平戎〗和〖飞影〗",
  ["@@caocao_lie"] = "猎",

  ["$lan__zhenglue1"] = "治政用贤不以德，则四方定。",
  ["$lan__zhenglue2"] = "秉至公而服天下，孤大略成。",
  ["$lan__zhenglue3"] = "孤上承天命，会猎于江夏，幸勿观望。",
  ["$lan__zhenglue4"] = "今雄兵百万，奉词伐罪，敢不归顺？",
}

-- 回合结束时获得猎标记
zhenglue:addEffect(fk.TurnEnd, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "#lan__zhenglue1-invoke",
    })
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:drawCards(1, self.name)
    if player.dead then return end
    local targets = table.filter(room.alive_players, function(p)
      return p:getMark("@@caocao_lie") == 0
    end)
    if #targets == 0 then return end
    
    local x = 1
    -- 判断当前回合角色是否为主公且未造成伤害
    if target.role == "lord" and #player.room.logic:getActualDamageEvents(1, function (e)
      return e.data.from == target
    end, Player.HistoryTurn) == 0 then
      x = 2
    end
    
    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = x,
      prompt = "#lan__zhenglue-choose:::"..x,
      skill_name = self.name,
      cancelable = false,
    })
    for _, to in ipairs(tos) do
      room:setPlayerMark(to, "@@caocao_lie", 1)
    end
  end,
})

-- 造成伤害后摸牌并获得伤害牌
zhenglue:addEffect(fk.Damage, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.to:getMark("@@caocao_lie") > 0 and
      player:usedEffectTimes(self.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "#lan__zhenglue2-invoke",
    })
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:drawCards(1, self.name)
    if player.dead then return end
    if data.card and room:getCardArea(data.card) == Card.Processing then
      room:moveCardTo(data.card, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true, player)
    end
  end,
})

-- 对有猎的角色使用牌无距离和次数限制
zhenglue:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and player:hasSkill(self.name) and to and to:getMark("@@caocao_lie") > 0
  end,
  bypass_distances = function(self, player, skill, card, to)
    return card and player:hasSkill(self.name) and to and to:getMark("@@caocao_lie") > 0
  end,
})

-- 准备阶段觉醒效果（获得平戎和飞影）
zhenglue:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      player.phase == Player.Start and
      player:getMark("@@lan__zhenglue_awakened") == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local lieCount = #table.filter(room.alive_players, function (p)
      return p:getMark("@@caocao_lie") > 0
    end)
    
    if lieCount >= 2 then
      room:setPlayerMark(player, "@@lan__zhenglue_awakened", 1)
      room:handleAddLoseSkills(player, "pingrong|feiying")
      
      -- 播放觉醒音效
      player:broadcastSkillInvoke(self.name, 3)
      room:notifySkillInvoked(player, self.name, "wake")
    end
  end,
})

-- 失去技能时清除猎标记
zhenglue:addLoseEffect(function (self, player, is_death)
  local room = player.room
  if not table.find(room.alive_players, function(p)
    return p:hasSkill(self.name, true)
  end) then
    for _, p in ipairs(room.alive_players) do
      room:setPlayerMark(p, "@@caocao_lie", 0)
    end
  end
end)

return zhenglue
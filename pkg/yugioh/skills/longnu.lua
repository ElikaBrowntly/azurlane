local longnu = fk.CreateSkill {
  name = "yyfy_longnu",
}

Fk:loadTranslationTable{
  ["yyfy_longnu"] = "龙怒",
  [":yyfy_longnu"] = "每回合限1次，其他角色发动技能时，你可以弃置一张手牌，使其发动无效并受到1点伤害，其本回合无法再使用此技能，然后你本局游戏造成的伤害+1。",

  ["@@yyfy_longnu-turn"] = "龙怒",
  ["@yyfy_longnu-attack"] = "攻击+"
}

longnu:addEffect(fk.SkillEffect, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    local skill = data.skill:getSkeleton()
    local name
    if skill == nil then
      name = data.skill.name
    else
      name = skill.name
    end
    return target and player and player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
    and #player:getCardIds("h") > 0 and target:hasSkill(name, true, true) and data.skill:isPlayerSkill(target)
    and target ~= player
  end,
  on_cost = function (self, event, target, player, data)
    local cards = player.room:askToDiscard(player, {
      min_num = 0,
      max_num = 1,
      skill_name = longnu.name,
      cancelable = true,
      prompt = "龙怒：你可以弃置一张牌，令〖"..Fk:translate(data.skill:getSkeleton().name).."〗无效？"
    })
    if #cards == 1 then
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local e = room.logic:getCurrentEvent():findParent(GameEvent.SkillEffect, false)
    local skill = data.skill:getSkeleton()
    local name
    if skill == nil then
      name = data.skill.name
    else
      name = skill.name
    end
    room:setPlayerMark(target, "@@yyfy_longnu-turn", 1)
    target.tag["yyfy_longnu-name"] = name
    room:addPlayerMark(player, "@yyfy_longnu-attack", 1)
    room:damage({
      to = target,
      damage = 1,
      skillName = longnu.name
    })
    if e then
      room.logic:breakEvent(e)
    end
  end,
})

longnu:addEffect("invalidity", {
  invalidity_func = function(self, from, skill)
    local s = skill:getSkeleton()
    local name
    if s == nil then
      name = skill.name
    else
      name = s.name
    end
    return from:getMark("@@yyfy_longnu-turn") > 0 and skill:isPlayerSkill(from) and from.tag["yyfy_longnu-name"] == name
  end,
})

longnu:addEffect(fk.SkillEffect, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    local skill = data.skill:getSkeleton()
    local name
    if skill == nil then
      name = data.skill.name
    else
      name = skill.name
    end
    if target and player and player:hasSkill(self, true, true) and target:getMark("@@yyfy_longnu-turn") > 0
    and target:hasSkill(name, true, true) and data.skill:isPlayerSkill(target)
    and (player.tag["yyfy_longnu-count"] or 0) < 20 and name == target.tag["yyfy_longnu-name"]then
      local n = player.tag["yyfy_longnu-count"] or 0
      player.tag["yyfy_longnu-count"] = n + 1
      return true
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    local e = room.logic:getCurrentEvent():findParent(GameEvent.SkillEffect)
    if e then
      room.logic:breakEvent(e)
    end
  end,
})

longnu:addEffect(fk.DamageCaused, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(self, true, true)
  end,
  on_refresh = function (self, event, target, player, data)
    data:changeDamage(player:getMark("@yyfy_longnu-attack"))
  end
})

longnu:addEffect(fk.EventTurnChanging, {
  is_delay_effect = true,
  can_refresh = function (self, event, target, player, data)
    return player and player:hasSkill(self)
  end,
  on_refresh = function (self, event, target, player, data)
    if player.tag["yyfy_longnu-count"] ~= 0 then
      player.tag["yyfy_longnu-count"] = 0
    end
    for _, p in ipairs(player.room:getAlivePlayers()) do
      if p.tag["yyfy_longnu-name"] ~= nil then
        p.tag["yyfy_longnu-name"] = nil
      end
    end
  end
})

longnu:addAI(Fk.Ltk.AI.newInvokeStrategy{
  think = function (self, ai)
    local data = ai.room.logic:getCurrentEvent().data
    return data and data.who and ai:isEnemy(data.who)
  end,
})

longnu:addAI(Fk.Ltk.AI.newDiscardStrategy{
  choose_cards = function (self, ai)
    local player = ai.player
    local cards = player:getCardIds("he")
    local card = cards[math.random(#cards)]
    local data = ai.room.logic:getCurrentEvent().data
    if not (data and data.who and ai:isEnemy(data.who)) then
      return {}, 0
    end
    cards = ai:askToChooseCards({
      cards = cards,
      skill_name = longnu.name,
      data = {
        to_place = Card.DiscardPile,
        reason = fk.ReasonDiscard,
        proposer = player
      }
    })
    return {card}, 10000
  end,
})

return longnu
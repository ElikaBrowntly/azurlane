local wushuang = fk.CreateSkill {
  name = "lan__wushuang",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["lan__wushuang"] = "无双",
  [":lan__wushuang"] = "锁定技，你使用的【杀】需要两张【闪】才能抵消；与你进行【决斗】的角色每次需要打出两张【杀】。" ..
  "若对方此次未使用或打出过【杀】或【闪】，则此【杀】或【决斗】对其造成的伤害+1。",

  ["$lan__wushuang1"] = "世间英雄如云，唯吾举世无双！",
  ["$lan__wushuang2"] = "纵观天下，安有我一合之敌？"
}

wushuang:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if
      not (
        target == player and
        player:hasSkill(wushuang.name) and
        data.card and
        table.contains({ "slash", "duel" }, data.card.trueName)
      )
    then
      return false
    end

    local effectEvent = player.room.logic:getCurrentEvent():findParent(GameEvent.CardEffect)
    if effectEvent then
      local effectData = effectEvent.data
      if not table.contains((effectData.extra_data or {}).wushuangTargets or {}, data.to) then
        return false
      end

      if effectData.card.trueName == "slash" then
        return not table.find(effectData.cardsResponded or {},
          function(card) return card.trueName == "jink"
        end)
      elseif effectData.card.trueName == "duel" then
        return #player.room.logic:getEventsByRule(GameEvent.RespondCard, 1, function(e)
          local responseData = e.data
          return
            responseData.card.trueName == "slash" and
            responseData.responseToEvent == effectData and
            responseData.from == data.to
        end, nil, Player.HistoryTurn) == 0
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(1)
  end,
})

---@type TrigSkelSpec<AimFunc>
local spec = {
  on_use = function(self, event, target, player, data)
    local to = (event == fk.TargetConfirmed and data.card.trueName == "duel") and data.from or data.to
    player.room:notifySkillInvoked(player, wushuang.name, "offensive")
    if data.card.trueName == "duel" and to:hasSkill(wushuang.name) then
      player:broadcastSkillInvoke(wushuang.name, math.random(5, 6))
    else
      player:broadcastSkillInvoke(wushuang.name, math.random(1, 2))
    end

    data:setResponseTimes(2, to)
    data.extra_data = data.extra_data or {}
    data.extra_data.wushuangTargets = data.extra_data.wushuangTargets or {}
    table.insertIfNeed(data.extra_data.wushuangTargets, to)
  end,
}

wushuang:addEffect(fk.TargetSpecified, {
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player:hasSkill(wushuang.name) and
      table.contains({ "slash", "duel" }, data.card.trueName)
  end,
  on_use = spec.on_use,
})

wushuang:addEffect(fk.TargetConfirmed, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(wushuang.name) and data.card.trueName == "duel"
  end,
  on_use = spec.on_use,
})

return wushuang
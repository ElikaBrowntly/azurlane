local yanhui = fk.CreateSkill {
  name = "yyfy_yanhui",
}

Fk:loadTranslationTable {
  ["yyfy_yanhui"] = "焰洄",
  [":yyfy_yanhui"] = "当你使用牌指定第一个目标后，你可展示一名目标角色的一张手牌，若此牌本回合已被展示过，你弃置之。" ..
      "若如此做，此阶段结束时，你对一名本阶段因此弃置过牌的角色造成1点火焰伤害，然后摸X张牌（X为本回合展示过牌的角色数）。",

  ["#yyfy_yanhui-invoke"] = "焰洄：你可展示一名目标角色的一张手牌",
  ["#yyfy_yanhui-choose"] = "焰洄：你可对一名满足条件的角色造成1点火焰伤害，然后摸%arg张牌",

  ["$yyfy_yanhui1"] = "既有夺城之力，所图岂在一方！",
  ["$yyfy_yanhui2"] = "闻弦歌而知雅意，抚瑶琴以会群英！",
  ["$yyfy_yanhui3"] = "引子敬而定宏图，振长策共吞天下！",
  ["$yyfy_yanhui4"] = "敌势已弱，进起胜焰！",
  ["$yyfy_yanhui5"] = "便趁此胜，作气连捷！",
  ["$yyfy_yanhui6"] = "你我同心共志，天下垂手可得！",
}

yanhui:addEffect(fk.TargetSpecified, {
  can_trigger = function(self, event, target, player, data)
    return
        target == player and
        data.firstTarget and
        player:hasSkill(yanhui.name) and
        table.find(data.use.tos, function(p)
          return not p:isKongcheng()
        end)
  end,
  on_cost = function(self, event, target, player, data)
    local targets = table.filter(data.use.tos, function(p)
      return not p:isKongcheng()
    end)

    local tos = player.room:askToChoosePlayers(
      player,
      {
        min_num = 1,
        max_num = 1,
        targets = targets,
        skill_name = yanhui.name,
        prompt = "#yyfy_yanhui-invoke",
      }
    )

    if #tos == 1 then
      event:setCostData(self, { tos = tos })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    ---@type string
    local skillName = yanhui.name
    local room = player.room
    local to = event:getCostData(self).tos[1]
    if room.logic:getCurrentEvent():findParent(GameEvent.Phase) then
      room:setPlayerMark(player, "yyfy_yanhui_used-phase", 1)
    end

    local id = room:askToChooseCard(
      player,
      {
        target = to,
        flag = "h",
        skill_name = skillName,
      }
    )

    local hasDisplayed = table.contains(room:getTag("yyfy_yanhui_record-turn") or {}, id)
    to:showCards(id, player)
    if hasDisplayed then
      room:throwCard(id, skillName, to, player)
    end
  end
})

yanhui:addEffect(fk.EventPhaseEnd, {
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("yyfy_yanhui_used-phase") > 0 and player:isAlive()
  end,
  on_use = function(self, event, target, player, data)
    ---@type string
    local skillName = yanhui.name
    local room = player.room

    local targets = {}
    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
      for _, move in ipairs(e.data) do
        if
            move.from and
            move.moveReason == fk.ReasonDiscard and
            move.skillName == skillName and
            move.from:isAlive()
        then
          table.insertIfNeed(targets, move.from)
        end
      end
    end, Player.HistoryPhase)

    local record = #(room:getTag("yyfy_yanhui_players-turn") or {})
    if #targets == 0 and record == 0 then
      return false
    end

    local tos = {}
    local prompt = "#yyfy_yanhui-choose:::" .. record
    tos = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = skillName,
      prompt = prompt,
      cancelable = false,
    }
    )

    room:damage {
      from = player,
      to = tos[1],
      damage = 1,
      damageType = fk.FireDamage,
      skillName = skillName,
    }
    player:drawCards(record, skillName)
  end,
})

yanhui:addEffect(fk.CardShown, {
  can_refresh = function(self, event, target, player, data)
    return data.from == player
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local record = room:getTag("yyfy_yanhui_record-turn") or {}
    table.insertTableIfNeed(record, data.cardIds)
    room:setTag("yyfy_yanhui_record-turn", record)

    record = room:getTag("yyfy_yanhui_players-turn") or {}
    table.insertIfNeed(record, player.id)
    room:setTag("yyfy_yanhui_players-turn", record)
  end,
})

return yanhui
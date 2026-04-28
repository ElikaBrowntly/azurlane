local zaohua = fk.CreateSkill {
  name = "yyfy_zaohua",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable {
  ["yyfy_zaohua"] = "造化",
  [":yyfy_zaohua"] = "持恒技，每轮限一次，当你即将死亡时，你可以将体力值回复至1，终止一切结算并结束当前回合，然后你立即行动。"
}

zaohua:addEffect(fk.BeforeGameOverJudge, {
  priority = 3,
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self, true, true) and (player.tag[zaohua.name] or 0) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player.tag[zaohua.name] = 1
    room:setTag("SkipGameRule", true)
    table.insertIfNeed(room.alive_players, player)
    player.dead = false
    player.maxHp = math.max(player.maxHp, 1) -- 防止出现僵尸
    room:broadcastProperty(player, "maxHp")
    room:recover({
      who = player,
      num = 1 - player.hp,
      recoverBy = player,
      skillName = zaohua.name
    })
    room:setBanner(zaohua.name, player.id)
    -- 直接player:gainAnExtraTurn(true, zaohua.name)会被breakTurn截断，所以手动实现
    room.logic:breakTurn()
  end
})

zaohua:addEffect(fk.EventTurnChanging, {
  can_refresh = function (self, event, target, player, data)
    return player.room:getBanner(zaohua.name) == player.id
  end,
  on_refresh = function (self, event, target, player, data)
    if data.to == player then
      player.room:setBanner(zaohua.name, 0)
    else
      data.skipped = true
    end
  end,
})

zaohua:addEffect(fk.RoundEnd, {
  can_refresh = function (self, event, target, player, data)
    return player and player:hasSkill(self, true, true) and (player.tag[zaohua.name] or 0) ~= 0
  end,
  on_refresh = function (self, event, target, player, data)
    player.tag[zaohua.name] = 1
  end
})

return zaohua
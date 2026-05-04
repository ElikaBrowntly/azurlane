local QC_yongsheng = fk.CreateSkill{
  name = "QC_yongsheng",
  tags = { Skill.Permanent },
  anim_type = "defensive",
}

Fk:loadTranslationTable{
  ["QC_yongsheng"] = "永生",
  [":QC_yongsheng"] = "持恒技，当你的体力大于0时，你不会死亡。你的阶段不可被跳过。",
}

QC_yongsheng:addEffect(fk.EventPhaseSkipping, {
  mute = true,
  no_indicate = true,
  can_refresh = function(self, event, target, player, data)
    return target:hasSkill(QC_yongsheng.name, true, true)
  end,
  on_refresh = function(self, event, target, player, data)
    data.skipped = false
  end,
})

QC_yongsheng:addEffect(fk.BeforeGameOverJudge, {
  is_delay_effect = true,
  mute = true,
  no_indicate = true,
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(QC_yongsheng.name, true, true) and
        ((player.dying or player.dead) and player.hp > 0) or player.maxHp <= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if player.maxHp <= 0 then
      room:setPlayerProperty(player, "maxHp", 1)
      room:setPlayerProperty(player, "hp", math.max(1, player.hp))
    end
    room:setPlayerProperty(player, "dead", false)
    player._splayer:setDied(false)
    room:setPlayerProperty(player, "dying", false)
    room:setPlayerProperty(player, "maxHp", math.max(1, player.maxHp))
    room:setPlayerProperty(player, "hp", math.max(1, player.hp))
    table.insertIfNeed(room.alive_players, player)
    local e = room.logic:getCurrentEvent()
    if e then e:shutdown() end
  end,
})

QC_yongsheng:addEffect(fk.MaxHpChanged, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(QC_yongsheng.name, true, true) and player.maxHp <= 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerProperty(player, "maxHp", 1)
    room:setPlayerProperty(player, "hp", math.max(1, player.hp))
  end,
})

return QC_yongsheng
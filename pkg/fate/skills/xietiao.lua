local xietiao = fk.CreateSkill {
  name = "yyfy_xietiao_ORT",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["yyfy_xietiao_ORT"] = "血条",
  [":yyfy_xietiao_ORT"] = "持恒技，你获得2个额外的血条(4上限·8上限)。你死亡时，若血条已全被击破，则变更为“移动ORT”。"
}

xietiao:addAcquireEffect(function (self, player, is_start, src)
  local room = player.room
  room:setPlayerMark(player, "@!yyfy_xietiao_ORT2", 1)
  room:setPlayerMark(player, "@!yyfy_xietiao_ORT1", 1)
end)

xietiao:addEffect(fk.BeforeGameOverJudge, {
  priority = 2,
  anim_type = "support",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self, true, true)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local case = 3
    if player:getMark("@!yyfy_xietiao_ORT1") > 0 then
      case = 1
    elseif player:getMark("@!yyfy_xietiao_ORT2") > 0 then
      case = 2
    end
    room:setTag("SkipGameRule", true)
    room:revivePlayer(player, false)
    if case == 1 then
      player.maxHp = 4
      room:broadcastProperty(player, "maxHp")
      player.tag[xietiao.name] = 1
      return
    end
    if case == 2 then
      player.maxHp = 8
      room:broadcastProperty(player, "maxHp")
      player.tag[xietiao.name] = 2
      return
    end
    local isDeputy = false
    if player.deputyGeneral == "yyfy_ORT" then
      isDeputy = true
    end
    room:changeHero(player, "sunce", true, isDeputy)
  end
})

-- 不知道为什么不显示标记数量了。可能是死亡一次以后都不会显示了？
xietiao:addEffect(fk.AfterSkillEffect, {
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self) and player.tag[xietiao.name] == 1
    and player:getMark("@!yyfy_xietiao_ORT2") == 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@!yyfy_xietiao_ORT2", 1)
  end
})

return xietiao
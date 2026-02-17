local xuwu = fk.CreateSkill {
  name = "yyfy_xuwu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["yyfy_xuwu"] = "虚无",
  [":yyfy_xuwu"] = "锁定技，当你受到伤害时，终止一切结算并立即结束此回合。你出场时，终止一切结算并立即行动。"
}

xuwu:addEffect(fk.DamageInflicted, {
  can_trigger = function (self, event, target, player, data)
    return player and target == player and player:hasSkill(self)
  end,
  on_trigger = function (self, event, target, player, data)
    player.room.logic:breakTurn()
  end
})

xuwu:addEffect(fk.AfterPropertyChange, {
  can_trigger = function (self, event, target, player, data)
    return player and target == player and player:hasSkill(self)
    and (data.general == "yyfy_shenglingpuni" or data.deputyGeneral and data.deputyGeneral == "yyfy_shenglingpuni")
  end,
  on_trigger = function (self, event, target, player, data)
    player.room:setBanner(xuwu.name, player.id)
    print("已行动")
    player.room.logic:breakTurn()
  end
})

xuwu:addEffect(fk.EventTurnChanging, {
  can_refresh = function (self, event, target, player, data)
    return player.room:getBanner(xuwu.name) == player.id
  end,
  on_refresh = function (self, event, target, player, data)
    if data.to == player then
      player.room:setBanner(xuwu.name, 0)
    else
      data.skipped = true
    end
  end,
})

return xuwu
local yingbo = fk.CreateSkill {
  name = "yyfy_yingbo",
  tags = { Skill.Compulsory }
}

Fk:loadTranslationTable {
  ["yyfy_yingbo"] = "英博",
  [":yyfy_yingbo"] = "当你使用牌时：<br>" ..
      "若本轮已有角色使用过，此牌造成的伤害改为火焰伤害且伤害+1；没有，则此牌不能被响应，结算结束后你摸1张牌。",

  ["$yyfy_yingbo1"] = "上士之争，不在沙场而在方寸。",
  ["$yyfy_yingbo2"] = "事别三日，当刮目相待，大兄何见事之晚乎！",
}

yingbo:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local events = room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
      return (((e.data or {}).card or {}).trueName or "") == data.card.trueName and
          e.id < room.logic:getCurrentEvent():findParent(GameEvent.UseCard).id
    end, Player.HistoryRound)
    if events and #events > 0 then return end
    data.disresponsiveList = player.room:getAllPlayers()
    local d = data.extra_data or {}
    d.yyfy_yingbo = true
    data.extra_data = d
  end
})

yingbo:addEffect(fk.CardUseFinished, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
        (data.extra_data or {}).yyfy_yingbo == true
  end,
  on_refresh = function(self, event, target, player, data)
    player:drawCards(1, yingbo.name)
  end
})

yingbo:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self) and data.card) then return false end
    local events = player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
      return (((e.data or {}).card or {}).trueName or "") == data.card.trueName and
          e.id < player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard).id
    end, Player.HistoryRound)
    return events and #events > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damageType = fk.FireDamage
    data:changeDamage(1)
  end
})

return yingbo
local shuangjia = fk.CreateSkill {
  name = "yyfy_shuangjia",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["yyfy_shuangjia"] = "霜笳",
  [":yyfy_shuangjia"] = "锁定技，<br>①你的初始手牌增加“胡笳”标记且不计入手牌上限。<br>②你每拥有一张“胡笳”，" ..
      "其他角色计算与你距离+1。<br>③回合开始或结束时，你回收牌堆或弃牌堆中的“胡笳”牌。（未完待续）",

  ["@@yyfy_shuangjia"] = "胡笳",
  ["@yyfy_shuangjia"] = "胡笳",

  ["$yyfy_shuangjia1"] = "塞外青鸟匿，不闻折柳声。",
  ["$yyfy_shuangjia2"] = "向晚吹霜笳，雪落白发生。",
}

shuangjia:addLoseEffect(function(self, player, is_death)
  player.room:setPlayerMark(player, "@yyfy_shuangjia", 0)
end)

shuangjia:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(shuangjia.name) and not player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = player:getCardIds("h")
    for _, id in ipairs(cards) do
      room:setCardMark(Fk:getCardById(id), "@@yyfy_shuangjia", 1)
    end
    room:setPlayerMark(player, shuangjia.name, cards)
    room:setPlayerMark(player, "@yyfy_shuangjia", #cards)
  end,
})

shuangjia:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    if #player:getTableMark(shuangjia.name) == 0 then return false end
    local before = player:getMark("@yyfy_shuangjia")
    local after = #table.filter(player:getCardIds("h"), function (id)
      return Fk:getCardById(id):getMark("@@yyfy_shuangjia") > 0
    end)
    if before == after then return false end
    local costData = event:getCostData(self) or {}
    costData.after = after
    event:setCostData(self, costData)
    return true
  end,
  on_refresh = function(self, event, target, player, data)
    local after = (event:getCostData(self) or {}).after or 0
    player.room:setPlayerMark(player, "@yyfy_shuangjia", after)
  end,
})

shuangjia:addEffect("maxcards", {
  exclude_from = function(self, player, card)
    return card:getMark("@@yyfy_shuangjia") > 0
  end,
})

shuangjia:addEffect("distance", {
  correct_func = function(self, from, to)
    return to:getMark("@yyfy_shuangjia")
  end,
})

local spec = {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self)) then return false end
    local piles = table.simpleClone(player.room.draw_pile)
    table.insertTable(piles, player.room.discard_pile)
    return table.find(piles, function(id)
      return Fk:getCardById(id):getMark("@@yyfy_shuangjia") > 0
    end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local piles = table.simpleClone(room.draw_pile)
    table.insertTable(piles, room.discard_pile)
    local cards = table.filter(piles, function(id)
      return Fk:getCardById(id):getMark("@@yyfy_shuangjia") > 0
    end)
    room:moveCardTo(cards, Player.Hand, player, fk.ReasonJustMove, shuangjia.name, nil, false, player)
  end,
}

shuangjia:addEffect(fk.TurnStart, spec)

shuangjia:addEffect(fk.TurnEnd, spec)

return shuangjia
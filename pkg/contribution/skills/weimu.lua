local weimu = fk.CreateSkill{
  name = "yyfy_weimu",
}

Fk:loadTranslationTable{
  ["yyfy_weimu"] = "帷幕",
  [":yyfy_weimu"] = "每名角色的回合或阶段开始时，若你未处于休整状态，你可以将牌堆中一张牌置于其武将牌上"..
  "称为「帷幕」，直到回合结束。若如此做，你进入仅1回合的修整。修整结束后，你获得本回合弃牌堆中的牌。"..
  "（每拥有一张红色/黑色「帷幕」，该角色造成的伤害便+1/-1）。",

  ["yyfy_weimu-red"] = "红色（令其伤害+1）",
  ["yyfy_weimu-black"] = "黑色（令其伤害-1）",
  ["yyfy_weimu-pile"] = "帷幕",

  ["$yyfy_weimu1"] = "施经布略由我，剩下的任由将军。",
  ["$yyfy_weimu2"] = "兵以诈立，不如，任其来攻。"
}

local F = require("packages.hidden-clouds.functions")

weimu:addEffect(fk.TurnStart, {
  anim_type = "control",
  priority = 2,
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self.name) and player.rest == 0
  end,
  on_cost = function (self, event, target, player, data)
    local choice = player.room:askToChoice(player, {
      skill_name = weimu.name,
      choices = {"yyfy_weimu-red", "yyfy_weimu-black", "Cancel"}
    })
    if choice ~= "Cancel" then
      event:setCostData(self, {choice = choice})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local choice = event:getCostData(self).choice
    local room = player.room
    if choice == "yyfy_weimu-red" then
      F.getWeimu(player, target, Card.Red, weimu.name)
    else
      F.getWeimu(player, target, Card.Black, weimu.name)
    end
    room:setPlayerRest(player, 1)
    room:addPlayerMark(player, "yyfy_weimu-rest")
    table.removeOne(room.alive_players, player)
    room:broadcastProperty(player, "dead")
    if player == room.current then
      room:endTurn()
    end
  end
})

weimu:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  priority = 2,
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self.name) and player.rest == 0
  end,
  on_cost = function (self, event, target, player, data)
    local choice = player.room:askToChoice(player, {
      skill_name = weimu.name,
      choices = {"yyfy_weimu-red", "yyfy_weimu-black", "Cancel"}
    })
    if choice ~= "Cancel" then
      event:setCostData(self, {choice = choice})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local choice = event:getCostData(self).choice
    local room = player.room
    if choice == "yyfy_weimu-red" then
      F.getWeimu(player, target, Card.Red, weimu.name)
    else
      F.getWeimu(player, target, Card.Black, weimu.name)
    end
    room:setPlayerRest(player, 1)
    room:addPlayerMark(player, "yyfy_weimu-rest")
    table.removeOne(room.alive_players, player)
    room:broadcastProperty(player, "dead")
    if player == room.current then
      room:endTurn()
    end
  end
})

weimu:addEffect(fk.TurnEnd, {
  anim_type = "drawcard",
  can_refresh = function (self, event, target, player, data)
    return player and player:hasSkill(self.name) and player.rest > 0 and player:getMark("yyfy_weimu-rest") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerRest(player, 0)
    player.room:setPlayerMark(player, "yyfy_weimu-rest", 0)
    if player.dead then return end
    local cards = {}
    player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
      for _, move in ipairs(e.data) do
        if move.toArea == Card.DiscardPile then
          for _, info in ipairs(move.moveInfo) do
            if Fk:getCardById(info.cardId):isCommonTrick() and table.contains(player.room.discard_pile, info.cardId) then
              table.insertIfNeed(cards, info.cardId)
            end
          end
        end
      end
    end, Player.HistoryTurn)
    if #cards > 0 then
      player.room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, weimu.name, nil, true, player)
    end
  end
})

weimu:addEffect(fk.DamageCaused, {
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return data.from and #target:getPile("yyfy_weimu-pile") > 0 and player and player:hasSkill(self.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local red = 0
    local black = 0
    for _, card in ipairs(target:getPile("yyfy_weimu-pile")) do
      if Fk:getCardById(card).color == Card.Red then
        red = red + 1
      else
        black = black + 1
      end
    end
    data:changeDamage(red - black)
  end
})

weimu:addEffect(fk.TurnEnd, {
  mute = true,
  can_trigger = Util.TrueFunc,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    for _, p in ipairs(player.room:getAllPlayers()) do
      if #p:getPile("yyfy_weimu-pile") > 0 then
        player.room:moveCardTo(p:getPile("yyfy_weimu-pile"), Card.DiscardPile)
      end
    end
  end
})

return weimu
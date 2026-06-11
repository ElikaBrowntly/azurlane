local huanli = fk.CreateSkill {
  name = "yyfy_huanli",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["yyfy_huanli"] = "幻利",
  [":yyfy_huanli"] = "锁定技，所有角色摸牌阶段多摸一张牌且手牌上限等于体力上限。一名角色摸牌阶段结束时，" ..
      "你展示任意张手牌，本回合这些牌获得“幻利”标记，你使用这些牌无距离次数限制，失去这些牌时摸2张牌。",

  ["@@yyfy_huanli-inhand-turn"] = "幻利",
  ["$yyfy_huanli1"] = "哈哈哈哈！",
  ["$yyfy_huanli2"] = "汝等看好了！",
}

huanli:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n + 1
  end,
})

huanli:addEffect("maxcards", {
  fixed_func = function(self, player)
    return player.maxHp
  end
})

huanli:addEffect(fk.EventPhaseEnd, {
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(self) and data.phase == Player.Draw and not player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 0,
      max_num = #player:getCardIds("h"),
      skill_name = huanli.name,
      include_equip = false,
      cancelable = false,
      prompt = "幻利：请展示任意张手牌并获得标记，失去标记牌后摸2张牌"
    })
    if not cards or #cards == 0 then return end
    player:showCards(cards, player)
    room:setPlayerMark(player, "yyfy_huanli-turn", cards)
    for _, id in ipairs(cards) do
      room:addCardMark(Fk:getCardById(id), "@@yyfy_huanli-inhand-turn")
    end
  end
})

huanli:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card)
    if player:hasSkill(self) and card and card:getMark("@@yyfy_huanli-inhand-turn") > 0 then
      return true
    end
  end,
})

huanli:addEffect(fk.CardUsing, {
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card
        and data.card:getMark("@@yyfy_huanli-inhand-turn") > 0 and not data.extraUse
  end,
  on_refresh = function(self, event, target, player, data)
    data.extraUse = true
  end,
})

huanli:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if player and player:hasSkill(self) then
      for _, move in ipairs(data) do
        if move.from == player then
          for _, info in ipairs(move.moveInfo) do
            local mark = player:getTableMark("yyfy_huanli-turn")
            if info.fromArea == Card.PlayerHand and table.contains(mark, info.cardId) then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local mark = table.simpleClone(player:getTableMark("yyfy_huanli-turn"))
    local x = 0
    for _, move in ipairs(data) do
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand and table.removeOne(mark, info.cardId) then
            x = x + 2
          end
        end
      end
    end
    room:setPlayerMark(player, "yyfy_huanli-turn", #mark > 0 and mark or 0)
    player:drawCards(x, huanli.name)
  end,
})

return huanli
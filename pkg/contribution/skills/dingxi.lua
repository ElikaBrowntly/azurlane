---@diagnostic disable: assign-type-mismatch
local lan__dingxi = fk.CreateSkill{
  name = "lan__dingxi",
  derived_piles = "dingxi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["lan__dingxi"] = "定西",
  [":lan__dingxi"] = "锁定技，当你使用伤害牌结算完毕进入弃牌堆后，你可以对你的上家使用其中一张伤害牌"..
  "（无次数限制），然后将之置于你的武将牌上。结束阶段，你摸X张牌（X为“定西”牌数）。"..
  "当你受到伤害后，你获得随机一张与造成伤害的牌牌名相同的“定西”牌。",

  ["#lan__dingxi-use"] = "定西：你可以对 %dest 使用其中一张牌",

  ["$lan__dingxi1"] = "今天，我曹操誓要踏平祁连山！",
  ["$lan__dingxi2"] = "饮马瀚海、封狼居胥，大丈夫当如此！",
  ["$lan__dingxi3"] = "当今四海升平，可为治世之能臣。",
  ["$lan__dingxi4"] = "为大汉江山鞠躬尽瘁，臣死犹生。",
}

-- 使用伤害牌后对上家使用的效果
lan__dingxi:addEffect(fk.AfterCardsMove, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(lan__dingxi.name) then
      local room = player.room
      local cards = {}
      for _, move in ipairs(data) do
        if move.from == nil and move.moveReason == fk.ReasonUse then
          local move_event = room.logic:getCurrentEvent()
          local use_event = move_event.parent
          if use_event ~= nil and use_event.event == GameEvent.UseCard then
            local use = use_event.data
            if use.from == player and use.card.is_damage_card then
              local card_ids = room:getSubcardsByRule(use.card)
              for _, info in ipairs(move.moveInfo) do
                local card = Fk:getCardById(info.cardId, true)
                if table.contains(card_ids, info.cardId) and card.is_damage_card and
                  table.contains(room.discard_pile, info.cardId) then
                  table.insertIfNeed(cards, info.cardId)
                end
              end
            end
          end
        end
      end
      cards = room.logic:moveCardsHoldingAreaCheck(cards)
      cards = table.filter(cards, function (id)
        local card = Fk:getCardById(id)
        if player:getLastAlive() == player then
          return player:canUseTo(card, player)
        else
          return not player:isProhibited(player:getLastAlive(), card)
        end
      end)
      if #cards > 0 then
        event:setCostData(self, {cards = cards})
        return true
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self).cards
    local use = room:askToUseRealCard(player, {
      pattern = cards,
      skill_name = lan__dingxi.name,
      prompt = "#lan__dingxi-use::"..player:getLastAlive().id,
      extra_data = {
        bypass_times = true,
        extraUse = true,
        expand_pile = cards,
        exclusive_targets = { player:getLastAlive().id },
      },
      cancelable = true,
      skip = true,
    })
    if use then
      event:setCostData(self, {extra_data = use})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local use = event:getCostData(self).extra_data
    use.tos = { player:getLastAlive() }
    use.extra_data = use.extra_data or {}
    use.extra_data.dingxi = player
    room:useCard(use)
  end,
})

-- 结束阶段摸牌效果
lan__dingxi:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  on_cost = function(self, event, target, player, data)
    return target == player and player:hasSkill(lan__dingxi.name) and player.phase == Player.Finish and
      #player:getPile(lan__dingxi.name) > 0
  end,
  on_use = function (self, event, target, player, data)
    player:drawCards(#player:getPile(lan__dingxi.name), lan__dingxi.name)
  end,
})

-- 使用牌后将牌置于武将牌上的效果
lan__dingxi:addEffect(fk.CardUseFinished, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and data.extra_data and data.extra_data.dingxi == player and
      not player.dead and player.room:getCardArea(data.card) == Card.Processing
  end,
  on_use = function (self, event, target, player, data)
    player:addToPile(lan__dingxi.name, data.card, true, lan__dingxi.name, player)
  end,
})

-- 能臣技能
lan__dingxi:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(lan__dingxi.name) and data.card and
      #player:getPile("dingxi") > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 获取与造成伤害的牌牌名相同的定西牌
    local cards = table.filter(player:getPile("dingxi"), function (id)
      return data.card.trueName == Fk:getCardById(id).trueName
    end)
    
    if #cards > 0 then
      -- 随机获得一张
      local cardId = table.random(cards)
      room:moveCardTo(cardId, Card.PlayerHand, player, fk.ReasonJustMove, lan__dingxi.name, nil, true, player)
      
      -- 播放音效
      player:broadcastSkillInvoke(lan__dingxi.name, 3)
    end
  end,
})

return lan__dingxi
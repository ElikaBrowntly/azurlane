local lieji = fk.CreateSkill {
  name = "lan__lieji",
}

Fk:loadTranslationTable{
  ["lan__lieji"] = "烈计",
  [":lan__lieji"] = "当你使用非装备牌结算结束后，你可以令你手牌中的所有伤害牌的伤害基数+1。",

  ["#lan__lieji-invoke"] = "烈计：令手牌中的伤害牌伤害+1！",
  ["@lan__lieji-inhand"] = "伤害+",

  ["$lan__lieji1"] = "计烈如火，敌将休想逃脱！",
  ["$lan__lieji2"] = "计如风，势如火，烧尽万千逆贼！"
}

lieji:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card.type ~= Card.TypeEquip
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "#lan__lieji-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, id in ipairs(player:getCardIds("h")) do
      local card = Fk:getCardById(id)
      if card.is_damage_card then
        room:addCardMark(card, "@lan__lieji-inhand")
      end
    end
  end,
})

lieji:addEffect(fk.PreCardUse, {
  can_refresh = function (self, event, target, player, data)
    return target == player and data.card:getMark("@lan__lieji-inhand") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    data.additionalDamage = (data.additionalDamage or 0) + data.card:getMark("@lan__lieji-inhand")
  end,
})

-- 当伤害牌离开手牌时清除标记
lieji:addEffect(fk.AfterCardsMove, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.from == player.id then
        for _, info in ipairs(move.moveInfo) do
          local card = Fk:getCardById(info.cardId)
          if card and card:getMark("@lan__lieji-inhand") > 0 then
            return true
          end
        end
      end
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, move in ipairs(data) do
      if move.from == player.id == Card.PlayerHand then
        for _, info in ipairs(move.moveInfo) do
          local card = Fk:getCardById(info.cardId)
          if card and card:getMark("@lan__lieji-inhand") > 0 then
            room:setCardMark(card, "@lan__lieji-inhand", 0)
          end
        end
      end
    end
  end,
})

return lieji
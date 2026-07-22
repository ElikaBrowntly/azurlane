local guose = fk.CreateSkill {
  name = "yyfy_guose",
  tags = { Skill.Compulsory }
}

Fk:loadTranslationTable {
  ["yyfy_guose"] = "国色",
  [":yyfy_guose"] = "锁定技，当你失去<font color='red'>♦</font>牌时，摸一张牌。出牌阶段，你可以将一张<font color='red'>♦</font>牌当【乐不思蜀】使用，或弃置一张<font color='red'>♦</font>牌并弃置场上的一张【乐不思蜀】。",

  ["#yyfy_guose_use"] = "国色：将一张<font color='red'>♦</font>牌当【乐不思蜀】使用",
  ["#yyfy_guose_throw"] = "国色：弃置<font color='red'>♦</font>牌并弃置场上一张【乐不思蜀】",
  ["yyfy_guose_use"] = "使用乐不思蜀",
  ["yyfy_guose_throw"] = "弃置乐不思蜀",

  ["$yyfy_guose1"] = "旅途劳顿，请下马休整吧~",
  ["$yyfy_guose2"] = "还没到休息的时候！",
}

guose:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(guose.name) then return end
    for _, move in ipairs(data) do
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
            return Fk:getCardById(info.cardId).suit == Card.Diamond
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, guose.name)
  end,
})

guose:addEffect("active", {
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  prompt = function(self)
    return "#" .. self.interaction.data
  end,
  can_use = function(self, player)
    return player and player:hasSkill(self)
  end,
  interaction = UI.ComboBox { choices = { "yyfy_guose_use", "yyfy_guose_throw" } },
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 or not self.interaction.data or Fk:getCardById(to_select).suit ~= Card.Diamond then return false end
    if self.interaction.data == "yyfy_guose_use" then
      local card = Fk:cloneCard("indulgence")
      card:addSubcard(to_select)
      return player:canUse(card) and not player:prohibitUse(card)
    else
      return not player:prohibitDiscard(to_select)
    end
  end,
  target_filter = function(self, player, to_select, selected, cards)
    if #cards ~= 1 or #selected > 0 or not self.interaction.data then return false end
    if self.interaction.data == "yyfy_guose_use" then
      local card = Fk:cloneCard("indulgence")
      card:addSubcard(cards[1])
      return to_select ~= player and not player:isProhibited(to_select, card)
    else
      return to_select:hasDelayedTrick("indulgence")
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    if self.interaction.data == "yyfy_guose_use" then
      room:useVirtualCard("indulgence", effect.cards, player, target, guose.name)
    else
      room:throwCard(effect.cards, guose.name, player, player)
      local ids = {}
      for _, id in ipairs(target:getCardIds("j")) do
        local card = target:getVirtualEquip(id) or Fk:getCardById(id)
        if card.name == "indulgence" then
          table.insert(ids, id)
        end
      end
      if #ids > 0 then
        local id = ids[1]
        if #ids > 1 and not player.dead then
          id = room:askToChooseCard(player, {
            target = target,
            flag = { card_data = { { guose.name, ids } } },
            skill_name = guose.name,
          })
        end
        room:throwCard(id, guose.name, target, player)
      end
    end
  end,
})

return guose
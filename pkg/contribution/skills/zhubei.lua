local zhubei = fk.CreateSkill{
  name = "lan__zhubei",
}

Fk:loadTranslationTable{
  ["lan__zhubei"] = "逐北",
  [":lan__zhubei"] = "出牌阶段限两次，你可以选择一名其他角色，令其将至少X张牌当【杀】或【决斗】对你使用（各限一次，"..
  "X为所有角色本回合使用基本牌数+1）。若你以此法受到伤害后，你可以获得伤害牌并摸一张牌；若你未以此法受到伤害，你回复1点体力，然后可以获得其手牌。",

  ["#lan__zhubei"] = "逐北：令一名角色将至少%arg张牌当【杀】或【决斗】对你使用",
  ["#lan__zhubei-use"] = "逐北：请将至少%arg张牌当【杀】或【决斗】对 %src 使用",
  ["#lan__zhubei-obtain"] = "逐北：是否获得 %dest 的所有手牌？",
  ["#lan__zhubei_dalay-invoke"] = "逐北：是否获得造成伤害的牌并摸一张牌？",

  ["$lan__zhubei1"] = "虎踞青兖，欲补薄暮苍天！",
  ["$lan__zhubei2"] = "欲止戈，必先执戈！",
}

zhubei:addEffect("active", {
  anim_type = "control",
  prompt = function (self, player)
    return "#lan__zhubei:::"..(player:getMark("lan__zhubei-phase") + 1)
  end,
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return (player:getMark("lan__zhubei_slash-phase") == 0 or player:getMark("lan__zhubei_duel-phase") == 0) and
      player:usedSkillTimes(self.name, Player.HistoryPhase) < 2
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local choices = {}
    for _, name in ipairs({"slash", "duel"}) do
      if not table.contains(player:getTableMark("lan__zhubei_names-phase"), name) then
        table.insert(choices, name)
      end
    end
    local use = room:askToUseVirtualCard(target, {
      name = choices,
      skill_name = self.name,
      prompt = "#lan__zhubei-use:"..player.id.."::"..(1 + player:getMark("lan__zhubei-phase")),
      cancelable = false,
      extra_data = {
        exclusive_targets = {player.id},
        bypass_distances = true,
        bypass_times = true,
      },
      card_filter = {
        n = { 1 + player:getMark("lan__zhubei-phase"), 999 },
      },
      skip = true,
    })
    if use then
      room:addTableMark(player, "lan__zhubei_names-phase", use.card.trueName)
      use.extra_data = use.extra_data or {}
      use.extra_data.lan__zhubei = player.id
      room:useCard(use)
    end
    if not (use and use.damageDealt and use.damageDealt[player]) then
      if player:isWounded() and not player.dead then
        room:recover{
          who = player,
          num = 1,
          recoverBy = player,
          skillName = self.name,
        }
      end
      -- 修改为单方面获得目标手牌
      if not player.dead and not target.dead and not target:isKongcheng() and
        room:askToSkillInvoke(player, {
          skill_name = self.name,
          prompt = "#lan__zhubei-obtain::"..target.id,
        }) then
        -- 获得目标所有手牌
        local handcards = target:getCardIds(Player.Hand)
        if #handcards > 0 then
          room:moveCards({
            ids = handcards,
            from = target,
            to = player,
            toArea = Card.PlayerHand,
            reason = fk.ReasonPrey,
            skillName = self.name,
          })
        end
      end
    end
  end,
})

zhubei:addEffect(fk.Damaged, {
  anim_type = "masochism",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and data.card and table.contains(data.card.skillNames, self.name) and
      player.room:getCardArea(data.card) == Card.Processing then
      local use_event = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if not use_event then return end
      local use = use_event.data
      return use.extra_data and use.extra_data.lan__zhubei == player.id
    end
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "#lan__zhubei_dalay-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 获得伤害牌
    room:moveCardTo(data.card, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true, player)
    -- 摸一张牌
    player:drawCards(1, self.name)
  end,
})

zhubei:addEffect(fk.AfterCardUseDeclared, {
  can_refresh = function (self, event, target, player, data)
    return player:hasSkill(self.name, true) and data.card.type == Card.TypeBasic
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:addPlayerMark(player, "lan__zhubei-phase", 1)
  end,
})

zhubei:addAcquireEffect(function (self, player, is_start)
  if not is_start then
    local room = player.room
    local n = #room.logic:getEventsOfScope(GameEvent.UseCard, 999, function(e)
      return e.data.card.type == Card.TypeBasic
    end, Player.HistoryTurn)
    room:setPlayerMark(player, "lan__zhubei-phase", n)
  end
end)

zhubei:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "lan__zhubei_names-phase", 0)
end)

return zhubei
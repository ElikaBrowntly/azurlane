local hanbao = fk.CreateSkill {
  name = "yyfy_hanbao"
}

Fk:loadTranslationTable {
  ["yyfy_hanbao"] = "寒暴",
  [":yyfy_hanbao"] = "出牌阶段限一次，你可以弃置你与至多三名其他角色的各一张牌，然后视为对这些角色使用一张不可响应的冰【杀】。"
}

hanbao:addEffect("active", {
  anim_type = "offensive",
  prompt = "寒暴：请弃置一张牌，并选择至多三名其他角色",
  can_use = function(self, player)
    local room = Fk:currentRoom()
    if not (player and player:isAlive() and player:hasSkill(self) and not player:isAllNude() and
          room:getCurrent() == player and player.phase == Player.Play) then
      return false
    end
    return table.find(room.alive_players, function(p)
      return p ~= player and #p:getCardIds("he") > 0
    end) and player:usedSkillTimes(hanbao.name, Player.HistoryPhase) == 0
  end,
  card_num = 1,
  include_equip = true,
  target_filter = function(self, player, to_select, selected, selected_cards, card, extra_data)
    return #selected < 3 and #to_select:getCardIds("he") > 0 and to_select ~= player
  end,
  feasible = function (self, player, selected, selected_cards, card)
    return #selected > 0 and #selected_cards == 1
  end,
  on_use = function(self, room, effect)
    local tos = effect.tos
    local player = effect.from
    if #tos == 0 or #tos > 3 then return end
    local cards = {}
    for _, to in ipairs(tos) do
      local id = room:askToChooseCard(player, {
        target = to,
        flag = "he",
        skill_name = hanbao.name
      })
      table.insert(cards, id)
    end
    room:throwCard(effect.cards, hanbao.name, player, player)
    if player.dead then return end
    for i, id in ipairs(cards) do
      room:throwCard(id, hanbao.name, tos[i], player)
    end
    if player.dead then return end
    tos = table.filter(tos, function(to)
      return to:isAlive() and player:canUseTo(Fk:cloneCard("ice__slash"), to, {
        bypass_distances = true,
        bypass_times = true,
        extraUse = true
      })
    end)
    local card = Fk:cloneCard("ice__slash")
    card.skillName = hanbao.name
    room:useCard({
      from = player,
      card = card,
      tos = tos,
      extraUse = true,
      disresponsiveList = room:getAlivePlayers()
    })
  end
})

return hanbao
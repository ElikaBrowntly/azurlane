local yyfy_kuangmo = fk.CreateSkill {
  name = "yyfy_kuangmo",
}

Fk:loadTranslationTable {
  ["yyfy_kuangmo"] = "狂魔",
  [":yyfy_kuangmo"] = "出牌阶段，你可以指定一名其他角色成为“狂”角色，你对其造成的伤害+1；" ..
      "击败对方后，获得对方所有“炁”。当且仅当“狂”角色死亡后，你重新指定“狂”角色。",

  ["#yyfy_kuangmo"] = "狂魔：指定一名其他角色成为“狂”角色",
  ["@@yyfy_kuangmo"] = "狂",
  ["#yyfy_kuangmo-choose"] = "狂魔：重新选择一名其他角色成为“狂”角色",

  ["$yyfy_kuangmo1"] = "草芥，也配呼吸？",
  ["$yyfy_kuangmo2"] = "哼，蝼蚁，杀了解闷。",
  ["$yyfy_kuangmo3"] = "骄狂纵意，天地唯我！",
}

yyfy_kuangmo:addEffect("active", {
  anim_type = "big",
  prompt = "#yyfy_kuangmo",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:getMark("yyfy_kuangmo_target") == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, cards)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:setPlayerMark(target, "@@yyfy_kuangmo", 1)
    room:setPlayerMark(player, "yyfy_kuangmo_target", target.id)
  end,
})

yyfy_kuangmo:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return player == target and not player.dead and player:getMark("yyfy_kuangmo_target") == data.to.id
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(1)
  end,
})

yyfy_kuangmo:addEffect(fk.Death, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(self) and not player.dead and
        player:getMark("yyfy_kuangmo_target") == target.id
  end,
  on_cost = function(self, event, target, player, data)
    event:setCostData(self, { tos = { player.room:getPlayerById(player:getMark("yyfy_kuangmo_target")) } })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = {}
    local winner = nil
    if data.damage and data.damage.from == player then
      winner = player
      cards = player:getTableMark("duoqi_record")[tostring(target.id)]
    end
    if winner and cards then
      --实测先获得牌堆+弃牌堆里的所有炁，再获得所有角色的区域里的炁，不同reason的move是不会同时进行的
      local to_get = table.filter(room.discard_pile, function(id)
        return table.contains(cards, id)
      end)
      table.insertTable(to_get, table.filter(room.draw_pile, function(id)
        return table.contains(cards, id)
      end))
      if #to_get > 0 then
        room:obtainCard(winner, to_get, false, fk.ReasonJustMove, winner, yyfy_kuangmo.name)
      end
      if not winner.dead then
        local handcards = winner:getCardIds("h")
        local player_places = { Card.PlayerHand, Card.PlayerEquip, Card.PlayerJudge }
        to_get = table.filter(cards, function(id)
          return not table.contains(handcards, id) and table.contains(player_places, room:getCardArea(id))
        end)
        if #to_get > 0 then
          room:obtainCard(winner, to_get, false, fk.ReasonPrey, winner, yyfy_kuangmo.name)
        end
      end
    end
    if player ~= target then
      local tos = room:getOtherPlayers(player, false)
      if #tos > 0 then
        tos = room:askToChoosePlayers(player, {
          min_num = 1,
          max_num = 1,
          targets = tos,
          skill_name = yyfy_kuangmo.name,
          prompt = "#yyfy_kuangmo-choose",
          cancelable = false,
        })
        room:setPlayerMark(tos[1], "@@yyfy_kuangmo", 1)
        room:setPlayerMark(player, "yyfy_kuangmo_target", tos[1].id)
      end
    end
  end,
})

yyfy_kuangmo:addLoseEffect(function(self, player, is_death)
  local room = player.room
  if player:getMark("yyfy_kuangmo_target") ~= 0 then
    local to = room:getPlayerById(player:getMark("yyfy_kuangmo_target"))
    room:setPlayerMark(player, "yyfy_kuangmo_target", 0)
    if to and not to.dead then
      if table.every(room.alive_players, function(p)
            return p:getMark("yyfy_kuangmo_target") ~= to.id
          end) then
        room:setPlayerMark(to, "@@yyfy_kuangmo", 0)
      end
    end
  end
end)

--FIXME:缺死亡清理（线上也没做，先摆）

return yyfy_kuangmo
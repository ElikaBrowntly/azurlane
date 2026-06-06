local jinglue = fk.CreateSkill {
  name = "lan__jinglue"
}

Fk:loadTranslationTable {
  ["lan__jinglue"] = "景略",
  [":lan__jinglue"] = "出牌阶段限一次，你可观看一名其他角色的手牌，将其中一张牌标记为“死士”。"
      .. "当其使用此“死士”牌时，你令此牌无效；其回合结束时，你获得此“死士”牌。",

  ["#lan__jinglue"] = "景略:观看一名其他角色的手牌，将其中一张牌标记为“死士”",

  ["$lan__jinglue1"] = "尔等暂且不麾不动，来日必有奇用。",
  ["$lan__jinglue2"] = "吾尽用间之谋，亦极用人之要。",
}

jinglue:addEffect("active", {
  anim_type = "control",
  prompt = "#lan__jinglue",
  can_use = function(self, player)
    return player:usedSkillTimes(jinglue.name, Player.HistoryPhase) == 0
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  target_num = 1,
  target_filter = function(self, player, to_select, selected)
    return #selected < 1 and to_select ~= player and not to_select:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local cid = room:askToChooseCard(player, {
      target = target,
      flag = { card_data = { { "$Hand", target:getCardIds("h") } } },
      skill_name = jinglue.name
    })
    room:setCardMark(Fk:getCardById(cid), "lan__sishi", { target.id, player.id })
    room:addTableMark(player, "lan__sanshi", cid)
    room:addTableMark(target, "lan__jinglue"..tostring(player.id), cid)
  end,
})

jinglue:addEffect(fk.CardUsing, {
  is_delay_effect = true,
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    local mark
    for _, id in ipairs(Card:getIdList(data.card)) do
      if Fk:getCardById(id):getMark("lan__sishi") ~= 0 then
        if not mark then
          mark = Fk:getCardById(id):getMark("lan__sishi")
        elseif mark ~= Fk:getCardById(id):getMark("lan__sishi") then
          return false
        end
      else
        return false
      end
    end
    return mark and mark[1] == target.id and mark[2] == player.id
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player, { target })
    data.toCard = nil
    data:removeAllTargets()
  end,
})

jinglue:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return #target:getTableMark("lan__jinglue"..tostring(player.id)) > 0 and player:isAlive()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local mark = target:getTableMark("lan__jinglue"..tostring(player.id))
    room:setPlayerMark(target, "lan__jinglue"..tostring(player.id), 0)
    if #mark > 0 then
      room:obtainCard(player, mark, true, fk.ReasonPrey, player, jinglue.name)
    end
  end,
})

return jinglue
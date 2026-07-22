local zelie = fk.CreateSkill {
  name = "lan__zelie",
  tags = { Skill.Family },
}

Fk:loadTranslationTable {
  ["lan__zelie"] = "泽烈",
  [":lan__zelie"] = "宗族技，当一名同族角色失去一个区域内的最后一张牌后，你可以令一名角色本回合下一次摸牌后再摸一张牌、令一名角色本回合下一次弃牌后再弃一张牌。",

  ["#lan__zelie-draw"] = "泽烈：你可以令一名角色本回合下次摸牌后再摸一张牌",
  ["#lan__zelie-dis"] = "泽烈：你可以令一名角色本回合下次弃牌后再弃一张牌",
  ["@lan__zelie_draw-turn"] = "泽烈 摸牌",
  ["@lan__zelie_discard-turn"] = "泽烈 弃牌",
}

local U = require "packages.utility.utility"

zelie:addEffect(fk.AfterCardsMove, {
  anim_type = "control",
  trigger_times = function(self, event, target, player, data)
    local tos = {}
    if player:hasSkill(zelie.name) then
      for _, move in ipairs(data) do
        if move.from and U.FamilyMember(player, move.from) then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand and #move.from:getCardIds("h") == 0 or
                info.fromArea == Card.PlayerEquip and #move.from:getCardIds("e") == 0 or
                info.fromArea == Card.PlayerJudge and #move.from:getCardIds("j") == 0 then
              table.insertIfNeed(tos, move.from)
            end
          end
        end
      end
    end
    return #tos
  end,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zelie.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      targets = room:getAlivePlayers(),
      min_num = 1,
      max_num = 1,
      cancelable = true,
      skill_name = zelie.name,
      prompt = "#lan__zelie-draw"
    })
    if to and #to == 1 then
      room:addPlayerMark(to[1], "@lan__zelie_draw-turn")
    end
    to = room:askToChoosePlayers(player, {
      targets = room:getAlivePlayers(),
      min_num = 1,
      max_num = 1,
      cancelable = true,
      skill_name = zelie.name,
      prompt = "#lan__zelie-dis"
    })
    if not to or #to ~= 1 then return end
    room:addPlayerMark(to[1], "@lan__zelie_discard-turn")
  end,
})

zelie:addEffect(fk.AfterCardsMove, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if player:getMark("@lan__zelie_draw-turn") > 0 then
      for _, move in ipairs(data) do
        if move.to == player and move.moveReason == fk.ReasonDraw then
          return true
        end
      end
    end
    if player:getMark("@lan__zelie_discard-turn") > 0 then
      for _, move in ipairs(data) do
        if move.from == player and move.moveReason == fk.ReasonDiscard then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = {}
    for _, move in ipairs(data) do
      if move.to == player and move.moveReason == fk.ReasonDraw then
        table.insertIfNeed(choices, "draw")
      end
      if move.from == player and move.moveReason == fk.ReasonDiscard then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
            table.insertIfNeed(choices, "discard")
          end
        end
      end
    end
    if player:getMark("@lan__zelie_draw-turn") > 0 and table.contains(choices, "draw") then
      local n = player:getMark("@lan__zelie_draw-turn")
      room:setPlayerMark(player, "@lan__zelie_draw-turn", 0)
      player:drawCards(n, zelie.name)
      if player.dead then return end
    end
    if player:getMark("@zelie_discard-turn") > 0 and table.contains(choices, "discard") then
      local n = player:getMark("@lan__zelie_discard-turn")
      room:setPlayerMark(player, "@lan__zelie_discard-turn", 0)
      room:askToDiscard(player, {
        min_num = n,
        max_num = n,
        include_equip = true,
        skill_name = zelie.name,
        cancelable = false,
      })
    end
  end,
})

return zelie
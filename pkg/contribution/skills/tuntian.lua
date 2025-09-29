local tuntian = fk.CreateSkill {
  name = "lan__tuntian",
  derived_piles = "lan__dengai_field",
}

Fk:loadTranslationTable {
  ["lan__tuntian"] = "屯田",
  [":lan__tuntian"] = "当你于回合外失去牌，或回合内弃置牌后，你可以将牌堆顶一张牌置于你的武将牌上，称为“田”，"
  .."然后你可以立即发动一次〖急袭〗；你计算与其他角色的距离-X且你的手牌上限+X（X为“田”的数量）。",

  ["lan__dengai_field"] = "田",

  ["$lan__tuntian1"] = "兵农一体，以屯养战。",
  ["$lan__tuntian2"] = "垦田南山，志在西川。",
}

tuntian:addEffect(fk.AfterCardsMove, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(tuntian.name) then
      if player.room.current == player then
        -- 回合内：弃置牌
        for _, move in ipairs(data) do
          if move.from == player and move.moveReason == fk.ReasonDiscard then
            return true
          end
        end
      else
        -- 回合外：失去牌
        for _, move in ipairs(data) do
          if move.from == player and (move.to ~= player or (move.toArea ~= Card.PlayerHand and move.toArea ~= Card.PlayerEquip)) then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                return true
              end
            end
          end
        end
      end
    end
    return false
  end,
  on_cost = function (self, event, target, player)
    return player.room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "屯田：你可以将牌堆顶一张牌置于你的武将牌上，称为“田”"
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 将牌堆顶一张牌置于"田"中
    local card = room:getNCards(1)[1]
    if card then
      player:addToPile("lan__dengai_field", card, true, self.name, player)
    end
    if #player:getPile("lan__dengai_field") then
      room:askToUseActiveSkill(player, {
        skill_name = "lan__jixi",
        prompt = "屯田：你可以立即发动一次〖急袭〗"
      })
    end
  end,
})

-- 与其他角色的距离-X
tuntian:addEffect("distance", {
  correct_func = function(self, from, to)
    if from:hasSkill(tuntian.name) and from ~= to then
      return -#from:getPile("lan__dengai_field")
    end
  end,
})

-- 手牌上限+X
tuntian:addEffect("maxcards", {
  correct_func = function(self, player)
    if player:hasSkill(tuntian.name) then
      return #player:getPile("lan__dengai_field")
    end
  end,
})

return tuntian
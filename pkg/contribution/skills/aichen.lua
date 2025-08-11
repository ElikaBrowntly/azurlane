local aichen = fk.CreateSkill {
  name = "lan_aichen",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["lan_aichen"] = "哀尘",
  [":lan_aichen"] = "锁定技，若牌堆中的牌数：大于80，每当你区域内的牌被弃置后，"
  .."你可以摸两张牌；大于40，你跳过弃牌阶段。",

  ["$lan_aichen1"] = "君可负妾，然妾不负君。",
  ["$lan_aichen2"] = "所思所想，皆系陛下。",
}

-- 牌堆>80
aichen:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    local room = player.room
    local drawPileSize = #room.draw_pile
    
    if not player:hasSkill(aichen.name) or drawPileSize <= 80 then
      return false
    end
    
    for _, move in ipairs(data) do
      if move.from and move.from == player and move.moveReason==fk.ReasonDiscard then
        return true
      end
    end
    return false
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "哀尘：是否要摸2张牌？"
    })
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, aichen.name)
  end,
})

-- 牌堆>40
aichen:addEffect(fk.EventPhaseChanging, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(aichen.name) and #player.room.draw_pile > 40 and
      data.phase == Player.Discard and not data.skipped
  end,
  on_use = function(self, event, target, player, data)
    data.skipped = true
  end,
})

return aichen
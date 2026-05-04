local QC_jishi = fk.CreateSkill{
  name = "QC_jishi",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["QC_jishi"] = "济世",
  [":QC_jishi"] = "持恒技，游戏开始和你的回合开始时，你获得3个“药”标记。当有角色濒死时，你可以移除1个“药”，使其回复至1点体力。当你失去红色牌时，获得等量“药”。你的手牌上限+X（X为你“药”的数量）。",
  ["@QC_jishi"] = "药",
  ["#QC_jishi-ask"] = "济世：你可以移除1个“药”，令 %dest 回复至1点体力",
}

QC_jishi:addEffect(fk.GameStart, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(QC_jishi.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@QC_jishi", 3)
  end,
})

QC_jishi:addEffect(fk.TurnStart, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(QC_jishi.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@QC_jishi", 3)
  end,
})

QC_jishi:addEffect(fk.EnterDying, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(QC_jishi.name) and player:getMark("@QC_jishi") > 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = QC_jishi.name,
      prompt = "#QC_jishi-ask::"..target.id,
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:removePlayerMark(player, "@QC_jishi", 1)
    room:recover{
      who = target,
      num = 1 - target.hp,
      recoverBy = player,
      skillName = QC_jishi.name,
    }
  end,
})

QC_jishi:addEffect(fk.AfterCardsMove, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) then
      local x = 0
      for _, move in ipairs(data) do
        if move.from == player then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand and Fk:getCardById(info.cardId).color == Card.Red then
              x = x + 1
            end
          end
        end
      end
      if x > 0 then
        event:setCostData(self, { x = x })
        return true
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@QC_jishi", event:getCostData(self).x)
  end,
})

QC_jishi:addEffect("maxcards", {
  correct_func = function(self, player)
    if player:hasSkill(QC_jishi.name) then
      return tonumber(player:getMark("@QC_jishi"))
    end
  end,
})

return QC_jishi
local huiliuli = fk.CreateSkill {
  name = "yyfy_hui",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable{
  ["yyfy_hui"] = "灰流丽",
  [":yyfy_hui"] = "持恒技，其他角色在摸牌阶段外，即将从牌堆或处理区获得牌时，你可以取消之。"
}

-- huiliuli:addLoseEffect(function(self, player, is_death)
--   player.room:handleAddLoseSkills(player, self.name, nil, false, true)
-- end)

huiliuli:addEffect(fk.BeforeCardsMove, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, datas)
    if not (player and player:hasSkill(self.name)) then return false end
    local current = player.room.current
    if current and current.phase == Player.Draw then return false end
    local ids = {}
    for _, data in ipairs(datas) do
      if data.to and data.to ~= player then
        for _, info in ipairs(data.moveInfo) do
          if info.fromArea == Card.DrawPile or info.fromArea == Card.Processing then
            table.insertIfNeed(ids, info.cardId)
            if not event:getCostData(self) then
              event:setCostData(self, {tos = {data.to}})
            end
          end
        end
      end
    end
    if #ids > 0 then
      local cost = event:getCostData(self) or {}
      cost.cards = ids
      event:setCostData(self, cost)
      return true
    end
    return false
  end,
  on_cost = function (self, event, target, player, data)
    local cost = event:getCostData(self)
    local room = player.room
    if not cost or not cost.tos then return false end
    local to = cost.tos[1]
    room:setPlayerMark(player, "yyfy_hui-ai", to.id)
    return room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "灰流丽：%dest 即将从牌堆获得牌，是否取消之？::"..to.id
    })
  end,
  on_use = function (self, event, target, player, data)
    local cost = event:getCostData(self)
    if cost and cost.cards then
      player.room:cancelMove(data, cost.cards)
    end
  end
})

huiliuli:addAI(Fk.Ltk.AI.newInvokeStrategy{
  think = function(self, ai)
    local room = ai.room
    local id = ai.player:getMark("yyfy_hui-ai")
    if id == 0 then return false end
    local target = room:getPlayerById(id)
    return target and ai:isEnemy(target)
  end,
})

return huiliuli
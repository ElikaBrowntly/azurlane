local huiliuli = fk.CreateSkill {
  name = "yyfy_hui",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable{
  ["yyfy_hui"] = "灰流丽",
  [":yyfy_hui"] = "永恒技，其他角色在摸牌阶段外，即将从牌堆或处理区获得牌时，你可以取消之。"
}

-- 永恒技：失去此技能时重新添加
huiliuli:addLoseEffect(function(self, player, is_death)
  player.room:handleAddLoseSkills(player, self.name, nil, false, true)
end)

huiliuli:addEffect(fk.BeforeCardsMove, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, datas)
    local ids = {}
    if player and player:hasSkill(self.name) and player.room:getCurrent().phase ~= Player.Draw then
      for _, data in ipairs(datas) do
        for _, info in ipairs(data.moveInfo) do
          if data.to and data.to ~= player and
          (info.fromArea == Card.DrawPile or info.fromArea == Card.Processing) then
            table.insertIfNeed(ids, info.cardId)
            event:setCostData(self, {tos = {data.to}})
          return true end
        end
      end
    end
    if ids ~= nil then
      event:setCostData(self, {cards = ids})
      return true
    end
  end,
  on_cost = function (self, event, target, player, data)
    if event:getCostData(self).tos == nil then return false end
    return player.room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "灰流丽： %dest 即将从牌堆获得牌，是否取消之？::"..event:getCostData(self).tos[1].id
    })
  end,
  on_use = function (self, event, target, player, data)
    player.room:cancelMove(data, event:getCostData(self).cards)
  end
})

return huiliuli
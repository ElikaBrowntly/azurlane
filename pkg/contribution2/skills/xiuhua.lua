local yyfy_xiuhua = fk.CreateSkill {
  name = "yyfy_xiuhua",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["yyfy_xiuhua"] = "羞花",
  [":yyfy_xiuhua"] = "锁定技，当你获得其他角色的牌后，你摸等量的牌；其他角色获得你的牌后，其弃置等量的牌。",
}

yyfy_xiuhua:addEffect(fk.AfterCardsMove, {
  anim_type = "support",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and not event:getSkillData(self, "processing") and table.find(data, function (move)
      return move.to and move.from and move.toArea and table.contains({move.to, move.from}, player)
      and move.toArea == Card.PlayerHand
    end)
  end,
  on_cost = function(self, event, target, player, data)
    event:setSkillData(self, "processing", true)
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, move in ipairs(data) do
      -- 情况1：player 获得其他角色的牌（移至 player 手牌区）
      if move.to == player and move.toArea == Card.PlayerHand and move.from and move.from ~= player then
        local n = #move.moveInfo
        if n > 0 then
          player:drawCards(n, self.name)
        end
      end
      -- 情况2：其他角色获得 player 的牌（移至该角色手牌区）
      if move.from == player and move.to and move.to ~= player and move.toArea == Card.PlayerHand then
        local n = #move.moveInfo
        if n > 0 then
          room:askToDiscard(move.to, {
            min_num = n,
            max_num = n,
            skill_name = yyfy_xiuhua.name,
            prompt = "羞花：请弃置"..tostring(n).."张牌",
            cancelable = false
          })
        end
      end
    end
  end,
})

return yyfy_xiuhua
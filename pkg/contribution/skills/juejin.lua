local lan__juejin = fk.CreateSkill {
  name = "lan__juejin",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["lan__juejin"] = "决进",
  [":lan__juejin"] = "持恒技，其他角色使用【闪】【桃】【酒】时，你可以令其无效",

  ["#lan__juejin-invalid"] = "决进：是否令 %arg 的使用无效？",
  ["#lan__juejin-effect"] = "%from 的「决进」效果触发，%arg 的使用无效",

  ["$lan__juejin1"] = "朕宁拼一死，逆贼安敢一战！",
  ["$lan__juejin2"] = "朕安可坐受废辱，今日当与卿自出讨之！",
}

lan__juejin:addEffect(fk.CardUsing, {
  can_trigger = function(self, event, target, player, data)
    local cardName = data.card.trueName
    return player and player:hasSkill(self.name) and target ~= player and
           (cardName == "jink" or cardName == "peach" or cardName == "analeptic")
  end,
  on_cost = function(self, event, target, player, data)    
    return player.room:askToSkillInvoke(player, {
      skill_name = lan__juejin.name,
      prompt = "#lan__juejin-invalid:::"..data.card:toLogString(),
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 令牌的使用无效
    room:sendLog{
      type = "#lan__juejin-effect",
      from = player.id,
      arg = data.card:toLogString(),
    }
    data.nullifiedTargets = room:getAlivePlayers()
    return true
  end,
})

return lan__juejin
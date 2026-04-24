local qizhen = fk.CreateSkill {
  name = "yyfy_qizhen",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["yyfy_qizhen"] = "奇阵",
  [":yyfy_qizhen"] = "锁定技，若你的手牌均不为黑色，你无法成为伤害锦囊牌的目标；若你的手牌均不为红色，" ..
      "你无法成为【杀】的目标。若你使用牌后黑色手牌与红色手牌相等，则你发动一次〖观星〗并摸一张牌。",

  ["$yyfy_qizhen1"] = "天地协力，止戈为武，九鼎合归奉云台。",
  ["$yyfy_qizhen2"] = "王师北定，山河重整，万民争迎汉家来。"
}

qizhen:addEffect("prohibit", {
  is_prohibited = function(self, from, to, card)
    local not_black = table.find(to:getCardIds("h"), function(c)
      return Fk:getCardById(c).color == Card.Black
    end) == nil
    local not_red = table.find(to:getCardIds("h"), function(c)
      return Fk:getCardById(c).color == Card.Red
    end) == nil
    return card and from and to and to:hasSkill(self.name) and (card.trueName == "slash" and not_red
      or card.is_damage_card and card.type == Card.TypeTrick and not_black)
  end,
})

qizhen:addEffect(fk.CardUseFinished, {
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self)) then return false end
    local black = 0
    local red = 0
    for _, c in ipairs(player:getCardIds()) do
      local color = Fk:getCardById(c).color
      if color == Card.Black then
        black = black + 1
      end
      if color == Card.Red then
        red = red + 1
      end
    end
    return black == red
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, "ex__guanxing")
    player:broadcastSkillInvoke("ex__guanxing")
    room:askToGuanxing(player, {
      cards = room:getNCards(#room.alive_players < 4 and 3 or 5),
      skill_name = "ex__guanxing"
    })
    player:addSkillUseHistory("ex__guanxing", 1)
    room:drawCards(player, 1, qizhen.name)
  end
})

return qizhen

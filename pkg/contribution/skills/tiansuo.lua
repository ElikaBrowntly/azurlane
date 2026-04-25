local tiansuo = fk.CreateSkill{
  name = "yyfy_tiansuo",
  tags = { Skill.Compulsory, Skill.Switch }
}

Fk:loadTranslationTable {
  ["yyfy_tiansuo"] = "天锁",
  [":yyfy_tiansuo"] = "锁定技，转换技，当你使用牌后，所有角色在本回合内不能使用，阳：黑色手牌；阴：红色手牌，直到此转换技转换。",

  ["yyfy_tiansuo_red-turn"] = "天锁 红",
  ["yyfy_tiansuo_black-turn"] = "天锁 黑",
  ["$yyfy_tiansuo1"] = "六道锁凡尘，死生皆如逆旅。",
  ["$yyfy_tiansuo2"] = "命数如织网，无人不坠因果。"
}

tiansuo:addEffect(fk.CardUseFinished, {
  can_trigger = function (self, event, target, player, data)
    return data.from == player and player:hasSkill(self)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local mark1 = "yyfy_tiansuo_black-turn"
    local mark2 = "yyfy_tiansuo_red-turn"
    if player:getSwitchSkillState(tiansuo.name, true) == 1 then
      mark1 = "yyfy_tiansuo_red-turn"
      mark2 = "yyfy_tiansuo_black-turn"
    end
    room:setPlayerMark(player, mark1, 1)
    room:setPlayerMark(player, mark2, 0)
  end
})

tiansuo:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    local room = Fk:currentRoom()
    local red = table.find(room.alive_players, function (p)
      return p ~= player and p:getMark("yyfy_tiansuo_red-turn") > 0 and p:hasSkill(tiansuo.name)
    end) and true or false
    local black = table.find(room.alive_players, function (p)
      return p ~= player and p:getMark("yyfy_tiansuo_black-turn") > 0 and p:hasSkill(tiansuo.name)
    end) and true or false
    return card.color == Card.Red and red or card.color == Card.Black and black
  end
})

return tiansuo
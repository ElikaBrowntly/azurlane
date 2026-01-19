local zhaifeng = fk.CreateSkill {
  name = "yyfy_zhaifeng",
}

Fk:loadTranslationTable{
  ["yyfy_zhaifeng"] = "摘锋",
  [":yyfy_zhaifeng"] = "当你造成伤害时，你可选择一项：1.令此伤害-1；2.摸一张牌。"..
  "背水：失去一点体力，本回合你使用【杀】的次数+1。",

  ["yyfy_zhaifeng-damage"] = "此伤害+1",
  ["yyfy_zhaifeng-draw"] = "摸1张牌",
  ["yyfy_zhaifeng-both"] = "背水",
  
  ["$yyfy_zhaifeng1"] = "鸣鼓净街魑魅退，擂瓮升堂罪何人！",
  ["$yyfy_zhaifeng2"] = "巡界奔走双甲子，归来两界又一秋。"
}

zhaifeng:addEffect(fk.DamageCaused, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_cost = function(self, event, target, player, data)
    local choice = player.room:askToChoice(player, {
      skill_name = self.name,
      choices = {"yyfy_zhaifeng-damage", "yyfy_zhaifeng-draw", "yyfy_zhaifeng-both", "Cancel"},
    })
    if choice ~= "Cancel" then
      event:setCostData(self, {choice = choice})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice
    if choice == "yyfy_zhaifeng-damage" then
      data:changeDamage(1)
    elseif choice == "yyfy_zhaifeng-draw" then
      room:drawCards(player, 1, self.name)
    else
      data:changeDamage(1)
      room:drawCards(player, 1, self.name)
      room:loseHp(player, 1, self.name, player)
      room:addPlayerMark(player, "yyfy_zhaifeng-turn")
    end
  end,
})

zhaifeng:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope)
    if player:getMark("yyfy_zhaifeng-turn") > 0 and skill.trueName == "slash_skill" and scope == Player.HistoryPhase then
      return player:getMark("yyfy_zhaifeng-turn")
    end
  end,
})

return zhaifeng

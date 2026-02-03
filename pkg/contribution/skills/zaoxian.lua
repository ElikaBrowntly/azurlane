local zaoxian = fk.CreateSkill {
  name = "lan__zaoxian",
}

Fk:loadTranslationTable {
  ["lan__zaoxian"] = "凿险",
  [":lan__zaoxian"] = "每名角色的非额外回合结束时，若你的“田”数量不小于3，你可以获得一个额外回合。",

  ["$lan__zaoxian1"] = "良田厚土，足平蜀道之难！",
  ["$lan__zaoxian2"] = "效仿五丁开川，赢粮直捣黄龙！",
}

zaoxian:addEffect(fk.TurnEnd, {
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(self.name) and #player:getPile("lan__dengai_field") >= 3
    and data.reason == "game_rule"
  end,
  on_use = function(self, event, target, player, data)
    if player.dead then return end
    player:gainAnExtraTurn()
  end,
})

return zaoxian
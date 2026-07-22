local shanshen = fk.CreateSkill {
  name = "lan__shanshen",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable {
  ["lan__shanshen"] = "善身",
  [":lan__shanshen"] = "持恒技，当一名其他角色受到伤害时，你可以回复1点体力。",

  ["$lan__shanshen1"] = "好善为德，坚守本心。",
  ["$lan__shanshen2"] = "洁身自爱，独善其身。",
  ["$lan__shanshen3"] = "人家只想做安安静静的小淑女。"
}

shanshen:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player and player:hasSkill(shanshen.name) and player:isWounded()
  end,
  on_use = function(self, event, target, player, data)
    player.room:recover {
      who = player,
      num = 1,
      recoverBy = player,
      skillName = shanshen.name,
    }
  end,
})

return shanshen
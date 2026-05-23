local feijiang = fk.CreateSkill {
  name = "lan__feijiang",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["lan__feijiang"] = "飞将",
  [":lan__feijiang"] = "锁定技，首轮开始时，你执行额外的回合。",

  ["$lan__feijiang1"] = "大好天下，皆为我驰骋之处！",
  ["$lan__feijiang2"] = "竖子好胆，竟敢与我比肩!"
}

feijiang:addEffect(fk.RoundStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player.room:getBanner("RoundCount") == 1
  end,
  on_use = function(self, event, target, player, data)
    player:gainAnExtraTurn()
  end,
})

return feijiang
local fenghuang = fk.CreateSkill{
  name = "yyfy_fenghuang",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["yyfy_fenghuang"] = "凤凰",
  [":yyfy_fenghuang"] = "其他角色与你的距离+10，你不是其他角色使用牌的合法目标。此化身结束时，你失去1点体力。",
}

fenghuang:addEffect("distance", {
  correct_func = function(self, from, to)
    if to:hasSkill(self.name) then
      return 10
    end
  end,
})

fenghuang:addEffect("prohibit", {
  is_prohibited = function(self, from, to, card)
    return card and from and to and from ~= to and to:hasSkill(self.name)
  end,
})

fenghuang:addLoseEffect(function (self, player, is_death)
  player.room:loseHp(player, 1, fenghuang.name, player)
end)

return fenghuang
local skill = fk.CreateSkill {
  name = "yyfy_xingzhishanshuo",
}

Fk:loadTranslationTable {
  ["yyfy_xingzhishanshuo"] = "星之闪烁",
  [":yyfy_xingzhishanshuo"] = "你受到蓄力技的伤害后，获得3点蓄力点，此后你的蓄力技伤害增加15%，可叠加。",
}

local U = require "packages/utility/utility"

skill:addEffect(fk.Damaged, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.skillName and
    Fk.skills[data.skillName] and Fk.skills[data.skillName]:hasTag(Skill.Charge)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    U.skillCharged(player, 3)
    player.room:addPlayerMark(player, skill.name)
  end
})

skill:addEffect(fk.DamageCaused, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:getMark(skill.name) > 0
    and data.skillName and Fk.skills[data.skillName] and Fk.skills[data.skillName]:hasTag(Skill.Charge)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    data:changeDamage(math.ceil(player:getMark(skill.name) * 0.15 * data.damage))
  end
})

return skill
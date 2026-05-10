local pengzhang = fk.CreateSkill {
  name = "yyfy_fanshipengzhang",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable {
  ["yyfy_fanshipengzhang"] = "范式膨胀",
  [":yyfy_fanshipengzhang"] = "持恒技，敌方角色造成大于1的伤害后，你令你下一次伤害增加超出部分的值。",

  ["@yyfy_fanshipengzhang"] = "范式膨胀"
}

local F = require "packages.hidden-clouds.functions"

pengzhang:addEffect(fk.Damage, {
  can_trigger = function (self, event, target, player, data)
    return target and player and player:hasSkill(self) and F.isEnemy(player, target) and data.damage > 1
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:addPlayerMark(player, "@yyfy_fanshipengzhang", data.damage - 1)
  end
})

pengzhang:addEffect(fk.DamageCaused, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:getMark("@yyfy_fanshipengzhang") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    data:changeDamage(player:getMark("@yyfy_fanshipengzhang"))
    player.room:setPlayerMark(player, "@yyfy_fanshipengzhang", 0)
  end
})

return pengzhang
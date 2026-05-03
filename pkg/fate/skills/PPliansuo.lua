local liansuo = fk.CreateSkill({
  name = "yyfy_PPliansuo",
  tags = { Skill.Permanent },
})

Fk:loadTranslationTable {
  ["yyfy_PPliansuo"] = "PP连锁",
  [":yyfy_PPliansuo"] = "持恒技，敌方角色的回合结束时，若此时总计已经过3个敌方回合，你将蓄力点增加至上限。"
}

local U = require "packages/utility/utility"
local F = require "packages.hidden-clouds.functions"

liansuo:addEffect(fk.TurnEnd, {
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player and player:hasSkill(self) and F.isEnemy(player, target)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local count = player.tag[liansuo.name] or 0
    player.tag[liansuo.name] = count + 1
    if count > 1 then
      U.skillCharged(player, player:getMark("skill_charge_max"), 0)
    end
  end
})

return liansuo
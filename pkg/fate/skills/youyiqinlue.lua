local qinlue = fk.CreateSkill({
  name = "yyfy_youyiqinlue",
  tags = { Skill.Permanent },
})

Fk:loadTranslationTable {
  ["yyfy_youyiqinlue"] = "优异的侵略",
  [":yyfy_youyiqinlue"] = "持恒技，敌方角色的回合结束时，所有敌方角色减1点体力上限。"
}

local F = require "packages.hidden-clouds.functions"

qinlue:addEffect(fk.TurnEnd, {
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player and player:hasSkill(self) and F.isEnemy(player, target)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getAlivePlayers()) do
      if F.isEnemy(player, p) then
        room:changeMaxHp(p, -1)
      end
    end
  end
})

return qinlue
local danti = fk.CreateSkill({
  name = "yyfy_yinhedanti",
  tags = { Skill.Permanent },
})

Fk:loadTranslationTable {
  ["yyfy_yinhedanti"] = "银河单体",
  [":yyfy_yinhedanti"] = "持恒技，敌方角色的回合结束时，你对所有敌方角色造成1点伤害，并令其减1点体力上限。"
}

local F = require "packages.hidden-clouds.functions"

danti:addEffect(fk.TurnEnd, {
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player and player:hasSkill(self) and F.isEnemy(player, target)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getAlivePlayers()) do
      if F.isEnemy(player, p) then
        room:damage({
          from = player,
          to = p,
          damage = 1,
          skillName = danti.name
        })
        room:changeMaxHp(p, -1)
      end
    end
  end
})

return danti
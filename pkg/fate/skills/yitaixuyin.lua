---@diagnostic disable: param-type-mismatch
local xuyin = fk.CreateSkill({
  name = "yyfy_yitaixuyin",
  tags = { Skill.Permanent },
})

Fk:loadTranslationTable {
  ["yyfy_yitaixuyin"] = "以太酗饮",
  [":yyfy_yitaixuyin"] = "持恒技，每2个敌方回合结束后，有50%概率令所有敌方角色失去2点蓄力点。"..
  "其他角色一次性失去至少2点蓄力点时，你获得1点蓄力点。"
}

local U = require "packages/utility/utility"
local F = require "packages.hidden-clouds.functions"

xuyin:addEffect(fk.TurnEnd, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player and player:hasSkill(self) and F.isEnemy(player, target)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local count = player.tag[xuyin.name] or 0
    player.tag[xuyin.name] = count + 1
    if player.tag[xuyin.name] % 2 == 1 or math.random(2) == 2 then return end
    for _, p in ipairs(player.room:getAlivePlayers()) do
      if F.isEnemy(player, p) then
        U.skillCharged(p, -2, 0)
      end
    end
  end
})

xuyin:addEffect(U.SkillChargeChanged, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and data.num < -1 and player and player:hasSkill(self)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    U.skillCharged(player, 1, 0)
  end
})

return xuyin
---@diagnostic disable: param-type-mismatch
local xinxing = fk.CreateSkill({
  name = "yyfy_shiluoxinxing",
  tags = { Skill.Charge },
})

Fk:loadTranslationTable {
  ["yyfy_shiluoxinxing"] = "失落新星",
  [":yyfy_shiluoxinxing"] = "蓄力技（0/5），敌方角色回合结束时，你获得1点蓄力点。" ..
      "你可以消耗5点蓄力点，对所有敌方角色造成2点伤害，然后令这些角色无法获得蓄力点。",
  ["$yyfy_shiluoxinxing1"] = "失落的超新星",
  ["$yyfy_shiluoxinxing2"] = "失落的超新星",
  ["@@yyfy_shiluoxinxing"] = "失落新星"
}

local U = require "packages/utility/utility"
local F = require "packages.hidden-clouds.functions"

xinxing:addEffect("active", {
  prompt = "失落的超新星：你可以消耗5点蓄力点，对所有敌方角色造成2点伤害",
  anim_type = "big",
  card_num = 0,
  can_use = function(self, player)
    return player:getMark("skill_charge") >= 5
  end,
  target_num = 0,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local targets = table.filter(room:getOtherPlayers(player), function(p)
      return p:isAlive() and F.isEnemy(player, p)
    end)
    -- 消耗5点蓄力点
    U.skillCharged(player, -5)
    -- 计算基础伤害和额外伤害
    -- 造成伤害
    for _, target in ipairs(targets) do
      room:damage {
        from = player,
        to = target,
        damage = 2,
        damageType = fk.NormalDamage,
        skillName = self.name,
      }
      room:addPlayerMark(target, "@@yyfy_shiluoxinxing")
    end
  end,
})

xinxing:addEffect(fk.TurnEnd, {
  can_trigger = function (self, event, target, player, data)
    return target ~= player and player and player:hasSkill(self) and F.isEnemy(player, target)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    U.skillCharged(player, 1)
  end
})

-- 技能获得时初始化蓄力点
xinxing:addAcquireEffect(function(self, player)
  U.skillCharged(player, 0, 5)
end)

-- 技能失去时移除蓄力点
xinxing:addLoseEffect(function(self, player)
  U.skillCharged(player, 0, -5)
end)

xinxing:addEffect(U.SkillChargeChanged, {
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self) and target ~= player
    and data.num and data.num > 0 and target:getMark("@@yyfy_shiluoxinxing") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    U.skillCharged(target, -data.num)
  end
})

return xinxing
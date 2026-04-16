local baofa = fk.CreateSkill({
  name = "yyfy_baofa",
  tags = { Skill.Charge },
})

Fk:loadTranslationTable {
  ["yyfy_baofa"] = "爆发",
  [":yyfy_baofa"] = "蓄力技（0/5），回合结束时，你获得1点蓄力点。" ..
      "你可以消耗5点蓄力点，对所有敌方角色造成2点伤害。",--，然后令这些角色无法获得蓄力点
  ["$yyfy_baofa1"] = "宇宙射线爆裂",
  ["$yyfy_baofa2"] = "宇宙线爆发"
}

local U = require "packages/utility/utility"
local F = require "packages.hidden-clouds.functions"

baofa:addEffect("active", {
  prompt = "宇宙射线爆裂：你可以消耗5点蓄力点，对所有敌方角色造成2点伤害",
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
    end
  end,
})

baofa:addEffect(fk.TurnEnd, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    U.skillCharged(player, 1)
  end
})

-- 技能获得时初始化蓄力点
baofa:addAcquireEffect(function(self, player)
  U.skillCharged(player, 0, 5)
end)

-- 技能失去时移除蓄力点
baofa:addLoseEffect(function(self, player)
  U.skillCharged(player, 0, -5)
end)

-- baolie:addEffect(U.SkillChargeChangeTE, {
--   can_trigger = function (self, event, target, player, data)
--     return player and player:hasSkill(self) and data.who ~= player
--   end,
--   on_cost = Util.TrueFunc,
--   on_use = function (self, event, target, player, data)
--     U.skillCharged(data.who, -data.num)
--   end
-- })

return baofa
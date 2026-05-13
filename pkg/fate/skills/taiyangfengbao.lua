local baofa = fk.CreateSkill({
  name = "yyfy_taiyangfengbao",
  tags = { Skill.Charge },
})

Fk:loadTranslationTable {
  ["yyfy_taiyangfengbao"] = "太阳风暴",
  [":yyfy_taiyangfengbao"] = "蓄力技（0/5），敌方角色回合结束时，你获得1点蓄力点。你可以消耗5点蓄力点，"
      .. "对所有敌方角色造成2点伤害，然后令这些角色失去一半蓄力点、每回合失去一点体力，持续3回合。",
  ["$yyfy_taiyangfengbao1"] = "太阳风暴",
  ["$yyfy_taiyangfengbao2"] = "太阳风暴",
  ["@@yyfy_taiyangfengbao"] = "太阳风暴"
}

local U = require "packages/utility/utility"
local F = require "packages.hidden-clouds.functions"

baofa:addEffect("active", {
  prompt = "太阳风暴：你可以消耗5点蓄力点，对所有敌方角色造成2点伤害",
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
    -- 造成伤害
    for _, target in ipairs(targets) do
      room:damage {
        from = player,
        to = target,
        damage = 2,
        damageType = fk.NormalDamage,
        skillName = self.name,
      }
      room:addPlayerMark(target, "@@yyfy_taiyangfengbao", 3)
      if target:getMark("skill_charge") == 0 then return end
      U.skillCharged(target, -math.ceil(target:getMark("skill_charge") / 2))
    end
  end,
})

baofa:addEffect(fk.TurnEnd, {
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player and player:hasSkill(self) and F.isEnemy(player, target)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    U.skillCharged(player, 1)
  end
})

baofa:addEffect(fk.TurnEnd, {
  can_refresh = function(self, event, target, player, data)
    return player and player:hasSkill(self, true, true) and table.find(player.room.alive_players, function(p)
      return p:getMark("@@yyfy_taiyangfengbao") > 0
    end)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getAlivePlayers()) do
      if p:getMark("@@yyfy_taiyangfengbao") > 0 then
        room:loseHp(p, 1, baofa.name)
        room:addPlayerMark(p, "@@yyfy_taiyangfengbao", -1)
      end
    end
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

return baofa
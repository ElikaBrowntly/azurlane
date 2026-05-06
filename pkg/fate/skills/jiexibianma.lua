---@diagnostic disable: param-type-mismatch
local jiexi = fk.CreateSkill({
  name = "yyfy_jiexibianma",
  tags = { Skill.Permanent, Skill.Limited },
})

Fk:loadTranslationTable {
  ["yyfy_jiexibianma"] = "解析编码",
  [":yyfy_jiexibianma"] = "持恒技，限定技，敌方角色的回合结束时，若此时总计已经过5个敌方回合，你令敌方全体" ..
      "获得「解析完成」标记。拥有此标记的角色技能失效、不能回复体力、清空蓄力点且无法再获得蓄力点、造成大于1的伤害减半；" ..
      "然后你获得无敌贯通状态，并对这些角色造成的伤害增加5倍。",

  ["@@yyfy_jiexiwancheng"] = "解析完成"
}

local U = require "packages/utility/utility"
local F = require "packages.hidden-clouds.functions"

jiexi:addEffect(fk.TurnEnd, {
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player and player:hasSkill(self) and F.isEnemy(player, target)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local count = player.tag[jiexi.name] or 0
    player.tag[jiexi.name] = count + 1
    if count > 3 then
      for _, p in ipairs(room:getAlivePlayers()) do
        if F.isEnemy(player, p) then
          room:addPlayerMark(p, "@@yyfy_jiexiwancheng")
          if p:getMark("skill_charge") > 0 then
            U.skillCharged(p, -p:getMark("skill_charge"), 0)
          end
        end
      end
      room:setPlayerMark(player, "@!fate_wudiguantong", 1)
    end
  end
})

-- 技能失效
jiexi:addEffect("invalidity", {
  invalidity_func = function(self, from, skill)
    return from:getMark("@@yyfy_jiexiwancheng") > 0 and skill:isPlayerSkill(from)
  end,
})

jiexi:addEffect(fk.BeforeHpChanged, {
  can_refresh = function(self, event, target, player, data)
    return player and player:hasSkill(self) and target and
        target:getMark("@@yyfy_jiexiwancheng") > 0 and data.num > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.num = 0
    data.prevented = true
  end
})

jiexi:addEffect(U.SkillChargeChanged, {
  can_refresh = function(self, event, target, player, data)
    return player and player:hasSkill(self) and target ~= player
        and data.num and data.num > 0 and target:getMark("@@yyfy_jiexiwancheng") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    U.skillCharged(target, -data.num)
  end
})

jiexi:addEffect(fk.DamageCaused, {
  can_refresh = function(self, event, target, player, data)
    return player and player:hasSkill(self) and target and
        target:getMark("@@yyfy_jiexiwancheng") > 0 and data.damage > 1
  end,
  on_refresh = function(self, event, target, player, data)
    data:changeDamage(-math.floor(data.damage / 2))
  end
})

jiexi:addEffect(fk.DamageCaused, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.to:getMark("@@yyfy_jiexiwancheng") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data:changeDamage(data.damage * 5)
  end
})

jiexi:addEffect(fk.DamageInflicted, {
  can_refresh = function (self, event, target, player, data)
    return player and player:hasSkill(self.name)
    and data.from == player and player:getMark("@!fate_wudiguantong") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:loseHp(data.to, data.damage, self.name)
    data:preventDamage()
  end
})

return jiexi
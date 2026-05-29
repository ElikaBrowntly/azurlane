local skill = fk.CreateSkill {
  name = "yyfy_shouhuzhiying",
  tags = { Skill.Compulsory }
}

Fk:loadTranslationTable {
  ["yyfy_shouhuzhiying"] = "守护之樱",
  [":yyfy_shouhuzhiying"] = "锁定技，体力上限不大于3的友方角色有15%的概率回避受到的伤害。"..
  "你所在阵营有3个以上重樱舰船时，你们造成的伤害+1，你受到的伤害-1。",
  ["$yyfy_shouhuzhiying1"] = "胜负，皆为命定。至少…让我等竭尽全力",
  ["$yyfy_shouhuzhiying2"] = "既是汝，妾身便甘之如饴…"
}

local F = require "packages.hidden-clouds.functions"

skill:addEffect(fk.DamageInflicted, {
  priority = 2,
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player and target ~= player and player:hasSkill(self) and
        not F.isEnemy(player, target) and target.maxHp < 4 and math.random() < 0.15
  end,
  on_use = function(self, event, target, player, data)
    data:preventDamage()
  end
})

skill:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not (player and player:hasSkill(self) and not F.isEnemy(player, target)) then return false end
    local count = 0
    for _, p in ipairs(player.room:getAlivePlayers()) do
      if F.isEnemy(player, target) then break end
      local general = Fk.generals[p.general]
      local deputy = Fk.generals[p.deputyGeneral or ""]
      if general and general.package.name == "SakuraEmpire" then
        count = count + 1
      end
      if deputy and deputy.package.name == "SakuraEmpire" then
        count = count + 1
      end
    end
    return count > 2
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data:changeDamage(1)
  end
})

skill:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self)) then return false end
    local count = 0
    for _, p in ipairs(player.room:getAlivePlayers()) do
      if F.isEnemy(player, target) then break end
      local general = Fk.generals[p.general]
      local deputy = Fk.generals[p.deputyGeneral or ""]
      if general and general.package.name == "SakuraEmpire" then
        count = count + 1
      end
      if deputy and deputy.package.name == "SakuraEmpire" then
        count = count + 1
      end
    end
    return count > 2
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data:changeDamage(-1)
  end
})

return skill
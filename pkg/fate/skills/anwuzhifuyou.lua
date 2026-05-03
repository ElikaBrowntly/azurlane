local fuyou = fk.CreateSkill({
  name = "yyfy_anwuzhifuyou",
  tags = { Skill.Permanent },
})

Fk:loadTranslationTable {
  ["yyfy_anwuzhifuyou"] = "暗物质浮游",
  [":yyfy_anwuzhifuyou"] = "持恒技，敌方角色的回合结束时，有30%的概率发动。随机吸取敌方全体的攻击力和防御力共计3点。"
}

local F = require "packages.hidden-clouds.functions"

fuyou:addEffect(fk.TurnEnd, {
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player and player:hasSkill(self) and F.isEnemy(player, target)
        and math.random(100) <= 30
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local atk = math.random(0, 4)
    for _, p in ipairs(room:getAlivePlayers()) do
      if F.isEnemy(player, p) then
        room:addPlayerMark(p, "@!fate_attack_down", atk)
        room:addPlayerMark(p, "@!fate_defense_down", 3 - atk)
      end
    end
    room:addPlayerMark(player, "@!fate_attack", atk)
    room:addPlayerMark(player, "@!fate_defense", 3 - atk)
  end
})

fuyou:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return (target:getMark("@!fate_attack_down") > 0 or target:getMark("@!fate_attack") > 0)
        and player and player:hasSkill(self)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data:changeDamage(target:getMark("@!fate_attack") - target:getMark("@!fate_attack_down"))
  end
})

fuyou:addEffect(fk.DamageInflicted, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return (target:getMark("@!fate_defense_down") > 0 or target:getMark("@!fate_defense") > 0)
        and player and player:hasSkill(self)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data:changeDamage(target:getMark("@!fate_defense_down") - target:getMark("@!fate_defense"))
  end
})

return fuyou
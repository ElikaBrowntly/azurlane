local tian = fk.CreateSkill {
  name = "yyfy_tian",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable {
  ["yyfy_tian"] = "天",
  [":yyfy_tian"] = "持恒技，出牌阶段，你可以失去任意点体力上限，然后对一名角色造成等量点伤害。你造成的伤害均视为真实伤害。",

  ["#yyfy_tian-invoke"] = "天：你可以失去任意体力上限，对一名角色造成等量伤害",

}

local ok, JL = pcall(require, "packages.jilve_caidog.util")

tian:addEffect("active", {
  anim_type = "offensive",
  prompt = "#yyfy_tian-invoke",
  can_use = function(self, player)
    return player.maxHp > 0
  end,
  card_num = 0,
  target_num = 1,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local num = room:askToNumber(player, {
      min = 0,
      max = player.maxHp,
      skill_name = tian.name,
      cancelable = true,
      prompt = "天：请选择要失去的体力上限值"
    })
    if not num then return end
    room:changeMaxHp(player, -num)
    room:damage {
      from = player,
      to = target,
      damage = num,
      skillName = tian.name,
    }
  end,
})

tian:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.damage > 0 and ok
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damageType = JL.TrueDamage
  end
})

return tian
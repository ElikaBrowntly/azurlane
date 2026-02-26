local shengming = fk.CreateSkill{
  name = "yyfy_shengming",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["yyfy_shengming"] = "生命",
  [":yyfy_shengming"] = "锁定技，你的体力上限不能被减少。你登场时加1点体力上限。"..
  "当场上有角色回复体力时，你回复等量体力，若此时体力值等于体力上限，你增加一点体力上限（每阶段最多+5）。"
}

local all_generals = {"yyfy_shenglingpuni"}
local j = 1
while j <= 7 do
  table.insert(all_generals, "yyfy_shenglingpuni"..tostring(j))
  j = j + 1
end

shengming:addEffect(fk.HpRecover,{
  anim_type = "support",
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self) and (player.tag[shengming.name] or 0) < 5
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:recover({
      num = data.num,
      skillName = shengming.name,
      who = player,
      recoverBy = player
    })
    if player.hp == player.maxHp then
      room:changeMaxHp(player, 1)
      player.tag[shengming.name] = (player.tag[shengming.name] or 0) + 1
    end
  end
})

shengming:addEffect(fk.EventPhaseChanging, {
  can_refresh = function (self, event, target, player, data)
    return player and player:hasSkill(self, true, true) and (player.tag[shengming.name] or 0) ~= 0
  end,
  on_refresh = function (self, event, target, player, data)
    player.tag[shengming.name] = 0
  end
})

shengming:addEffect(fk.BeforeMaxHpChanged, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.num < 0
  end,
  on_use = function (self, event, target, player, data)
    data:preventMaxHpChange()
  end
})

shengming:addEffect(fk.AfterPropertyChange, {
  anim_type = "support",
  can_trigger = function (self, event, target, player, data)
    return player and target == player and player:hasSkill(self)
    and (table.contains(all_generals, data.general) or
    data.deputyGeneral and table.contains(all_generals, data.deputyGeneral))
  end,
  on_use = function (self, event, target, player, data)
    player.room:changeMaxHp(player, 1)
  end
})

return shengming
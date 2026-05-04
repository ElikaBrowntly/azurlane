local QC_tianjie = fk.CreateSkill{
  name = "QC_tianjie",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["QC_tianjie"] = "天劫",
  [":QC_tianjie"] = "持恒技，你免疫雷电伤害。一名角色的回合结束时，你可以对一名角色造成 X 点雷电伤害（X 为所有角色手牌中【闪】的数量且至少为 1）。当你进入濒死时，随机对全场其他角色造成 1~X 次 1~X 点雷电伤害，然后你回复等量的体力（X 由当前场上【闪】数量决定）。",
  ["#QC_tianjie-choose"] = "天劫：请选择一名角色对其造成雷电伤害",
}

QC_tianjie:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.damageType == fk.ThunderDamage
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.prevented = true
  end,
})

QC_tianjie:addEffect(fk.TurnEnd, {
  can_trigger = function(self, event, target, player, data)
    return target and player:hasSkill(self.name)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local all_players = room.alive_players
    local X = 0
    for _, p in ipairs(all_players) do
      for _, id in ipairs(p:getCardIds("h")) do
        if Fk:getCardById(id).name == "jink" then
          X = X + 1
        end
      end
    end
    X = math.max(1, X)
    local to = room:askToChoosePlayers(player, {
      skill_name = self.name,
      min_num = 1,
      max_num = 1,
      targets = all_players,
      prompt = "#QC_tianjie-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, { tos = to, X = X })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local costData = event:getCostData(self)
    local tos = costData.tos
    local X = costData.X
    for _, targetId in ipairs(tos or {}) do
      if not targetId.dead then
        room:damage{
          to = targetId,
          damage = X,
          damageType = fk.ThunderDamage,
          skillName = self.name,
        }
      end
    end
  end,
})

QC_tianjie:addEffect(fk.EnterDying, {
  mute = true,
  no_indicate = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local X = 0
    for _, p in ipairs(room.alive_players) do
      for _, id in ipairs(p:getCardIds("h")) do
        if Fk:getCardById(id).name == "jink" then
          X = X + 1
        end
      end
    end
    X = math.max(1, X)

    local others = room:getOtherPlayers(player, true)
    local totalDamage = 0

    local times = math.random(1, X)
    for i = 1, times do
      if #others == 0 then break end
      local target = others[math.random(1, #others)]
      if not target.dead then
        local damage = math.random(1, X)
        room:damage{
          to = target,
          damage = damage,
          damageType = fk.ThunderDamage,
          skillName = self.name,
        }
        totalDamage = totalDamage + damage
      end
    end

    if totalDamage > 0 and not player.dead then
      room:recover{
        who = player,
        num = totalDamage,
        recoverBy = player,
        skillName = self.name,
      }
    end
  end,
})

return QC_tianjie
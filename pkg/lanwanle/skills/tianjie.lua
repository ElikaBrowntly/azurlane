local tianjie = fk.CreateSkill {
  name = "lan__tianjie"
}

Fk:loadTranslationTable {
  ["lan__tianjie"] = "天劫",
  [":lan__tianjie"] = "一名角色的回合结束时，你可对任意名有牌的角色造成3点雷电伤害。",

  ["$lan__tianjie1"] = "雷池铸剑，今霜刃既成，当振天下于大白",
  ["$lan__tianjie2"] = "汝辈食民脂，糜民膏，当受天劫而死",
}

tianjie:addEffect(fk.TurnEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not (player and player:hasSkill(self)) then return false end
    local tos = table.filter(player.room.alive_players, function(p)
      return not p:isNude()
    end)
    if not tos or #tos == 0 then return false end
    event:setCostData(self, { tos = tos })
    return true
  end,
  on_cost = function(self, event, target, player, data)
    local tos = (event:getCostData(self) or {}).tos or {}
    if #tos == 0 then return false end
    tos = player.room:askToChoosePlayers(player, {
      targets = tos,
      min_num = 1,
      max_num = #tos,
      skill_name = tianjie.name,
      prompt = "天劫：你可以对任意名有牌的角色造成3点雷电伤害",
      cancelable = true
    })
    if #tos == 0 then return false end
    event:setCostData(self, { tos = tos })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tos = (event:getCostData(self) or {}).tos or {}
    if #tos == 0 then return end
    for _, t in ipairs(tos) do
      room:damage({
        from = player,
        to = t,
        damage = 3,
        damageType = fk.ThunderDamage,
        skillName = tianjie.name
      })
    end
  end,
})

return tianjie
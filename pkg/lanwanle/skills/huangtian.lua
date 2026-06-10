local huangtian = fk.CreateSkill {
  name = "lan__huangtian",
  tags = { Skill.Lord },
  attached_skill_name = "lan__huangtian_active&",
}

Fk:loadTranslationTable {
  ["lan__huangtian"] = "黄天",
  [":lan__huangtian"] = "主公技，当一名角色造成雷电伤害时，所有群势力可以各令其进行一次判定，若结果为：黑色，此伤害+1；红色，其获得此判定牌。",

  ["$lan__huangtian1"] = "黄衣变黄土，黄巾应黄天。",
  ["$lan__huangtian2"] = "着黄衣者，皆是黄天子民。",
  ["$lan__huangtian3"] = "苍天己被吾泪没，且看黄天昭太平！",
  ["$lan__huangtian4"] = "黄巾覆首，联方数万，此击可撼百年之炎汉。",
}

huangtian:addAcquireEffect(function (self, player)
  local room = player.room
  for _, p in ipairs(room:getOtherPlayers(player, false)) do
    if p.kingdom == "qun" then
      room:handleAddLoseSkills(p, "lan__huangtian_active&", nil, false, true)
    else
      room:handleAddLoseSkills(p, "-lan__huangtian_active&", nil, false, true)
    end
  end
end)

-- 其他角色变势力后，获得或失去附加技黄天
huangtian:addEffect(fk.AfterPropertyChange, {
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if player.kingdom == "qun" and table.find(room.alive_players, function (p)
      return p ~= player and p:hasSkill(huangtian.name, true)
    end) then
      room:handleAddLoseSkills(player, huangtian.attached_skill_name, nil, false, true)
    else
      room:handleAddLoseSkills(player, "-" .. huangtian.attached_skill_name, nil, false, true)
    end
  end,
})

huangtian:addEffect(fk.DamageCaused, {
  audio_index = {1, 2},
  can_trigger = function (self, event, target, player, data)
    return target and player and player:hasSkill(self) and (data.damageType or 0) == fk.ThunderDamage and player.role == "lord"
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if target then
      room:doIndicate(player.id, { target.id })
    end
    local judge = {
      who = target,
      reason = "lightning",
      pattern = ".|.|spade,club",
    }
    room:judge(judge)
    if judge:matchPattern() then
      data:changeDamage(1)
      return
    end
    if not judge.card or room:getCardArea(judge.card) ~= Card.Processing then return end
    room:obtainCard(target, judge.card, true, fk.ReasonJustMove, player, huangtian.name)
  end
})

return huangtian
local huangtian = fk.CreateSkill {
  name = "lan__huangtian_active&",
}

Fk:loadTranslationTable {
  ["lan__huangtian_active&"] = "黄天",
  [":lan__huangtian_active&"] = "当一名角色造成雷电伤害时，你可以令其进行一次判定，若结果为：黑色，此伤害+1；红色，其获得此判定牌。",
}

huangtian:addEffect(fk.DamageCaused, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target and player and player:hasSkill(self) and (data.damageType or 0) == fk.ThunderDamage
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ori = table.find(room.alive_players, function(p)
      return p ~= player and p:hasSkill("lan__huangtian")
    end)
    if ori then
      room:notifySkillInvoked(ori, "lan__huangtian")
      ori:broadcastSkillInvoke("lan__huangtian", math.random(3, 4))
      room:doIndicate(player.id, { ori.id })
      if ori.id ~= target.id then
        room:doIndicate(player.id, { target.id })
      end
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
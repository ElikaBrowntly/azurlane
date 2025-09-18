local aige = fk.CreateSkill{
  name = "lan__aige",
  tags = { Skill.Wake },
}

Fk:loadTranslationTable{
  ["lan__aige"] = "哀歌",
  [":lan__aige"] = "觉醒技，一回合内第二次有角色进入濒死状态时，你获得〖逐北〗，然后摸X张牌，回复X点体力。（X为该角色体力上限）",

  ["$lan__aige1"] = "奈何力不齐，踌躇而雁行。",
  ["$lan__aige2"] = "生民百遗一，念之断人肠。",
}

aige:addEffect(fk.Dying, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(aige.name) and player:usedSkillTimes(aige.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    -- 计算本回合内发生的Dying事件次数
    local dyingEvents = player.room.logic:getEventsOfScope(GameEvent.Dying, 100, Util.TrueFunc, Player.HistoryTurn)
    return #dyingEvents >= 2
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 获得逐北
    room:handleAddLoseSkills(player, "lan__zhubei")
    local n = target.maxHp
    -- 摸X张牌
    player:drawCards(n, aige.name)
    -- 回复X点体力
    if not player.dead and player:isWounded() then
      room:recover{
        who = player,
        num = n,
        recoverBy = player,
        skillName = aige.name,
      }
    end
  end,
})

return aige
local skill = fk.CreateSkill{
  name = "fate_siji",
  anim_type = "offensive",
  tags = {Skill.Limited},
}

Fk:loadTranslationTable{
  ["fate_siji"] = "死棘",
  [":fate_siji"] = "限定技：出牌阶段，你可以对一名角色造成一点雷电伤害，"..
  "每传导一次，该伤害便+x（x为上一名角色剩余体力值）",
  
  ["$fate_siji1"] = "这心脏就由我拿下了！",
  ["$fate_siji2"] = "穿刺死棘之枪！"
}

skill:addEffect("active", {
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  target_num = 1,
  min_target_num = 1,
  max_target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]

    local damage = 1
    local lastHp = target.hp

    if target.chained == true then
      target:setChainState(false)
    end

    room:damage{
      from = player,
      to = target,
      damage = damage,
      damageType = fk.ThunderDamage,
      skillName = self.name,
    }

    lastHp = target.hp

    local allPlayers = room:getAlivePlayers()
    if allPlayers == nil then return nil end

    local function getPropagationOrder()
      local order = {}
      local currentSeat = player.seat
      local numPlayers = #allPlayers

      for i = 0, numPlayers - 1 do
        local index = (currentSeat + i - 1) % numPlayers + 1
        if  allPlayers[index].chained == true then
        table.insert(order, allPlayers[index])
        end
      end
      
      return order
    end
    
    local propagationOrder = getPropagationOrder()

    for _, nextTarget in ipairs(propagationOrder) do

      if nextTarget ~= target then
        if lastHp > 0 then
          damage = damage + lastHp
        end
        nextTarget:setChainState(false)
        
        room:damage{
          from = player,
          to = nextTarget,
          damage = damage,
          damageType = fk.ThunderDamage,
          skillName = self.name,
        }
        
        lastHp = nextTarget.hp
      end
    end
  end,
})

return skill
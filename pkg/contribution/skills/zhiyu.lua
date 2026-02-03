local zhiyu = fk.CreateSkill {
  name = "lan__zhiyu",
}

Fk:loadTranslationTable{
  ["lan__zhiyu"] = "智愚",
  [":lan__zhiyu"] = "当你受到伤害后，你可以展示所有手牌且令伤害来源弃置一张手牌，然后你摸伤害值张牌。"
  .."若你展示的牌颜色均相同，你获得其弃置的牌且本局游戏〖奇策〗可发动次数永久+1；"
  .."否则，仅下回合〖奇策〗可发动次数+1。",

  ["@lan__zhiyu_temp"] = "临时+",
  ["@lan__zhiyu_permanent"] = "永久+",
  ["@lan__zhiyu_temp-turn"] = "奇策+",
  ["$lan__zhiyu1"] = "经达权变，大智若愚。",
  ["$lan__zhiyu2"] = "微末伎俩，让阁下见笑了。",
}

zhiyu:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local damage = data.damage
    
    -- 展示所有手牌
    local cards = player:getCardIds("h")
    if #cards > 0 then
      player:showCards(cards)
    end
    -- 伤害来源弃牌
    local discardedCard = nil
    if data.from and not data.from.dead and not data.from:isKongcheng() then
      discardedCard = room:askToDiscard(data.from, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = self.name,
        cancelable = false,
      })
    end
    -- 摸伤害值张牌
    player:drawCards(damage, self.name)
    if player.dead then return end
    -- 检查手牌颜色
    local allSameColor = false
    if #cards > 0 then
      allSameColor = true
      local firstColor = Fk:getCardById(cards[1]).color
      for i = 2, #cards do
        if Fk:getCardById(cards[i]).color ~= firstColor then
          allSameColor = false
          break
        end
      end
    end
    
    if allSameColor then
      -- 永久增加奇策
      room:addPlayerMark(player, "@lan__zhiyu_permanent", 1)
      -- 获得弃置的牌
      if discardedCard and #discardedCard > 0 then
        local cardId = discardedCard[1]
        if table.contains(room.discard_pile, cardId) then
          room:obtainCard(player, cardId, false, fk.ReasonPrey, player, self.name)
        end
      end
    else
      -- 临时增加奇策
      room:addPlayerMark(player, "@lan__zhiyu_temp", 1)
    end
  end,
})

-- 回合开始时处理标记
zhiyu:addEffect(fk.TurnStart, {
  can_trigger = function (self, event, target, player, data)
    return target == player
  end,
  on_trigger = function (self, event, target, player, data)
    local room = player.room
    local tempMarks = player:getMark("@lan__zhiyu_temp")
    local permanentMarks = player:getMark("@lan__zhiyu_permanent")
    room:addPlayerMark(player, "@lan__zhiyu_temp-turn", tempMarks + permanentMarks)
    room:setPlayerMark(player, "@lan__zhiyu_temp", 0)
  end,
})

zhiyu:addEffect(fk.AfterSkillEffect, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:getMark("@lan__zhiyu_temp-turn") > 0 and data.skill.name == "qice"
  end,
  on_trigger = function (self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@lan__zhiyu_temp-turn", -1)
    player:addSkillUseHistory("qice", -1)
  end,
})

-- 失去技能时清除标记
zhiyu:addLoseEffect(function(self, player)
  local room = player.room
  room:setPlayerMark(player, "@lan__zhiyu_permanent", 0)
  room:setPlayerMark(player, "@lan__zhiyu_temp", 0)
  room:setPlayerMark(player, "@lan__zhiyu_temp-turn", 0)
end)

return zhiyu
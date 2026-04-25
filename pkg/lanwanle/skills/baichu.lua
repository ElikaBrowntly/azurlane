local baichu = fk.CreateSkill{
  name = "lan__baichu",
  tags = { Skill.Compulsory },
}

local F = require("packages.hidden-clouds.functions")

Fk:loadTranslationTable{
  ["lan__baichu"] = "百出",
  [":lan__baichu"] = "锁定技，你使用锦囊牌后，摸1张牌并回复1点体力。"..
  "若此牌为转化的伤害锦囊牌，你可以摸X张牌（X为用于转化的牌数）",
  
  ["$lan__baichu1"] = "腹有经纶，到用时施无穷之计",
  ["$lan__baichu2"] = "胸纳甲兵，烽烟起可靖疆晏海",
  ["$lan__baichu3"] = "郃计不用，为郭逢所伤，含冤怒而来，君何疑？",
  ["$lan__baichu4"] = "绍运车旦暮至，其将韩猛锐而轻敌，击可破也",
}

baichu:addEffect(fk.CardUseFinished, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(baichu.name) and
           data.card.type == Card.TypeTrick  -- 锦囊牌
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    player:drawCards(1, self.name)
    room:addPlayerMark(player, "lan__baichu-achievements") -- 用于统计战功
    room:recover{
      who = player,
      num = 1,
      recoverBy = player,
      skillName = self.name,
    }
    -- 检查：转化伤害牌
    local card = data.card
    local X = #card.subcards
    if card.is_damage_card and card:isVirtual() and X > 0 then
      player:drawCards(X, self.name)
      room:addPlayerMark(player, "lan__baichu-achievements", X) -- 用于统计战功
    end
  end,
})

--战功：十二奇策
baichu:addEffect(fk.GameFinished, {
  priority = 0.0001,
  can_refresh = function(self, event, target, player, data)
    local winners = data:split("+")
    return player:getMark("lan__baichu-achievements") >= 12 and table.contains(winners, player.role)
  end,
  on_refresh = function(self, event, target, player, data)
    F.addAchievement(player.room, nil, nil, nil, "十二奇策", nil, nil, {player}, false, "夜隐浮云")
  end
})

return baichu
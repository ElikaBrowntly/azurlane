local tianen = fk.CreateSkill {
  name = "lan__tianen",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["lan__tianen"] = "天恩",
  [":lan__tianen"] = "当你使用牌指定唯一目标后，你从牌堆中随机获得一张不计入手牌上限的【杀】，若目标不为你，你随机弃置其一张牌，本回合此技能失效。",

  ["@@lan__tianen-inhand"] = "天恩",

  ["$lan__tianen1"] = "臣是薪，恩是火，莫让朕寒了心。",
  ["$lan__tianen2"] = "雷霆雨露，俱是朕赏你的。",
  ["$lan__tianen3"] = "庙堂之上，贤良忠臣独汝一人？",
}

tianen:addEffect(fk.TargetSpecified, {
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      data:isOnlyTarget(data.to) and
      data.to:isAlive() and
      player:hasSkill(tianen.name)
  end,
  on_cost = function(self, event, target, player, data)
    event:setCostData(self, { tos = { data.to } })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local skillName = tianen.name
    local room = player.room
    local targetPlayer = data.to
    local cards = room:getCardsFromPileByRule("slash", 1)
    if #cards > 0 then
      room:obtainCard(player, cards, true, fk.ReasonPrey, player, skillName, "@@lan__tianen-inhand")
    end
    -- 若目标不为自己
    if targetPlayer ~= player then
      if not targetPlayer:isNude() then
        local toDiscard = room:tableRandomPick(targetPlayer:getCardIds("he"))
        room:throwCard(toDiscard, skillName, targetPlayer, player)
      end
      room:invalidateSkill(player, skillName, "-turn")
    end
  end,
})

tianen:addEffect("maxcards", {
  exclude_from = function(self, player, card)
    return card:getMark("@@lan__tianen-inhand") > 0
  end,
})

return tianen
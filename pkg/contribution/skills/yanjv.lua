local yanjv = fk.CreateSkill {
  name = "yyfy_yanjv",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["yyfy_yanjv"] = "言句",
  [":yyfy_yanjv"] = "锁定技，你的多字手牌<a href='yyfy_yanjv_change'>牌名替换</a>为【句】，你的【句】不计入手牌上限。",
  
  ["yyfy_yanjv_change"] = "替换了卡牌的trueName。<br>若被替换牌为装备牌，可以使用但无任何效果；<br>否则该牌无法使用或打出。",
  ["$yyfy_yanjv1"] = "对酒，当歌，人生，几何？",
  ["$yyfy_yanjv2"] = "上有皓月当空，下有江波荡漾。此情此景，感慨系之。我当作歌，尔等和之！",
}

-- 判断是否为多字牌的函数
--- @param cardID integer
local function isMultiCharacterCard(cardID)
  local card = Fk:getCardById(cardID)
  local cardName = card.trueName or card.name
  local translatedName = Fk:translate(cardName, "zh_CN")
  return translatedName and translatedName:len() > 1
end

-- 游戏开始时触发：多字牌变为“句”
yanjv:addEffect(fk.GameStart, {
  mute = true,
  --实测只计算初始手牌，机制不明，这里靠提高记录优先级来实现
  priority = 9,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(yanjv.name) and #player:getCardIds("h") > 0 then
      event:setCostData(self, {cards = player:getCardIds("h")})
      return true
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self).cards
    if cards == nil then return false end
    for _, c in ipairs(cards) do
      if isMultiCharacterCard(c) then
      local card = Fk:getCardById(c)
      room:moveCardTo(c, Card.Void, nil, nil, self.name, nil, false, player)
      local newCard = nil
      if card.type == Card.TypeBasic then
        newCard = room:printCard("yyfy_jv_basic", card.suit, card.number)
      elseif card.type == Card.TypeTrick then
        newCard = room:printCard("yyfy_jv_trick", card.suit, card.number)
      else
        if card.sub_type == Card.SubtypeWeapon then
          newCard = room:printCard("yyfy_jv_weapon", card.suit, card.number)
        elseif card.sub_type == Card.SubtypeArmor then
          newCard = room:printCard("yyfy_jv_armor", card.suit, card.number)
          elseif card.sub_type == Card.SubtypeDefensiveRide then
          newCard = room:printCard("yyfy_jv_defensive", card.suit, card.number)
            elseif card.sub_type == Card.SubtypeOffensiveRide then
              newCard = room:printCard("yyfy_jv_offensive", card.suit, card.number)
            else newCard = room:printCard("yyfy_jv_treasure", card.suit, card.number)
        end
      end
      player:broadcastSkillInvoke(self.name)
      room:moveCardTo(newCard, Card.PlayerHand, player, nil, self.name, nil, false, player)
      end
    end
  end,
})
-- 获得牌时触发：检查是否为多字牌，是则重命名并添加标记
yanjv:addEffect(fk.AfterCardsMove, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(yanjv.name) and #player:getCardIds("h") > 0 then
      local cards = {}
      table.insertTable(cards, player:getCardIds("h"))
      cards = player.room.logic:moveCardsHoldingAreaCheck(cards)
      if #cards > 0 then
        event:setCostData(self, {cards = cards})
        return true
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self).cards
    if cards == nil then return false end
    for _, c in ipairs(cards) do
      if isMultiCharacterCard(c) then
      local card = Fk:getCardById(c)
      room:moveCardTo(c, Card.Void, nil, nil, self.name, nil, false, player)
      local newCard = nil
      if card.type == Card.TypeBasic then
        newCard = room:printCard("yyfy_jv_basic", card.suit, card.number)
      elseif card.type == Card.TypeTrick then
        newCard = room:printCard("yyfy_jv_trick", card.suit, card.number)
      else
        if card.sub_type == Card.SubtypeWeapon then
          newCard = room:printCard("yyfy_jv_weapon", card.suit, card.number)
        elseif card.sub_type == Card.SubtypeArmor then
          newCard = room:printCard("yyfy_jv_armor", card.suit, card.number)
          elseif card.sub_type == Card.SubtypeDefensiveRide then
          newCard = room:printCard("yyfy_jv_defensive", card.suit, card.number)
            elseif card.sub_type == Card.SubtypeOffensiveRide then
              newCard = room:printCard("yyfy_jv_offensive", card.suit, card.number)
            else newCard = room:printCard("yyfy_jv_treasure", card.suit, card.number)
        end
      end
      player:broadcastSkillInvoke(self.name)
      room:moveCardTo(newCard, Card.PlayerHand, player, nil, self.name, nil, false, player)
      end
    end
  end,
})

local F = require("packages.hidden-clouds.functions")

-- 不占手牌上限
yanjv:addEffect("maxcards", {
  mute = true,
  exclude_from = function(self, player, card)
    if player:hasSkill(yanjv.name) and F.isJv(card) then
        return true
    end
  end,
})

return yanjv
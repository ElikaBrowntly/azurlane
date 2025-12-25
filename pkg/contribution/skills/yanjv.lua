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
  
  ["@@yyfy_yanjv-mark"] = "句",
  ["yyfy_yueCaocao-jv"] = "句",
}

-- 判断是否为多字牌的函数
local function isMultiCharacterCard(card)
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
    return player:hasSkill(yanjv.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, id in ipairs(player:getCardIds("h")) do
      local card = Fk:getCardById(id)
      if isMultiCharacterCard(card) then
        -- 重命名卡牌
        card.trueName = "yyfy_yueCaocao-jv"
        -- 添加标记，用于不占手牌上限
        room:setCardMark(card, "@@yyfy_yanjv-mark", 1)
      end
    end
  end,
})
-- 获得牌时触发：检查是否为多字牌，是则重命名并添加标记
yanjv:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    if player:hasSkill(yanjv.name) then
      for _, move in ipairs(data) do
        if move.to == player and move.toArea == Card.PlayerHand then
          for _, info in ipairs(move.moveInfo) do
            local card = Fk:getCardById(info.cardId)
            if isMultiCharacterCard(card) then
              return true
            end
          end
        end
      end
    end
    return false
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, move in ipairs(data) do
      if move.to == player and move.toArea == Card.PlayerHand then
        for _, info in ipairs(move.moveInfo) do
          local card = Fk:getCardById(info.cardId)
          if isMultiCharacterCard(card) then
            -- 重命名卡牌
            card.trueName = "yyfy_yueCaocao-jv"
            -- 添加标记，用于不占手牌上限
            room:setCardMark(card, "@@yyfy_yanjv-mark", 1)
          end
        end
      end
    end
  end,
})

local F = require "packages.hidden-clouds.functions"
-- 装备技能失效效果
yanjv:addEffect("invalidity", {
  invalidity_func = function(self, from, skill)
   for _, c in ipairs(from:getCardIds("he")) do
      local card = Fk:getCardById(c, true)
      if card:getMark("@@yyfy_yanjv-mark") > 0 and
        (F.getCardNameFromSkillName(skill.name) == card.name) then
        return true
      end
    end
    return false
  end
})
-- 锦囊基本失效效果
yanjv:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    return card:getMark("@@yyfy_yanjv-mark") > 0 and card.type ~= Card.TypeEquip
  end,
  prohibit_response = function(self, player, card)
    return card:getMark("@@yyfy_yanjv-mark") > 0 and card.type ~= Card.TypeEquip
  end,
})

-- 不占手牌上限
yanjv:addEffect("maxcards", {
  exclude_from = function(self, player, card)
    if player:hasSkill(yanjv.name) then
      if card:getMark("@@yyfy_yanjv-mark") > 0 then
        return true
      end
      
      -- 也可以直接检查牌名是否为"句"（备用方案）
      if card.trueName == "yyfy_yueCaocao-jv" then
        return true
      end
    end
    return false
  end,
})

return yanjv
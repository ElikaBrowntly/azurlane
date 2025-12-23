local yanjv = fk.CreateSkill {
  name = "yyfy_yanjv",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["yyfy_yanjv"] = "言句",
  [":yyfy_yanjv"] = "锁定技，你获得多字手牌后，将此牌牌名替换为「句」，你的「句」不计入手牌上限。",
  
  ["$yyfy_yanjv1"] = "言之无文，行而不远。",
  ["$yyfy_yanjv2"] = "文以载道，言以修身。",
  
  ["@@yyfy_yanjv-mark"] = "句",
  ["yyfy_yueCaocao-jv"] = "句",
  ["@yyfy_yueCaocao-acquire"] = "获得",
  ["@yyfy_yueCaocao-lose"] = "失去"
}

-- 判断是否为多字牌的函数
local function isMultiCharacterCard(card)
  local cardName = card.trueName or card.name
  local translatedName = Fk:translate(cardName, "zh_CN")
  return translatedName and translatedName:len() > 1
end

-- 将牌名替换为"句"
local function renameCardTojv(card)
  -- 保存原牌名到extra_data
  if not card.extra_data then
    card.extra_data = {}
  end
  card.extra_data.yanjv_original_trueName = card.trueName
  
  -- 替换为"句"
  card.trueName = "yyfy_yueCaocao-jv"
  
  -- 添加标记
  return true
end

-- 恢复原牌名
local function restoreCardName(card)
  if card.extra_data and card.extra_data.yanjv_original_trueName then
    card.trueName = card.extra_data.yanjv_original_trueName
    
    -- 清理extra_data
    card.extra_data.yanjv_original_trueName = nil
    
    -- 如果extra_data为空表，可以置空
    if next(card.extra_data) == nil then
      card.extra_data = nil
    end
    
    return true
  end
  return false
end

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
            renameCardTojv(card)
            -- 添加标记，用于不占手牌上限，以及二技能失效计数
            room:setCardMark(card, "@@yyfy_yanjv-mark", 1)
            if player:hasSkill("yyfy_hejue", false) then -- 只有技能没失效的时候才累计失效计数
              room:addPlayerMark(player, "@yyfy_yueCaocao-acquire")
              if player:getMark("@yyfy_yueCaocao-acquire") == 3 then
                room:setPlayerMark(player, "@yyfy_yueCaocao-acquire", 0)
                room:setPlayerMark(player, "@yyfy_yueCaocao-lose", 0)
                room:addPlayerMark(player, "yyfy_hejue-phase") -- 清除失效计数，转换为失效标记
              end
            end
            
          end
        end
      end
    end
  end,
})

-- 装备技能失效效果
yanjv:addEffect("invalidity", {
  invalidity_func = function(self, from, skill)
   for _, c in ipairs(from:getCardIds("he")) do
      local card = Fk:getCardById(c, true)
      if card:getMark("@@yyfy_yanjv-mark") > 0 and
        skill:getSkeleton().attached_equip == card.name then
        return true
      end
    end
    return false
  end
})

-- 卡牌离开自己区域时恢复原牌名
yanjv:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    if player:hasSkill(yanjv.name) then
      for _, move in ipairs(data) do
        if move.from == player and ((move.to ~= player and move.toArea == Card.PlayerHand)
          or move.toArea == Card.DiscardPile or move.toArea == Card.DrawPile or
          move.toArea == Card.Unknown or move.toArea == Card.Void or move.toArea == Card.PlayerJudge
          or move.toArea == Card.PlayerSpecial ) then
          for _, info in ipairs(move.moveInfo) do
            local card = Fk:getCardById(info.cardId)
            if card:getMark("@@yyfy_yanjv-mark") > 0 then
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
        for _, info in ipairs(move.moveInfo) do
          local card = Fk:getCardById(info.cardId)
          if card:getMark("@@yyfy_yanjv-mark") > 0 then
            -- 恢复原牌名
            restoreCardName(card)
            -- 处理标记
            room:setCardMark(card, "@@yyfy_yanjv-mark", 0)
            if player:hasSkill("yyfy_hejue", false) then -- 只有技能没失效的时候才累计失效计数
              room:addPlayerMark(player, "@yyfy_yueCaocao-lose")
              if player:getMark("@yyfy_yueCaocao-lose") == 3 then
                room:setPlayerMark(player, "@yyfy_yueCaocao-acquire", 0)
                room:setPlayerMark(player, "@yyfy_yueCaocao-lose", 0)
                room:addPlayerMark(player, "yyfy_hejue-phase") -- 清除失效计数，转换为失效标记
              end
            end
          end
        end
    end
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

-- 技能失去时清理标记
yanjv:addLoseEffect(function(self, player, is_death)
  local room = player.room
  for _, id in ipairs(player:getCardIds("h")) do
    local card = Fk:getCardById(id)
    if card:getMark("@@yyfy_yanjv-mark") > 0 then
      room:setCardMark(card, "@@yyfy_yanjv-mark", 0)
      restoreCardName(card)
    end
  end
end)

return yanjv
local yyfy_haopai = fk.CreateSkill {
  name = "yyfy_haopai",
}

Fk:loadTranslationTable{
  ["yyfy_haopai"] = "好牌",
  [":yyfy_haopai"] = "每回合限5次，你可以从牌堆中获得一张你需要的牌，此牌伤害值固定为X（X为此牌点数）；"
  .."每回合前5次，你进入濒死状态时，可以将体力回复至一点。",
  ["@yyfy_haopai"] = "好牌",

  ["#yyfy_haopai-type"] = "好牌：请选择要获取的牌的类型",
  ["#yyfy_haopai-choice"] = "好牌：请选择要获取的牌",
  ["#NoCardOfType"] = "%from 想要获取%arg，但牌堆中没有此类牌",
  ["#yyfy_haopai-recover"] = "好牌：你可以将体力回复至1点",
}

local U = require "packages/utility/utility"

yyfy_haopai:addEffect("active", {
  card_num = 0,
  anim_type = "drawcard",
  prompt = "#yyfy_haopai-type",
  can_use = function(self, player)
    return player:getMark("yyfy_haopai_used-turn") < 5 and
      #Fk:currentRoom().draw_pile > 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    
    -- 增加使用次数标记
    room:addPlayerMark(player, "yyfy_haopai_used-turn", 1)
    
    -- 1.选择牌的类型
    local type_choices = {
      "基本牌",
      "锦囊牌",
      "装备牌"
    }
    
    local type_choice = room:askToChoice(player, {
      choices = type_choices,
      skill_name = yyfy_haopai.name,
      prompt = "#yyfy_haopai-type",
    })
    
    if not type_choice then 
      -- 如果取消选择，回退使用次数
      room:addPlayerMark(player, "yyfy_haopai_used-turn", -1)
      return 
    end
    
    -- 将类型选择转换为对应的卡牌类型
    local card_type
    if type_choice == "基本牌" then
      card_type = Card.TypeBasic
    elseif type_choice == "锦囊牌" then
      card_type = Card.TypeTrick
    else -- 装备牌
      card_type = Card.TypeEquip
    end
    
    -- 获取对应类型的所有可选牌名
    local choices = {}
    for _, id in ipairs(room.draw_pile) do
      local card = Fk:getCardById(id)
      if card.type == card_type and not table.contains(choices, card.trueName) then
        table.insert(choices, card.trueName)
      end
    end
    
    if #choices == 0 then
      room:sendLog{
        type = "#NoCardOfType",
        from = player.id,
        arg = type_choice,
      }
      -- 如果没有对应类型的牌，回退使用次数
      room:addPlayerMark(player, "yyfy_haopai_used-turn", -1)
      return 
    end
    
    -- 2.选择具体的牌名
    local result = U.askForChooseCardNames(room, player,
      choices, 1, 1, yyfy_haopai.name, "#yyfy_haopai-choice", nil, true)
    
    if #result == 0 then 
      -- 如果取消选择，回退使用次数
      room:addPlayerMark(player, "yyfy_haopai_used-turn", -1)
      return 
    end
    
    local selected_name = result[1]
    
    -- 从牌堆中找到对应牌名的牌
    local toObtain = nil
    for i = 1, #room.draw_pile do
      local card = Fk:getCardById(room.draw_pile[i])
      if card.trueName == selected_name then
        toObtain = card.id
        -- 如果是伤害牌，则添加标记
        if card.is_damage_card then
          room:addCardMark(card, "@yyfy_haopai", card.number)
        end
        break
      end
    end
    
    if toObtain then
      room:obtainCard(player, toObtain, false, fk.ReasonJustMove, player, yyfy_haopai.name)
    end
  end,
})

-- 伤害值固定为牌点数
yyfy_haopai:addEffect(fk.DetermineDamageCaused, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return data.card and data.card:getMark("@yyfy_haopai") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local card_number = data.card:getMark("@yyfy_haopai")
    if card_number then
      data.damage = card_number
    end
  end,
})

-- 进入弃牌堆时清除标记
yyfy_haopai:addEffect(fk.AfterCardsMove, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    for _, move in ipairs(data) do
      for _, info in ipairs(move.moveInfo) do
        local card = Fk:getCardById(info.cardId)
        if card and card:getMark("@yyfy_haopai") > 0 and
           info.fromArea == Card.PlayerHand and move.toArea == Card.DiscardPile then
          return true
        end
      end
    end
    return false
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, move in ipairs(data) do
      for _, info in ipairs(move.moveInfo) do
        local card = Fk:getCardById(info.cardId)
        if card and card:getMark("@yyfy_haopai") > 0 and 
           info.fromArea == Card.PlayerHand or move.toArea == Card.DiscardPile then
          room:setCardMark(card, "@yyfy_haopai", 0)
        end
      end
    end
  end,
})

-- 濒死回血
yyfy_haopai:addEffect(fk.EnterDying, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(yyfy_haopai.name) and 
           target == player and 
           player:getMark("yyfy_haopai_dying_times-turn") < 5
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = yyfy_haopai.name,
      prompt = "#yyfy_haopai-recover",
    }) then
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 增加濒死次数标记
    room:addPlayerMark(player, "yyfy_haopai_dying_times-turn", 1)
    
    -- 将体力回复至1点
    room:recover{
      who = player,
      num = 1 - player.hp,
      recoverBy = player,
      skillName = yyfy_haopai.name,
    }
    local randomIndex = math.random(0, 58)
    local emojiString = "{emoji" .. randomIndex .. "}"
    -- 发个表情
    player:chat(emojiString)
  end,
})

return yyfy_haopai
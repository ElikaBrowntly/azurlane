local yyfy_ex_jinglue = fk.CreateSkill {
  name = "yyfy_ex_jinglue"
}

Fk:loadTranslationTable{
  ["yyfy_ex_jinglue"] = "景略",
  [":yyfy_ex_jinglue"] = "出牌阶段限一次，若场上没有“死士”牌，你可观看一名其他角色的手牌，"
  .."将其中一张牌标记为“死士”。“死士”牌不能被打出，当“死士”牌被其使用时，你令此牌无效并重铸你的一张手牌；"
  .."其回合结束时，若“死士”牌在牌堆、弃牌堆或任意角色的区域内，你获得之并摸一张牌。"
  .."每回合限一次，你对手牌区有“死士”牌的角色使用【杀】可以额外结算一次",

  ["#yyfy_ex_jinglue"] = "景略:观看一名其他角色的手牌，将其中一张牌标记为“死士”",
  ["#CardNullifiedBySkill"] = "由于 %arg 的效果，%from 使用的 %arg2 无效",
  ["#yyfy_ex_jinglue-sha"] = "景略：你可以令此【杀】额外结算一次",

  ["$yyfy_ex_jinglue1"] = "尔等暂且不麾不动，来日必有奇用。",
  ["$yyfy_ex_jinglue2"] = "吾尽用间之谋，亦极用人之要。",
}

-- 标记死士
yyfy_ex_jinglue:addEffect("active", {
  name = "yyfy_ex_jinglue",
  anim_type = "control",
  prompt = "#yyfy_ex_jinglue",
  times = function (self, player)
    return 1 - player:usedSkillTimes(yyfy_ex_jinglue.name, Player.HistoryPhase)
  end,
  can_use = function(self, player)
    return
      player:usedSkillTimes(yyfy_ex_jinglue.name, Player.HistoryPhase) < 1 and
      table.every(Fk:currentRoom().alive_players, function(p)
        return table.every(p:getCardIds("ej"), function(id)
          return Fk:getCardById(id):getMark("_yyfy_ex_sishi") == 0
        end)
      end)
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  target_num = 1,
  target_filter = function(self, player, to_select, selected)
    return #selected < 1 and to_select ~= player and not to_select:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local cid = room:askToChooseCard(
      player,
      {
        target = target,
        flag = { card_data = { { "$Hand", target:getCardIds("h") } } },
        skill_name = yyfy_ex_jinglue.name
      }
    )
    room:setCardMark(Fk:getCardById(cid), "_yyfy_ex_sishi", { target.id, player.id })
    room:setCardMark(Fk:getCardById(cid), "yyfy_ex_sishi_forbid", 1) -- 添加禁止打出标记
    local mark_name = "_yyfy_ex_jinglue_now-" .. tostring(player.id)
    room:addTableMarkIfNeed(target, mark_name, cid)
    room:addTableMarkIfNeed(player, "_yyfy_ex_jinglue", target.id)
  end,
})

-- 死士被使用
yyfy_ex_jinglue:addEffect(fk.CardUsing, {
  is_delay_effect = true,
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    local mark
    for _, id in ipairs(Card:getIdList(data.card)) do
      if Fk:getCardById(id):getMark("_yyfy_ex_sishi") ~= 0 then
        if not mark then
          mark = Fk:getCardById(id):getMark("_yyfy_ex_sishi")
        elseif mark ~= Fk:getCardById(id):getMark("_yyfy_ex_sishi") then
          return false
        end
      else
        return false
      end
    end
    return mark and mark[1] == target.id and mark[2] == player.id
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player, { target })
    data.toCard = nil
    data:removeAllTargets()
    room:sendLog{
      type = "#CardNullifiedBySkill",
      from = player.id,
      arg = yyfy_ex_jinglue.name,
      arg2 = data.card:toLogString(),
    }
    
    -- 移除禁止打出标记
    for _, id in ipairs(Card:getIdList(data.card)) do
      room:setCardMark(Fk:getCardById(id), "yyfy_ex_sishi_forbid", 0)
    end
    
    -- 重铸一张手牌
    if not player:isKongcheng() then
      local recastCards = room:askToCards(player, {
        min_num = 1,
        max_num = 1,
        skill_name = self.name,
        prompt = "景略：请重铸一张手牌"
      })
      room:recastCard(recastCards, player, yyfy_ex_jinglue.name)
    end
  end,
})

-- 禁止打出死士牌
yyfy_ex_jinglue:addEffect("prohibit", {
  prohibit_response = function(self, player, card)
    local cards = card:isVirtual() and card.subcards or { card.id }
    return table.find(cards, function(id)
      return Fk:getCardById(id):getMark("yyfy_ex_sishi_forbid") > 0
    end)
  end,
})

-- 其回合结束时
yyfy_ex_jinglue:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if target:getMark("_yyfy_ex_jinglue_now-" .. player.id) ~= 0 and player:isAlive() then
      for _, id in ipairs(target:getMark("_yyfy_ex_jinglue_now-" .. player.id)) do
        if
          table.contains(
            { Card.DrawPile, Card.DiscardPile, Card.PlayerHand, Card.PlayerEquip, Card.PlayerJudge },
            player.room:getCardArea(id)
          )
        then
          return true
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = {}
    local mark = target:getMark("_yyfy_ex_jinglue_now-" .. player.id)
    for i = #mark, 1, -1 do
      local id = mark[i]
      if
        table.contains(
          { Card.DrawPile, Card.DiscardPile, Card.PlayerHand, Card.PlayerEquip, Card.PlayerJudge },
          room:getCardArea(id)
        )
      then
        table.remove(mark, i)
        room:setCardMark(Fk:getCardById(id), "_yyfy_ex_sishi", 0)
        room:setCardMark(Fk:getCardById(id), "yyfy_ex_sishi_forbid", 0) -- 清除禁止打出标记
        table.insert(cards, id)
      end
    end
    room:setPlayerMark(target, "_yyfy_ex_jinglue_now-" .. player.id, mark)
    if #cards > 0 then
      room:obtainCard(player, cards, true, fk.ReasonPrey, player, yyfy_ex_jinglue.name)
      -- 额外摸一张牌
      player:drawCards(1, yyfy_ex_jinglue.name)
    end
  end,
})

-- 杀额外结算
yyfy_ex_jinglue:addEffect(fk.CardUsing, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if data.from:hasSkill(yyfy_ex_jinglue.name) and 
       data.card.trueName == "slash" and
       data.from:getMark("yyfy_ex_jinglue_sha_used-turn") < 1 then
      -- 寻找死士牌
      for _, to in ipairs(data.tos) do
        for _, card_id in ipairs(to:getCardIds("h")) do
          local mark = Fk:getCardById(card_id):getMark("_yyfy_ex_sishi")
          if mark and type(mark) == "table" and mark[2] == data.from.id then
            return player and player:hasSkill(self.name)
          end
        end
      end
    end
    return false
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = yyfy_ex_jinglue.name,
      prompt = "#yyfy_ex_jinglue-sha",
    }) then
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "yyfy_ex_jinglue_sha_used-turn", 1)
    data.additionalEffect = 1 -- 额外结算1次
  end,
})

return yyfy_ex_jinglue
local gongxin = fk.CreateSkill {
  name = "yyfy_gongxin"
}

Fk:loadTranslationTable{
  ["yyfy_gongxin"] = "攻心",
  [":yyfy_gongxin"] = "出牌阶段限一次，你可以观看一名其他角色的手牌，然后你可以展示其中一张牌，选择一项："..
  "1.弃置此牌；2.将此牌置于牌堆顶。若其手牌中花色数因此减少，你可以令其本回合无法使用或打出一种颜色的牌。",

  ["yyfy_gongxin_discard"] = "弃置所选牌",
  ["yyfy_gongxin_put"] = "将所选牌置于牌堆顶",
  ["yyfy_gongxin_red"] = "令其本回合无法使用或打出红色牌",
  ["yyfy_gongxin_black"] = "令其本回合无法使用或打出黑色牌",
  ["#yyfy_gongxin-ask"] = "攻心：观看%dest的手牌，可展示其中一张牌并选择一项",
  ["#yyfy_gongxin-color"] = "攻心：你可以令%dest本回合无法使用或打出一种颜色的牌",
  ["@@yyfy_gongxin_red-turn"] = "攻心 禁红牌",
  ["@@yyfy_gongxin_black-turn"] = "攻心 禁黑牌",

  ["$yyfy_gongxin1"] = "一眼看透你的心事。",
  ["$yyfy_gongxin2"] = "你心中的防线已失陷，还不速速退走？",
}

gongxin:addEffect("active", {
  anim_type = "control",
  can_use = function(self, player)
    return player:usedSkillTimes(gongxin.name, Player.HistoryPhase) < 1
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player and not to_select:isKongcheng()
  end,
  target_num = 1,
  on_use = function(self, room, effect)
    ---@type string
    local skillName = gongxin.name
    local player = effect.from
    local target = effect.tos[1]
    local cids = target:getCardIds("h")

    local card_suits = {}
    table.forEach(cids, function(id)
      table.insertIfNeed(card_suits, Fk:getCardById(id).suit)
    end)
    local num = #card_suits
    local cards, choice = room:askToChooseCardsAndChoice(player, {
      cards = cids,
      choices = { "yyfy_gongxin_discard", "yyfy_gongxin_put" },
      skill_name = skillName,
      prompt = "#yyfy_gongxin-ask::" .. target.id,
      cancel_choices = { "Cancel" }
    })
    if #cards == 0 then
      return false
    end

    target:showCards(cards)
    if choice == "yyfy_gongxin_discard" then
      room:throwCard(cards, skillName, target, player)
    else
      room:moveCardTo(cards, Card.DrawPile, nil, fk.ReasonPut, skillName, nil, false, player)
    end
    
    -- 重新计算目标手牌花色数
    card_suits = {}
    cids = target:getCardIds("h")
    table.forEach(cids, function(id)
      table.insertIfNeed(card_suits, Fk:getCardById(id).suit)
    end)
    local num2 = #card_suits
    
    -- 如果花色数减少，询问是否发动后续效果
    if num > num2 and player:isAlive() and target:isAlive() then
      local colorChoice = room:askToChoice(player, {
        choices = {
        "yyfy_gongxin_red",
        "yyfy_gongxin_black",
        "Cancel"
        },
        skill_name = skillName,
        prompt = "#yyfy_gongxin-color::" .. target.id})
      
      if colorChoice == "yyfy_gongxin_red" then
        -- 令其本回合无法使用或打出红色牌
        room:setPlayerMark(target, "@@yyfy_gongxin_red-turn", 1)
      elseif colorChoice == "yyfy_gongxin_black" then
        -- 令其本回合无法使用或打出黑色牌
        room:setPlayerMark(target, "@@yyfy_gongxin_black-turn", 1)
      end
    end
  end,
})

local function checkProhibit(player, card)
  if card.color == Card.NoColor then -- 首先排除单张无色牌，如神张飞
    return false
  end
  local cards = card:isVirtual() and card.subcards or {card.id}
  if player:getMark("@@yyfy_gongxin_red-turn") > 0 then
    -- 红=2，黑=1，所以红-1=1，黑-1=0，可以用二进制与或进行逻辑计算
    local product = 1
    for _, id in ipairs(cards) do
      product = product * (Fk:getCardById(id).color - 1) -- 连乘，即只有全是红(1)，乘积才是红(1)，从而禁红生效
    end
    if product == 1 then
      return true
    end
  end
  
  if player:getMark("@@yyfy_gongxin_black-turn") > 0 then
    local sum = 0
    for _, id in ipairs(cards) do
      sum = sum + (Fk:getCardById(id).color - 1) -- 连加，即只有全是黑(0)，和才是黑(0)，从而禁黑生效
    end
    if sum == 0 then
      return true
    end
  end
  return false
end
-- 禁止使用或打出指定颜色的牌
gongxin:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    return checkProhibit(player, card)
  end,
  prohibit_response = function(self, player, card)
    return checkProhibit(player, card)
  end
})

-- 技能失去时清理标记
gongxin:addLoseEffect(function(self, player, is_death)
  local room = player.room
  room:setPlayerMark(player, "_yyfy_gongxin_red-turn", 0)
  room:setPlayerMark(player, "_yyfy_gongxin_black-turn", 0)
  
  -- 同时清理可能存在的禁牌标记
  if player:getMark("@@yyfy_gongxin_red-turn") > 0 then
    room:setPlayerMark(player, "@@yyfy_gongxin_red-turn", 0)
  end
  if player:getMark("@@yyfy_gongxin_black-turn") > 0 then
    room:setPlayerMark(player, "@@yyfy_gongxin_black-turn", 0)
  end
end)

return gongxin
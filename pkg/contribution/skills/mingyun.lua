local mingyun = fk.CreateSkill {
  name = "yyfy_mingyun",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable {
  ["yyfy_mingyun"] = "命运",
  [":yyfy_mingyun"] = "持恒技，回合开始时，你可以展示牌堆顶的一张牌，然后直到你的下回合开始前，" ..
      "你使用该类型的牌时，摸一张牌。你使用的基本牌数值随机+0~X（X为展示牌的点数）。",

  ["yyfy_mingyun-card"] = "命运：你可以展示牌堆顶一张牌，然后使用该类型的牌时摸一张牌",
  ["@yyfy_mingyun"] = "命运"
}

mingyun:addEffect(fk.TurnStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = mingyun.name,
      prompt = "yyfy_mingyun-card"
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:getNCards(1)
    room:showCards(cards)
    local c = Fk:getCardById(cards[1])
    local type = "基"
    if c.type == Card.TypeTrick then
      type = "锦"
    elseif c.type == Card.TypeEquip then
      type = "装"
    end
    room:setPlayerMark(player, "@yyfy_mingyun", { type, c.number })
    room:moveCards({
      ids = cards,
      toArea = Card.DrawPile,
      moveReason = fk.ReasonPut,
      skillName = mingyun.name,
    })
  end,
})

mingyun:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self) and #player:getTableMark("@yyfy_mingyun") == 2) then return false end
    local t = { "基", "锦", "装" }
    local mark = player:getTableMark("@yyfy_mingyun")
    return t[data.card.type] == mark[1] or data.card.type == Card.TypeBasic
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local t = { "基", "锦", "装" }
    local mark = player:getTableMark("@yyfy_mingyun")
    if t[data.card.type] == mark[1] then
      player:drawCards(1, mingyun.name)
    end
    local num = math.random(mark[2]) - 1
    if data.card.type ~= Card.TypeBasic then return end
    if data.card.is_damage_card then
      data.additionalDamage = (data.additionalDamage or 0) + num
    elseif data.card.name == "peach" then
      data.additionalRecover = (data.additionalRecover or 0) + num
    elseif data.card.name == "analeptic" then
      if data.extra_data and data.extra_data.analepticRecover then
        data.additionalRecover = (data.additionalRecover or 0) + num
      else
        data.extra_data = data.extra_data or {}
        data.extra_data.additionalDrank = (data.extra_data.additionalDrank or 0) + num
      end
    end
  end
})

return mingyun

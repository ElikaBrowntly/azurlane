local guidao = fk.CreateSkill {
  name = "lan__guidao",
}

Fk:loadTranslationTable{
  ["lan__guidao"] = "鬼道",
  [":lan__guidao"] = "当一名角色的判定结果确定前，你可打出一张牌替换之，若你打出的牌为【闪】【闪电】或♠2~9，你摸一张牌。",

  ["#lan__guidao-ask"] = "鬼道：可以打出一张牌替换 %dest 的“%arg”判定，若打出闪、闪电或♠2~9，你摸一张牌",

  ["$lan__guidao1"] = "电闪雷鸣，改天换日。",
  ["$lan__guidao2"] = "鬼道大开，峰回路转。",
}

guidao:addEffect(fk.AskForRetrial, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(guidao.name) and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local ids = table.filter(table.connect(player:getHandlyIds(), player:getCardIds("e")), function (id)
      return not player:prohibitResponse(Fk:getCardById(id))
    end)
    -- 非主动技中限制选牌的办法：先确定哪些牌可选，然后放到pattern里
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      skill_name = guidao.name,
      include_equip = true,
      pattern = tostring(Exppattern{ id = ids }),
      prompt = "#lan__guidao-ask::"..target.id..":"..data.reason,
      cancelable = true,
    })
    if #cards > 0 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local card = Fk:getCardById(event:getCostData(self).cards[1])
    player.room:changeJudge{
      card = card,
      player = player,
      data = data,
      skillName = guidao.name,
      response = true,
      exchange = true,
    }
    if not player.dead and (card.suit == Card.Spade and card.number > 1 and card.number < 10
    or card.name == "jink" or card.name == "lightning") then
      player:drawCards(1, guidao.name)
    end
  end,
})

return guidao
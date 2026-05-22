local chanjuan = fk.CreateSkill {
  name = "lan__chanjuan",
}

Fk:loadTranslationTable{
  ["lan__chanjuan"] = "婵娟",
  [":lan__chanjuan"] = "当你使用手牌中仅指定一个目标的基本牌或普通锦囊牌结算结束后，你可以视为使用一张此牌，若目标与之前相同，你摸一张牌。",

  ["#lan__chanjuan-use"] = "婵娟：你可以视为使用【%arg】，若目标为 %dest 则摸一张牌",

  ["$lan__chanjuan1"] = "姐妹一心，共侍玄德无忧。",
  ["$lan__chanjuan2"] = "双姝从龙，姊妹宠荣与共。",
}

chanjuan:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chanjuan.name) and
      (data.card:isCommonTrick() or data.card.type == Card.TypeBasic) and
      #data.tos == 1 and data:isUsingHandcard(player)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local use = room:askToUseVirtualCard(player, {
      name = data.card.name,
      skill_name = chanjuan.name,
      prompt = "#lan__chanjuan-use::"..data.tos[1].id..":"..data.card.name,
      cancelable = true,
      extra_data = {
        bypass_times = true,
        extraUse = true,
      },
      skip = true,
    })
    if use then
      event:setCostData(self, { extra_data = use })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local use = event:getCostData(self).extra_data
    room:useCard(use)
    if not player.dead and #use.tos == 1 and data.tos[1] == use.tos[1] then
      player:drawCards(1, chanjuan.name)
    end
  end,
})

return chanjuan
local zhifou = fk.CreateSkill {
  name = "lan__zhifou",
}

Fk:loadTranslationTable{
  ["lan__zhifou"] = "知否",
  [":lan__zhifou"] = "当你使用牌结算结束后，你可以移去1张“翼”并选择一项令一名角色执行："..
  "1.将一张牌置入“翼”；2.弃置两张牌；3.失去1点体力。",

  ["#lan__zhifou-invoke"] = "知否：你可以移去1张“翼”",
  ["#lan__zhifou-choose"] = "知否：选择一名角色，令其执行一项",
  ["lan__zhifou_put"] = "将一张牌置入“翼”",
  ["lan__zhifou_discard"] = "弃置两张牌",
  ["lan__zhifou_loseHp"] = "失去1点体力",
  ["#lan__zhifou-ask"] = "知否：你须将一张牌置为 %src 的“翼”",

  ["$lan__zhifou1"] = "满怀相思意，念君君可知？",
  ["$lan__zhifou2"] = "世有人万万，相知无二三。",
}

zhifou:addEffect(fk.CardUseFinished, {
  anim_type = "control",
  priority = 0.1,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhifou.name) and
      #player:getPile("lingxi_wing") >= 1
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      pattern = ".|.|.|lingxi_wing",
      prompt = "#lan__zhifou-invoke",
      skill_name = zhifou.name,
      cancelable = true,
      expand_pile = "lingxi_wing",
    })
    if #cards == 1 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:moveCardTo(event:getCostData(self).cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, zhifou.name)
    if player.dead then return end
    local targets = room:askToChoosePlayers(player, {
      targets = room.alive_players,
      min_num = 1,
      max_num = 1,
      skill_name = zhifou.name,
      prompt = "#lan__zhifou-choose",
      cancelable = true,
    })
    if #targets == 0 then return end
    local to = targets[1]
    local options = {
      { key = "put", name = "lan__zhifou_put", available = true },
      { key = "discard", name = "lan__zhifou_discard", available = (#to:getCardIds("he") >= 2) },
      { key = "loseHp", name = "lan__zhifou_loseHp", available = true },
    }
    local availableChoices = {}
    for _, opt in ipairs(options) do
      if opt.available then
        table.insert(availableChoices, opt.name)
      end
    end
    if #availableChoices == 0 then return end
    local choice = room:askToChoice(player, {
      choices = availableChoices,
      skill_name = zhifou.name,
      prompt = "知否：请选择一项令其执行",
      all_choices = {"lan__zhifou_put", "lan__zhifou_discard", "lan__zhifou_loseHp"}
    })
    if choice == "lan__zhifou_put" then
      if to:isNude() then
        room:doBroadcastNotify("ShowToast", "目标没有可置入的牌")
        return
      end
      local card = room:askToCards(to, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        prompt = "#lan__zhifou-ask:" .. player.id,
        skill_name = zhifou.name,
        cancelable = false,
      })
      player:addToPile("lingxi_wing", card, true, zhifou.name)
    elseif choice == "lan__zhifou_discard" then
      room:askToDiscard(to, {
        min_num = 2,
        max_num = 2,
        include_equip = true,
        skill_name = zhifou.name,
        cancelable = false,
      })
    elseif choice == "lan__zhifou_loseHp" then
      room:loseHp(to, 1, zhifou.name)
    end
  end,
})

return zhifou
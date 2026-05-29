local gangquan = fk.CreateSkill{
  name = "lan__gangquan",
}

Fk:loadTranslationTable {
  ["lan__gangquan"] = "罡拳",
  [":lan__gangquan"] = "你的装备牌可以当火【杀】使用；你的锦囊牌可以当【决斗】使用。"..
    "当你造成伤害后，你获得对方一个区域的牌。",

  ["@lan__gangquan"] = "罡拳",

  ["$lan__gangquan1"] = "罡风贯耳，为我战歌！",
  ["$lan__gangquan2"] = "用这拳头，打破一切！",
}

gangquan:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "slash,duel",
  prompt = function(self, player)
    return "罡拳：将一张装备牌当火【杀】，或将一张锦囊牌当【决斗】使用"
  end,
  handly_pile = true,
  filter_pattern = function (self, player, card_name)
    if card_name == "fire__slash" then
      return {
        max_num = 1,
        min_num = 1,
        pattern = ".|.|.|.|.|equip",
      }
    elseif card_name == "duel" then
      return {
        max_num = 1,
        min_num = 1,
        pattern = ".|.|.|.|.|trick",
      }
    end
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local c = Fk:getCardById(cards[1])
    local name = c.type == Card.TypeTrick and "duel" or "fire__slash"
    c = Fk:cloneCard(name)
    c.skillName = gangquan.name
    c:addSubcard(cards[1])
    return c
  end,
  enabled_at_play = function(self, player)
    local c = Fk:cloneCard("fire__slash")
    c.skillName = gangquan.name
    if Fk:currentRoom().current == player and player.phase == Player.Play and
    #c:getAvailableTargets(player) > 0 and c.skill:withinTimesLimit(player, 1, c) then
      return table.find(player:getCardIds("he"), function (id)
        if Fk:getCardById(id).type ~= Card.TypeEquip then return false end
        local card = Fk:cloneCard("fire__slash")
        card.skillName = gangquan.name
        card:addSubcard(id)
        return player:canUse(card) and #card:getAvailableTargets(player) > 0
      end)
    end
    return table.find(player:getCardIds("he"), function (id)
      local card = Fk:cloneCard("duel")
      card.skillName = gangquan.name
      card:addSubcard(id)
      return #card:getAvailableTargets(player) > 0 and Fk:getCardById(id).type == Card.TypeTrick and player:canUse(card)
    end)
  end,
  enabled_at_response = function(self, player, response)
    if response then return false end
    if Fk.currentResponsePattern then
      return table.find(player:getCardIds("he"), function (id)
        local c1 = Fk:cloneCard("fire__slash")
        c1.skillName = gangquan.name
        c1:addSubcard(id)
        local c2 = Fk:cloneCard("duel")
        c1.skillName = gangquan.name
        c1:addSubcard(id)
        return Exppattern:Parse(Fk.currentResponsePattern):match(c1) and
        Fk:getCardById(id).type == Card.TypeEquip and #c1:getAvailableTargets(player) > 0 or
        Exppattern:Parse(Fk.currentResponsePattern):match(c2) and
        Fk:getCardById(id).type == Card.TypeTrick and #c2:getAvailableTargets(player) > 0
      end)
    end
  end,
})

gangquan:addEffect(fk.Damage, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and #data.to:getCardIds("hej") > 0
  end,
  on_cost = function(self, event, target, player, data)
    event:setCostData(self, { tos = { data.to } })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local to = data.to
    local c1 = to:getCardIds("h")
    local c2 = to:getCardIds("e")
    local c3 = to:getCardIds("j")
    local all_choices = {"手牌区", "装备区", "判定区"}
    local choices = {}
    if #c1 > 0 then
      table.insert(choices, "手牌区")
    end
    if #c2 > 0 then
      table.insert(choices, "装备区")
    end
    if #c3 > 0 then
      table.insert(choices, "判定区")
    end
    local room = player.room
    local field = room:askToChoice(player, {
      choices = choices,
      all_choices = all_choices,
      cancelable = false
    })
    local relation = {
      ["手牌区"] = "h",
      ["装备区"] = "e",
      ["判定区"] = "j",
    }
    local cards = to:getCardIds(relation[field])
    local visible = field == "手牌区" and false or true
    room:obtainCard(player, cards, visible, fk.ReasonPrey, player, gangquan.name)
  end,
})

return gangquan
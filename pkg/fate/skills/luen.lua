local skill = fk.CreateSkill{
  name = "fate_luen",
  anim_type = "support",
  global = false,
}

Fk:loadTranslationTable{
  ["fate_luen"] = "卢恩",
  [":fate_luen"] = "结束阶段，你可以将任意张基本牌扣置在武将牌上，称为「符」；出牌阶段，"..
  "你可以将一张「符」当做一张非延时锦囊牌使用，如果当做铁索连环使用，你摸一张牌。",
  
  ["符"] = "符",
  
  ["#fate_luen-put"] = "卢恩：你可以将任意张基本牌扣置在武将牌上，称为「符」",
  ["#fate_luen-choose"] = "卢恩：请选择要将「符」当做什么非延时锦囊牌使用",
  
  ["$fate_luen1"] = "活动手指活动手指。",
  ["$fate_luen2"] = "动真格的我可是很不好对付的哦？",
}

skill:addEffect(fk.EventPhaseEnd, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
           player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room

    local basicCards = {}
    for _, id in ipairs(player:getCardIds(Player.Hand)) do
      local card = Fk:getCardById(id)
      if card.type == Card.TypeBasic then
        table.insert(basicCards, id)
      end
    end
    
    return #basicCards > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    local basicCards = {}
    for _, id in ipairs(player:getCardIds(Player.Hand)) do
      local card = Fk:getCardById(id)
      if card.type == Card.TypeBasic then
        table.insert(basicCards, id)
      end
    end
    
    -- 扣置牌
    local result = room:askToCards(player, {
      min_num=0,
      max_num=#basicCards,
      include_equip=false,
      skill_name=self.name, true, 
      prompt="#fate_luen-put",
      pattern=".|.|.|.|.|basic"})
    
    if #result > 0 then

      player:broadcastSkillInvoke(self.name, 1)

      for _, id in ipairs(result) do
        room:moveCardTo(id, Player.Special, player, 0, skill.name, "符", false, player)
      end
    end
  end,
})
-- 印牌
skill:addEffect("viewas", {
  name = "fate_luen",
  interaction = function(self, player)

    local all_choices = Fk:getAllCardNames("t")
    table.removeOne(all_choices, "nullification")
    local trickCards = player:getViewAsCardNames(skill.name, all_choices, nil)
    if #trickCards == 0 then return end
    return UI.ComboBox {
      choices = trickCards,
      all_choices = all_choices,
      prompt = "#fate_luen-choose"
    }
  end,
  expand_pile = "符",
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getPile("符"), to_select)
  end,
  
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end

    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    card:addSubcard(cards[1])
    return card
  end,
  
  after_use = function (self, player, use)
    if not player.dead and use.card.trueName == "iron_chain" then
      player:drawCards(1, skill.name)
    end
  end,
  
  enabled_at_play = function(self, player)
    return #(player:getPile("符")) > 0
  end,

})

return skill
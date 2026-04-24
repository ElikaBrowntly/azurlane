local longfeng = fk.CreateSkill {
  name = "yyfy_longfeng",
}

Fk:loadTranslationTable {
  ["yyfy_longfeng"] = "龙凤",
  [":yyfy_longfeng"] = "你可以将任意张红色牌当【火攻】或【桃】使用；你可以将任意张黑色牌当【铁索连环】或【无懈可击】使用。",

  ["$yyfy_longfeng1"] = "北伐中原，龙游雍凉，声震千里魏土。",
  ["$yyfy_longfeng2"] = "南安百黎，虬渡泸水，锦铺万洞蛮邦。",
}

longfeng:addEffect("viewas", {
  anim_type = "control",
  pattern = "nullification,peach,fire_attack,iron_chain",
  handly_pile = true,
  include_equip = true,
  interaction = function(self, player)
    local all_names = { "nullification", "peach", "fire_attack", "iron_chain" }
    return UI.CardNameBox {
      choices = player:getViewAsCardNames(longfeng.name, all_names),
      all_choices = all_names,
      default_choice = "Cancel",
    }
  end,
  card_filter = function(self, player, to_select, selected, selected_targets)
    local color = table.contains({ "nullification", "iron_chain" }, self.interaction.data) and 1 or 2
    return #selected == 0 and Fk:getCardById(to_select).color == color
  end,
  view_as = function(self, player, cards)
    if #cards == 0 then return end
    local cardName = self.interaction.data
    if cardName == "Cancel" then return nil end
    local card = Fk:cloneCard(cardName)
    card.skillName = longfeng.name
    card:addSubcards(cards)
    return card
  end,
  enabled_at_nullification = function(self, player, data)
    return table.find(player:getHandlyIds(), function(c)
      return Fk:getCardById(c).color == Card.Black
    end) ~= nil
  end,
})

return longfeng
local weizhen = fk.CreateSkill {
  name = "yyfy_weizhen",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable {
  ["yyfy_weizhen"] = "威震",
  [":yyfy_weizhen"] = "持恒技，你可以将一张牌当无次数限制的任意基本牌使用。" ..
      "此牌指定目标后，你令所有角色与此牌颜色相同的手牌均视为【杀】直到回合结束。",

  ["#yyfy_weizhen"] = "威震：将一张牌当任意基本牌使用",
  ["@yyfy_weizhen-turn"] = "威震",

  ["$yyfy_weizhen1"] = "汝等鼠辈，岂敢与某相抗！",
  ["$yyfy_weizhen2"] = "义襄千里，威震华夏！",
  ["$yyfy_weizhen3"] = "今日之敌，必死于我刀下！",
  ["$yyfy_weizhen4"] = "青龙所向，战无不胜！"
}

weizhen:addEffect("viewas", {
  anim_type = "offensive",
  prompt = "#yyfy_weizhen",
  pattern = ".|.|.|.|.|basic",
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("b")
    local names = player:getViewAsCardNames(weizhen.name, all_names, nil, nil, {
      bypass_times = true,
      extraUse = true,
    })
    if #names > 0 then
      return UI.CardNameBox { choices = names, all_choices = all_names }
    end
  end,
  include_equip = true,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcards(cards)
    card.skillName = weizhen.name
    return card
  end,
  before_use = function(self, player, use)
    use.extraUse = true
    use.extra_data = use.extra_data or {}
    use.extra_data.bypass_times = true
    use.extra_data.extraUse = true
    use.extra_data.yyfy_weizhen = player
  end
})

weizhen:addEffect(fk.TargetSpecified, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return not player.dead and data.extra_data and data.extra_data.yyfy_weizhen == player and
        data.card.color ~= Card.NoColor
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getOtherPlayers(player)) do
      local mark = p:getTableMark("@yyfy_weizhen-turn")
      if table.insertIfNeed(mark, data.card:getColorString()) then
        room:setPlayerMark(p, "@yyfy_weizhen-turn", mark)
        p:filterHandcards()
      end
    end
  end,
})

weizhen:addEffect("filter", {
  mute = true,
  card_filter = function(self, to_select, player)
    return table.contains(player:getCardIds("h"), to_select.id) and
        table.contains(player:getTableMark("@yyfy_weizhen-turn"), to_select:getColorString())
  end,
  view_as = function(self, player, to_select)
    return Fk:cloneCard("slash", to_select.suit, to_select.number)
  end,
})

return weizhen
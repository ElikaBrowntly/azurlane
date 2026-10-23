local skill = fk.CreateSkill{
  name = "yyfy_0_active&",
}

Fk:loadTranslationTable {
  ["yyfy_0_active&"] = "0",
  [":yyfy_0_active&"] = "拥有〖1〗的角色的回合内，你可以将一张牌当【无懈可击】使用。"
}

skill:addEffect("viewas", {
  anim_type = "control",
  pattern = "nullification",
  prompt = "0：你可以将一张牌当【无懈可击】使用",
  handly_pile = true,
  filter_pattern = {
    min_num = 1,
    max_num = 1,
    pattern = ".",
  },
  view_as = function(self, player, cards)
    if #cards ~= 1 or not Fk:currentRoom():getCurrent():hasSkill("yyfy_1", true) then return end
    local card = Fk:cloneCard("nullification")
    card.skillName = skill.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_response = function(self, player, response)
    return not response
  end,
  enabled_at_nullification = function (self, player, data)
    return #player:getCardIds("he") > 0 or #player:getHandlyIds(false) > 0
  end
})

return skill
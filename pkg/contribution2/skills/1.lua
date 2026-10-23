local skill = fk.CreateSkill {
  name = "yyfy_1"
}

Fk:loadTranslationTable {
  ["yyfy_1"] = "1",
  [":yyfy_1"] = "出牌阶段，你可以将一张牌当作【无中生有】使用。",

  ["#yyfy_1"] = "1：将一张牌当作【无中生有】使用"
}

skill:addEffect("viewas", {
  anim_type = "drawcard",
  pattern = "ex_nihilo",
  prompt = "#yyfy_1",
  filter_pattern = {
    min_num = 1,
    max_num = 1,
    pattern = "."
  },
  view_as = function(self, player, cards)
    if #cards ~= 1 or Fk:currentRoom():getCurrent() ~= player or
      player.phase ~= Player.Play then return end
    local card = Fk:cloneCard("ex_nihilo")
    card.skillName = skill.name
    card:addSubcard(cards[1])
    return card
  end
})

skill:addAI(nil, "vs_skill")

return skill
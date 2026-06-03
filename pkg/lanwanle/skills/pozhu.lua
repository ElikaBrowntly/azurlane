local pozhu = fk.CreateSkill{
  name = "lan__pozhu",
}

Fk:loadTranslationTable{
  ["lan__pozhu"] = "破竹",
  [":lan__pozhu"] = "出牌阶段，你可以将一张牌当【<a href=':yyfy_unexpectation'><font color='#8300FF'>出其不意</font></a>】使用。",

  ["#lan__pozhu"] = "破竹：你可以将一张牌当【出其不意】使用",

  ["$lan__pozhu1"] = "灭国之战，当奋破竹之势，秉吾当继前！",
  ["$lan__pozhu2"] = "用兵当以奇，奇计如迷踪，势可破竹。",
  ["$lan__pozhu3"] = "试问朽木之堤，何当滔滔九天之水？",
  ["$lan__pozhu4"] = "吴鹿失于野，覆稷火而燎东南之原。",
}

pozhu:addEffect("viewas", {
  anim_type = "offensive",
  prompt = "#lan__pozhu",
  handly_pile = true,
  filter_pattern = {
    min_num = 1,
    max_num = 1,
    pattern = ".|.|.|.",
  },
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local c = Fk:cloneCard("yyfy_unexpectation")
    c.skillName = pozhu.name
    c:addSubcard(cards[1])
    return c
  end,
})

return pozhu
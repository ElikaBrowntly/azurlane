local yishi = fk.CreateSkill{
  name = "yyfy_yishi",
}

Fk:loadTranslationTable{
  ["yyfy_yishi"] = "义释",
  [":yyfy_yishi"] = "暂未实装",

  ["#yyfy_yishi"] = "傲斩：你可以将所有手牌当【杀】使用"
}

-- 出牌阶段主动发动
-- yishi:addEffect("active", {
--   anim_type = "offensive",
--   prompt = "#yyfy_yishi",
--   card_num = 0,
--   target_num = 1,
--   can_use = function(self, player)
--     return player and #player:getCardIds("h") > 0
--   end,
--   card_filter = Util.FalseFunc,
--   target_filter = function(self, player, to_select, selected, selected_cards)
--     return #selected == 0 and to_select ~= player and to_select:isAlive()
--   end,
--   on_use = function(self, room, effect)
--     slash(effect.from, effect.tos[1])
--   end,
-- })

return yishi
local yyfy_ex_baiyi = fk.CreateSkill {
  name = "yyfy_ex_baiyi",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["yyfy_ex_baiyi"] = "败移",
  [":yyfy_ex_baiyi"] = "限定技，出牌阶段，你可选择两名角色，令这两名角色交换座次。",
  ["#yyfy_ex_baiyi"] = "请选择两名角色，令这两名角色交换座次。",

  ["$yyfy_ex_baiyi1"] = "正为应敌之时，不可大贬将兵。",
  ["$yyfy_ex_baiyi2"] = "此吾之过也，望诸君勿复言之。",
}

yyfy_ex_baiyi:addEffect("active", {
  anim_type = "control",
  prompt = "#yyfy_ex_baiyi",
  card_num = 0,
  target_num = 2,
  target_filter = function(self, player, to_select, selected)
    return #selected < 2
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(yyfy_ex_baiyi.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, room, effect)
    local from, to = effect.tos[1], effect.tos[2]
    room:swapSeat(from, to)
  end
})

return yyfy_ex_baiyi
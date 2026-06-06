local baiyi = fk.CreateSkill {
  name = "lan__baiyi"
}

Fk:loadTranslationTable{
  ["lan__baiyi"] = "败移",
  [":lan__baiyi"] = "出牌阶段限一次，你可令两名其他角色交换座次。",
  ["#lan__baiyi"] = "请选择两名角色，令这两名角色交换座次。",

  ["$lan__baiyi1"] = "正为应敌之时，不可大贬将兵。",
  ["$lan__baiyi2"] = "此吾之过也，望诸君勿复言之。",
}

baiyi:addEffect("active", {
  anim_type = "control",
  prompt = "#lan__baiyi",
  card_num = 0,
  target_num = 2,
  target_filter = function(self, player, to_select, selected)
    return #selected < 2 and to_select ~= player
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(baiyi.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, room, effect)
    local from, to = effect.tos[1], effect.tos[2]
    room:swapSeat(from, to)
  end
})

return baiyi
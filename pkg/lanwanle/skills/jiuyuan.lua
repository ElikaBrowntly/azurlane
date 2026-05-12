local jiuyuan = fk.CreateSkill {
  name = "lan__jiuyuan",
  tags = { Skill.Lord },
}

Fk:loadTranslationTable{
  ["lan__jiuyuan"] = "救援",
  [":lan__jiuyuan"] = "主公技，出牌阶段限一次，你可以获得一名其他吴势力角色装备区里的所有牌，然后你回复1点体力。",

  ["#lan__jiuyuan"] = "救援：获得一名吴势力角色所有装备并回复1点体力",

  ["$lan__jiuyuan1"] = "公奕且在此断后，事成许你荡寇将军！",
  ["$lan__jiuyuan2"] = "卿身披数创，皆是为孤。",
}

jiuyuan:addEffect("active", {
  anim_type = "control",
  prompt = "#lan__jiuyuan",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(jiuyuan.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player and to_select.kingdom == "wu" and #to_select:getCardIds("e") > 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:obtainCard(player, effect.tos[1]:getCardIds("e"), true, fk.ReasonPrey, player, jiuyuan.name)
    if not player.dead then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = jiuyuan.name,
      }
    end
  end
})

return jiuyuan
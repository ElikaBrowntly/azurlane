local yuanshi = fk.CreateSkill {
  name = "yyfy_yuanshi",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable {
  ["yyfy_yuanshi"] = "元始",
  [":yyfy_yuanshi"] = "持恒技，出牌阶段，你可以失去1点体力，然后令一名角色的技能视为未发动过。",
}

yuanshi:addEffect("active", {
  anim_type = "support",
  prompt = "你可以失去1点体力，令一名角色的技能视为未发动过",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return (player:getMark("yyfy_yuanshi_slash-phase") == 0 or player:getMark("yyfy_yuanshi_duel-phase") == 0) and
        player:usedSkillTimes(self.name, Player.HistoryPhase) < 2
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select:isAlive()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:loseHp(player, 1, yuanshi.name, player)
    local skill = player:getSkillNameList()
    for _, name in ipairs(skill) do
      player:clearSkillHistory(name)
      -- 暂时无法对Fk.skills[name].times进行复原，因为不知道原本的times最大是多少
    end
  end,
})

return yuanshi

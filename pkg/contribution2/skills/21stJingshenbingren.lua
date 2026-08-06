local skill = fk.CreateSkill {
  name = "yyfy_21stJingshenbingren",
  tags = { Skill.Limited },
  related_skills = { "yyfy_Monster" }
}

Fk:loadTranslationTable {
  ["yyfy_21stJingshenbingren"] = "21世纪精神病人",
  [":yyfy_21stJingshenbingren"] = "限定技，出牌阶段，你可以失去所有技能，令一名其他角色获得〖Monster〗，然后若你的武将牌为奈亚子，将你的武将牌替换为奈亚拉托提普。",
}

skill:addEffect("active", {
  anim_type = "big",
  can_use = function(self, player)
    return player and player:hasSkill(self) and player:usedSkillTimes(skill.name, Player.HistoryGame) == 0
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  target_num = 1,
  target_filter = function (self, player, to_select, selected, selected_cards, card, extra_data)
    return #selected == 0 and to_select:isAlive() and to_select ~= player
  end,
  prompt = "你可以失去所有技能，选择一名角色获得〖Monster〗",
  on_use = function(self, room, effect)
    local player = effect.from
    local tos = effect.tos
    if not tos or #tos ~= 1 then return end
    local skills = player:getSkillNameList()
    local lose = {}
    for _, s in ipairs(skills) do
      ---@diagnostic disable-next-line: undefined-field
      if not Fk.skills[s].mode_skill then
        table.insert(lose, "-"..s)
      end
    end
    room:handleAddLoseSkills(player, lose)
    room:handleAddLoseSkills(tos[1], "yyfy_Monster")
  end
})

return skill
local shaonian = fk.CreateSkill {
  name = "yyfy_shaonian",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["yyfy_shaonian"] = "少年",
  [":yyfy_shaonian"] = "出牌阶段限一次，你可以选择一名其他角色，赐予其一个其他化身。"..
  "其他角色受到另一名其他角色的伤害后，你可以赐予其一个其他化身。",
  ["#yyfy_shaonian-skill"] = "少年：请赐予 %dest 一个化身",
  ["#yyfy_shaonian-target"] = "少年：你可以赐予 %dest 一个化身"
}

local all_skills = {
  "yyfy_qiangfeng", "yyfy_gongniu", "yyfy_baima", "yyfy_luotuo", "yyfy_shanzhu",
  "yyfy_fenghuang", "yyfy_muyang", "yyfy_shanyang", "yyfy_zhanshi"
}

---赐予其他角色化身的函数
---@param player ServerPlayer
---@param to ServerPlayer
local function giveHuashen(player, to)
  local room = player.room
  local available_skills = all_skills
  -- 让对方已有的技能不可选
  for _, skill in ipairs(all_skills) do
    if to:hasSkill(skill) then
      table.removeOne(available_skills, skill)
    end
  end
  local chosen_skill = room:askToChoice(player, {
    choices = available_skills,
    skill_name = shaonian.name,
    prompt = "#yyfy_shaonian-skill::"..to.id,
    all_choices = all_skills -- 让不可选选项变灰
  })
  room:handleAddLoseSkills(to, chosen_skill, shaonian.name, true, true)
end

shaonian:addEffect("active", {
  anim_type = "support",
  max_phase_use_time = 1,
  target_num = 1,
  target_filter = function (self, player, to_select, selected, selected_cards, card, extra_data)
    return to_select and to_select ~= player and #selected == 0
  end,
  card_num = 0,
  prompt = "你可以选择一名其他角色，赐予其一个化身",
  on_use = function (self, room, effect)
    giveHuashen(effect.from, effect.tos[1])
  end
})

shaonian:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self.name) and data.to
    and data.from ~= player and data.from ~= data.to -- 伤害来源可以是死的，承伤角色可以是修整的
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "#yyfy_shaonian-target::"..data.to.id
    })
  end,
  on_use = function (self, event, target, player, data)
    giveHuashen(player, data.to)
  end
})

return shaonian
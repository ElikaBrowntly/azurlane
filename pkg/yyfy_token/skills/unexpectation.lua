local skill = fk.CreateSkill {
  name = "yyfy_unexpectation_skill",
}

Fk:loadTranslationTable {
  ["yyfy_unexpectation_skill"] = "出其不意",
  ["#yyfy_unexpectation_skill"] = "展示目标角色的一张手牌，并对其造成1点伤害",
}

skill:addEffect("cardskill", {
  prompt = "#yyfy_unexpectation_skill",
  target_num = 1,
  mod_target_filter = function(self, player, to_select, selected, card)
    return to_select ~= player
  end,
  target_filter = Util.CardTargetFilter,
  on_effect = function(self, room, effect)
    local player = effect.from
    local target = effect.to
    if not target:isKongcheng() then
      local card = room:askToChooseCard(player, {
        target = target,
        flag = "h",
        skill_name = skill.name,
      })
      target:showCards(card)
    end
    if target.dead then return end
    room:damage {
      from = player,
      to = target,
      card = effect.card,
      damage = 1,
      skillName = skill.name,
    }
  end,
})

return skill
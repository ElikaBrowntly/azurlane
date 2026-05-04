local QC_huoji = fk.CreateSkill{
  name = "QC_huoji",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["QC_huoji"] = "火计",
  [":QC_huoji"] = "持恒技，出牌阶段限一次，你可以选择一名其他角色，对其及其同势力的其他角色各造成X点火焰伤害（X为你的体力上限）。",
  ["#QC_huoji"] = "火计：选择一名其他角色，对其及同势力角色各造成 %arg 点火焰伤害",
}

QC_huoji:addEffect("active", {
  anim_type = "offensive",
  max_phase_use_time = 1,
  target_num = 1,
  target_filter = function(self, player, to_select, selected)
    return #selected < 1 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local damage = player.maxHp

    local targets = {}
    for _, p in ipairs(room:getAlivePlayers()) do
      if p ~= player and p.kingdom == target.kingdom then
        table.insert(targets, p)
      end
    end

    for _, p in ipairs(targets) do
      if not p.dead then
        room:damage{
          from = player,
          to = p,
          damage = damage,
          damageType = fk.FireDamage,
          skillName = QC_huoji.name,
        }
      end
    end
  end,
})

return QC_huoji
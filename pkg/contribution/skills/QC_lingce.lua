local QC_lingce = fk.CreateSkill{
  name = "QC_lingce",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["QC_lingce"] = "灵策",
  [":QC_lingce"] = "持恒技，当有牌被使用时，你可以摸1~X张牌或对一名角色造成1~X点伤害（X为本局游戏你发动灵策的次数）。",
  ["@QC_lingce"] = "灵策",
  ["#QC_lingce-choice"] = "灵策：请选择摸牌或造成伤害",
  ["#QC_lingce-target"] = "灵策：请选择造成伤害的目标",
}

QC_lingce:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(QC_lingce.name) and data.card ~= nil
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local current_count = player:getMark("@QC_lingce")
    local times = (current_count or 0) + 1

    local choice = room:askToChoice(player, {
      choices = {"摸牌", "伤害"},
      prompt = "#QC_lingce-choice",
      skill_name = QC_lingce.name,
    })

    if choice == "摸牌" then
      local draw_num = math.random(1, times)
      if draw_num > 0 then
        player:drawCards(draw_num, QC_lingce.name)
      end
    else
      local tos = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = room.alive_players,
        prompt = "#QC_lingce-target",
        skill_name = QC_lingce.name,
        cancelable = true,
      })
      if #tos > 0 then
        local damage = math.random(1, times)
        room:damage{
          from = player,
          to = tos[1],
          damage = damage,
          skillName = QC_lingce.name,
        }
      end
    end

    room:addPlayerMark(player, "@QC_lingce", 1)
  end,
})

return QC_lingce
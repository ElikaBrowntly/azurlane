local QC_taoxian = fk.CreateSkill{
  name = "QC_taoxian",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["QC_taoxian"] = "桃仙",
  [":QC_taoxian"] = "持恒技，你可以将一张红色牌当【桃】使用。有角色使用【桃】时，若其为其他角色，你可令此桃无效或摸1~X张牌；若为你，则你摸1~X张牌。（X为本局游戏你发动桃仙的次数）",
  ["@QC_taoxian"] = "桃仙",
  ["#QC_taoxian1"] = "你可以将一张红色牌当【桃】使用。",
  ["#QC_taoxian2"] = "你可以令此【桃】无效，或摸1~X张牌。",
}

QC_taoxian:addEffect("viewas", {
  anim_type = "support",
  pattern = "peach",
  prompt = "#QC_taoxian1",
  card_filter = function(self, player, to_select, selected)
    if #selected == 1 then return false end
    return Fk:getCardById(to_select).color == Card.Red
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return nil end
    local card = Fk:cloneCard("peach")
    card.skillName = QC_taoxian.name
    card:addSubcard(cards[1])
    return card
  end,
})

QC_taoxian:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(QC_taoxian.name) and data.card and data.card.trueName == "peach"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room

    room:addPlayerMark(player, "@QC_taoxian", 1)
    local x = player:getMark("@QC_taoxian")

    if target == player then

      local draw_num = math.random(1, x)
      if draw_num > 0 then
        player:drawCards(draw_num, QC_taoxian.name)
      end
    else

      local choice = room:askToChoice(player, {
        choices = { "无效", "摸牌" },
        prompt = "#QC_taoxian2",
        cancelable = true,
        skill_name = QC_taoxian.name,
      })
      if choice == "无效" then
        data.nullifiedTargets = room:getOtherPlayers(player) 
      elseif choice == "摸牌" then
        local draw_num = math.random(1, x)
        if draw_num > 0 then
          player:drawCards(draw_num, QC_taoxian.name)
        end
      end
    end
  end,
})

return QC_taoxian
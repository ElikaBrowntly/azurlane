local hengwu = fk.CreateSkill {
  name = "yyfy_hengwu",
}

Fk:loadTranslationTable {
  ["yyfy_hengwu"] = "横鹜",
  [":yyfy_hengwu"] = "每名角色各限一次，出牌阶段，你可以将一张坐骑牌置入一名其他角色的装备区并声明一张牌名"..
  "（本轮你不能成为该角色使用此牌名的目标）。" ,

  ["$yyfy_hengwu1"] = "横枪立马，独啸秋风！",
  ["$yyfy_hengwu2"] = "世皆彳亍，唯我纵横！"
}

hengwu:addEffect("active", {
  anim_type = "control",
  can_use = function (self, player)
    if not (player and player:isAlive() and player:hasSkill(self.name) and
      Fk:currentRoom():getCurrent() == player and player.phase == Player.Play) then return false end
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      local include = false
      for _, id in ipairs(player:getTableMark("yyfy_hengwu")) do
        if p.id == id then
          include = true
          break
        end
      end
      if not include then return true end
    end
  end,
  card_num = 1,
  target_num = 1,
  target_filter = function (self, player, to_select, selected, selected_cards, card, extra_data)
    for _, id in ipairs(player:getTableMark("yyfy_hengwu")) do
      if to_select.id == id then
        return false
      end
    end
    if #selected == 0 and to_select.id ~= player.id then return true end
    return false
  end,
  card_filter = function (self, player, to_select, selected, selected_targets)
    local card = Fk:getCardById(to_select)
    return (card.sub_type == Card.SubtypeOffensiveRide or
    card.sub_type == Card.SubtypeDefensiveRide) and #selected == 0
  end,
  on_cost = function (self, player, data, extra_data)
    local all_choices = Fk:getAllCardNames("btd", true)
    local choice = player.room:askToChoice(player, {
      skill_name = hengwu.name,
      choices = all_choices,
      prompt = "横鹜：请声明一个卡名，本轮你不能成为该角色使用此牌名的目标",
      cancelable = false
    })
    player.room:addPlayerMark(data.tos[1], "yyfy_hengwu_"..choice.."-round")
  end,
  on_use = function (self, room, event)
    room:moveCardIntoEquip(event.tos[1], event.cards, hengwu.name, true, event.from)
    room:addTableMark(event.from, "yyfy_hengwu", event.tos[1].id)
  end
})

hengwu:addEffect("prohibit", {
  is_prohibited = function(self, from, to, card)
    return card and from and to and from ~= to and to:hasSkill(self.name)
    and from:getMark("yyfy_hengwu_"..card.trueName.."-round") > 0
  end,
})

return hengwu
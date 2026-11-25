local renxia = fk.CreateSkill {
  name = "yyfy_renxia",
}

Fk:loadTranslationTable {
  ["yyfy_renxia"] = "任侠",
  [":yyfy_renxia"] = "出牌阶段各限一次，你可以<font color='red'>摸</font>/<font color='blue'>弃置</font>2张牌，"..
  "然后若<font color='red'>你的手牌</font>/<font color='blue'>弃置的牌</font>中没有伤害牌，此技能视为未发动过。",

  ["#yyfy_renxia"] = "任侠：你可以摸或弃置2张牌",
  ["@yyfy_renxia"] = "任侠",
  ["$yyfy_renxia"] = "俊毅如风……"
}

renxia:addEffect("active", {
  mute = true,
  prompt = "#yyfy_renxia",
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  can_use = function(self, player)
    return #player:getTableMark("@" .. renxia.name) < 2
  end,
  interaction = function(self, player)
    local all = { "摸2张牌", "弃置2张牌" }
    local choices = table.clone(all)
    local already = player:getTableMark("@" .. renxia.name)
    if #player:getCardIds("he") < 2 or table.contains(already, "弃") then
      table.remove(choices)
    end
    if table.contains(already, "摸") then
      table.remove(choices, 1)
    end
    return UI.ComboBox { choices = choices, all_choices = all }
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local choice = self.interaction.data
    local cards = {}
    if not choice then return end
    local anim = choice == "弃置2张牌" and "negative" or "drawcard"
    room:notifySkillInvoked(player, renxia.name, anim)
    player:broadcastSkillInvoke(renxia.name)
    if choice == "摸2张牌" then
      room:drawCards(player, 2, renxia.name)
      room:addTableMarkIfNeed(player, "@" .. renxia.name, "摸")
      cards = player:getCardIds("h")
    else
      cards = room:askToDiscard(player, {
        min_num = 2,
        max_num = 2,
        include_equip = true,
        skill_name = renxia.name,
        prompt = "任侠：请弃置2张牌"
      })
      room:addTableMarkIfNeed(player, "@" .. renxia.name, "弃")
    end
    if table.find(cards, function(id)
          return Fk:getCardById(id).is_damage_card
        end) then
      return
    end
    room:setPlayerMark(player, "@" .. renxia.name, 0)
  end
})

return renxia
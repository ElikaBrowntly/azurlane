local yishi = fk.CreateSkill{
  name = "yyfy_yishi&",
}

Fk:loadTranslationTable{
  ["yyfy_yishi&"] = "义释",
  [":yyfy_yishi&"] = "出牌阶段内限1次，你可选择1名其他角色，交给其1张牌，若你选择的角色与此技能原拥有者"..
  "势力相同，则至多交出4张。你每交给与原拥有者同势力的角色2张牌，其对你下次造成的伤害便-1。",
}

yishi:addEffect("active", {
  anim_type = "support",
  prompt = "义释：你可以交给一名角色1或4张牌",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player and #player:getCardIds("he") > 0 and #Fk:currentRoom().alive_players > 1
    and player:usedSkillTimes(yishi.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player and to_select:isAlive()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    if #effect.tos ~= 1 then return end
    local to = effect.tos[1]
    local kingdoms = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if p:hasSkill("yyfy_yishi", true) then
        table.insertIfNeed(kingdoms, p.kingdom)
      end
    end
    local num = 1
    if table.contains(kingdoms, to.kingdom) then
      num = 4
    end
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = num,
      skill_name = yishi.name,
      prompt = "义释：你可以交给其至多"..tostring(num).."张牌",
      include_equip = true,
      cancelable = false
    })
    room:moveCardTo(cards, Player.Hand, to, fk.ReasonGive, "yyfy_yishi")
    if num == 4 then
      num = math.floor(#cards / 2)
    end
    room:addPlayerMark(player, "@yyfy_yishi", num)
  end,
})

return yishi
local shengong = fk.CreateSkill {
  name = "yyfy_shengong",
}

Fk:loadTranslationTable {
  ["yyfy_shengong"] = "神弓",
  [":yyfy_shengong"] = "获得此技能时或出牌阶段限一次，你可以令一名其他角色隐匿并射杀该角色。"
}

shengong:addAcquireEffect(function(self, player, is_start, src)
  local room = player.room
  local choice = room:askToChoosePlayers(player, {
    targets = room:getOtherPlayers(player),
    min_num = 1,
    max_num = 1,
    skill_name = shengong.name,
    prompt = "神弓：请选择要射杀的角色",
    cancelable = true
  })
  if #choice ~= 1 then return end
  choice = choice[1]
  room:setPlayerMark(choice, "__hidden_general", choice.general)
  local deputy = choice.deputyGeneral or ""
  if Fk.generals[deputy] then
    room:setPlayerMark(choice, "__hidden_deputy", deputy)
    room:setPlayerProperty(choice, "deputyGeneral", "")
  end
  room:setPlayerProperty(choice, "general", "hiddenone")
  room:setPlayerProperty(choice, "gender", (Fk.generals["hiddenone"] or {}).gender or 4)
  room:setPlayerProperty(choice, "kingdom", "jin")
  room:killPlayer({
    who = choice,
    killer = player
  })
end)

shengong:addEffect("active", {
  prompt = "神弓：你可以射杀一名角色",
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  max_phase_use_time = 1,
  target_filter = function(self, player, to_select, selected, selected_cards, card, extra_data)
    return to_select and to_select:isAlive() and to_select ~= player and #selected == 0
  end,
  can_use = function(self, player)
    return player and player.phase == Player.Play and player:hasSkill(self)
        and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local tos = effect.tos
    if #tos ~= 1 then return end
    local choice = tos[1]
    room:setPlayerMark(choice, "__hidden_general", choice.general)
    local deputy = choice.deputyGeneral or ""
    if Fk.generals[deputy] then
      room:setPlayerMark(choice, "__hidden_deputy", deputy)
      room:setPlayerProperty(choice, "deputyGeneral", "")
    end
    room:setPlayerProperty(choice, "general", "hiddenone")
    room:setPlayerProperty(choice, "gender", (Fk.generals["hiddenone"] or {}).gender or 4)
    room:setPlayerProperty(choice, "kingdom", "jin")
    room:killPlayer({
      who = choice,
      killer = effect.from
    })
  end
})

return shengong
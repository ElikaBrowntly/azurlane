local shengong = fk.CreateSkill {
  name = "yyfy_shengong",
}

Fk:loadTranslationTable {
  ["yyfy_shengong"] = "神弓",
  [":yyfy_shengong"] = "获得此技能时或出牌阶段限一次，你可以令一名其他角色隐匿并射杀该角色。"
}

---进入隐匿状态
---@param player ServerPlayer @ 目标角色
local function enterHidden(player)
  local room = player.room
  local skills = "hidden_skill&"
  room:setPlayerMark(player, "__hidden_general", player.general)
  for _, s in ipairs(Fk.generals[player.general]:getSkillNameList(true)) do
    if player:hasSkill(s, true) then
      skills = skills.."|-"..s
    end
  end
  if player.deputyGeneral ~= "" then
    room:setPlayerMark(player, "__hidden_deputy", player.deputyGeneral)
    for _, s in ipairs(Fk.generals[player.deputyGeneral]:getSkillNameList(true)) do
      if player:hasSkill(s, true) then
        skills = skills.."|-"..s
      end
    end
  end
  player.general = "hiddenone"
  player.gender = General.Male
  room:broadcastProperty(player, "gender")
  if player.deputyGeneral ~= "" then
    player.deputyGeneral = ""
  end
  player.kingdom = "jin"
  room:setPlayerMark(player, "__hidden_record",
  {
    maxHp = player.maxHp,
    hp = player.hp,
  })
  player.maxHp = 1
  player.hp = 1
  for _, property in ipairs({"general", "deputyGeneral", "kingdom", "maxHp", "hp"}) do
    room:broadcastProperty(player, property)
  end
  room:handleAddLoseSkills(player, skills, nil, false, true)
end

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
  enterHidden(choice)
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
    enterHidden(choice)
    room:killPlayer({
      who = choice,
      killer = effect.from
    })
  end
})

return shengong
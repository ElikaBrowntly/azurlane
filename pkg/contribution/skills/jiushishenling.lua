local jiushishenling = fk.CreateSkill{
  name = "yyfy_jiushishenling",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["yyfy_jiushishenling"] = "救世神灵",
  [":yyfy_jiushishenling"] = "永恒技，出牌阶段限一次或其他角色死亡时，"..
  "你可以使〖轮回〗中的数字+1，然后复活任意名角色，若如此做，你失去所有体力。"
}

jiushishenling:addLoseEffect(function(self, player, is_death)
  player.room:handleAddLoseSkills(player, self.name, nil, false, true)
end)

---@param player ServerPlayer
local function doFuhuo(player)
  local room = player.room
  local round = player.tag["yyfy_lunhui"] or 0
  round = round + 1
  player.tag["yyfy_lunhui"] = round
  local players = room:getAllPlayers()
  local targets = {}
  for _, p in ipairs(players) do
    if p.dead then
      table.insert(targets, tostring(p.seat).."号位")
    end
  end
  if #targets == 0 then return end
  local choices = room:askToChoices(player, {
    choices = targets,
    min_num = 0,
    max_num = #targets,
    skill_name = jiushishenling.name,
    prompt = "救世神灵：请令任意名角色复活",
    cancelable = true
  })
  if #choices == 0 then return end
  for _, c in ipairs(choices) do
    local seat = tonumber(c[1])
    if seat ~= nil then
      room:revivePlayer(room:getPlayerBySeat(seat), true, jiushishenling.name)
    end
  end
  room:loseHp(player, player.hp, jiushishenling.name, player)
end

jiushishenling:addEffect(fk.Death, {
  anim_type = "support",
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self, true) and target ~= player
  end,
  on_trigger = function (self, event, target, player, data)
    doFuhuo(player)
  end
})

jiushishenling:addEffect("active", {
  anim_type = "support",
  max_phase_use_time = 1,
  card_num = 0,
  target_num = 0,
  prompt = "救世神灵：你可以令任意名角色复活",
  can_use = function (self, player)
    if player:usedSkillTimes(jiushishenling.name, Player.HistoryPhase) > 0 then return false end
    local players = Fk:currentRoom().players
    local targets = {}
    for _, p in ipairs(players) do
      if p.dead then
        table.insert(targets, p)
      end
    end
    if #targets > 0 then
      return true
    end
  end,
  on_use = function (self, room, data)
    doFuhuo(data.from)
  end
})

return jiushishenling
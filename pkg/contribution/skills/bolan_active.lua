local bolan_active = fk.CreateSkill{
  name = "yyfy_bolan&",
  dynamic_desc = function (self, player, lang)
    return table.find(Fk:currentRoom().alive_players, function (p)
        return p:hasSkill("yyfy_bolan") and p:getMark("@@yyfy_yifa-turn") > 0
      end) and "出牌阶段限一次，你可以失去1点体力，令钟琰从随机三个“受到伤害后”的技能中选择一个，你获得之直到此阶段结束。"
      or "出牌阶段限一次，你可以失去1点体力，令钟琰从随机三个“出牌阶段限一次”的技能中选择一个，你获得之直到此阶段结束。"
  end
}

Fk:loadTranslationTable{
  ["yyfy_bolan&"] = "博览",
  [":yyfy_bolan&"] = "出牌阶段限一次，你可以失去1点体力，令钟琰从随机三个“出牌阶段限一次”的技能中选择一个，你获得之直到此阶段结束。",

  ["#yyfy_bolan"] = "博览：你可以令钟琰从三个“出牌阶段限一次”的技能中选择一个令你获得，然后你失去1点体力",
}

---@param room Room
local getBolanSkills = function(room)
  local mark = room:getBanner("yyfy_BolanSkills")
  if mark then
    return mark
  else
    local all_skills = {}
    for _, g in ipairs(room.general_pile) do
      for _, s in ipairs(Fk.generals[g]:getSkillNameList()) do
        table.insert(all_skills, s)
      end
    end
    local skills = table.filter(BolanSkills, function(s) return table.contains(all_skills, s) end)
    room:setBanner("yyfy_BolanSkills", skills)
    return skills
  end
end

---@param room Room
local getBolanSkills2 = function(room)
  local mark = room:getBanner("yyfy_BolanSkills2")
  if mark then
    return mark
  else
    local all_skills = {}
    for _, g in ipairs(room.general_pile) do
      for _, s in ipairs(Fk.generals[g]:getSkillNameList()) do
        table.insert(all_skills, s)
      end
    end
    local skills = table.filter(BolanSkills2, function(s) return table.contains(all_skills, s) end)
    room:setBanner("yyfy_BolanSkills2", skills)
    return skills
  end
end

bolan_active:addEffect("active", {
  prompt = "#yyfy_bolan",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(bolan_active.name, Player.HistoryPhase) == 0 and
      table.find(Fk:currentRoom().alive_players, function (p)
        return p:hasSkill("yyfy_bolan")
      end)
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = table.find(room:getOtherPlayers(player, false), function(p)
      return p:hasSkill("yyfy_bolan")
    end)
    if not target then return end
    target:broadcastSkillInvoke("yyfy_bolan")
    room:doIndicate(player, {target})
    if player.dead or target.dead then return end
    local all_skills = target:getMark("@@yyfy_yifa-turn") == 0 and getBolanSkills(room) or getBolanSkills2(room)
    local skills = table.filter(all_skills, function (skill_name)
      return not player:hasSkill(skill_name, true)
    end)
    if #skills > 0 then
      local choice = room:askToChoice(target, {
        choices = room:tableRandomPick(skills, 3),
        skill_name = "yyfy_bolan",
        prompt = "#yyfy_bolan-choice::"..player.id,
        detailed = true,
      })
      room:handleAddLoseSkills(player, choice)
      room.logic:getCurrentEvent():findParent(GameEvent.Phase):addCleaner(function()
        room:handleAddLoseSkills(player, "-"..choice)
      end)
    end
    room:loseHp(player, 1, "yyfy_bolan")
  end,
})

return bolan_active
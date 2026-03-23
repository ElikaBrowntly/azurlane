local shoushu = fk.CreateSkill{
  name = "yyfy_shoushu",
}

Fk:loadTranslationTable{
  ["yyfy_shoushu"] = "授术",
  [":yyfy_shoushu"] = "出牌阶段限一次，或当你受到伤害后，你可以将一册<a href='yyfy_tianshu_href'>“天书”</a>交给一名其他角色。",


  ["#yyfy_shoushu"] = "授术：你可以将一册“天书”交给一名其他角色",
  ["#yyfy_shoushu-give"] = "授术：选择交给 %dest 的“天书”",

  ["$yyfy_shoushu1"] = "此书载天地至理，望汝珍视如命。",
  ["$yyfy_shoushu2"] = "我得道成仙，当出世化生人中。",
  ["$yyfy_shoushu3"] = "世人皆慕长生，却不见多少仙人，枯老在这白玉京！",
  ["$yyfy_shoushu4"] = "今授汝天书三卷，望汝救万民于水火。"
}

--- 给予目标一本天书
local function doGive(room, player, target, skillName)
  -- 获取符合条件的技能
  local skills = player:getTableMark("@[yyfy_tianshu]")
  if #skills == 0 then return false end

  local skillNames = table.map(skills, function (info) return info.skillName end)
  local args = {}
  for _, s in ipairs(skillNames) do
    local info = room:getBanner("yyfy_tianshu_skills")[s]
    table.insert(args, Fk:translate("yyfy_tianshu_triggers"..info[1]).."，"..Fk:translate("yyfy_tianshu_effects"..info[2]).."。")
  end

  local choice = room:askToChoice(player, {
    choices = args,
    skill_name = skillName,
    prompt = "#yyfy_shoushu-give::"..target.id,
    cancelable = true,
  })
  if choice == "Cancel" then return false end

  local chosenSkill = skillNames[table.indexOf(args, choice)]
  room:handleAddLoseSkills(player, "-"..chosenSkill)
  room:handleAddLoseSkills(target, chosenSkill)
  return true
end

-- 出牌阶段主动发动
shoushu:addEffect("active", {
  anim_type = "support",
  prompt = "#yyfy_shoushu",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player and player:usedSkillTimes(shoushu.name, Player.HistoryTurn) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player and to_select:isAlive()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    doGive(room, player, target, shoushu.name)
  end,
})

-- 受伤后触发
shoushu:addEffect(fk.Damaged, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    -- 至少有一本天书
    return target == player and player:hasSkill(shoushu.name, true) and
      #player:getTableMark("@[yyfy_tianshu]") > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = room:getOtherPlayers(player, false)
    if #targets == 0 then return false end
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      skill_name = shoushu.name,
      prompt = "#yyfy_shoushu",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, { to = to[1] })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).to
    doGive(room, player, to, shoushu.name)
  end,
})

return shoushu
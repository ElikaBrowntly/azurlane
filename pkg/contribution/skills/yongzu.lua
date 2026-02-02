local yongzu = fk.CreateSkill{
  name = "lan__yongzu",
}

Fk:loadTranslationTable{
  ["lan__yongzu"] = "拥族",
  [":lan__yongzu"] = "准备阶段，你可以选择一名其他角色，你与其依次选择一项："..
  "<br>1.摸两张牌；<br>2.回复1点体力；<br>3.复原武将牌。<br>4.手牌上限+2；<br>"..
  "5.获得技能<font color='blue'>〖奸雄〗</font>或<font color='grey'>〖天命〗</font>。",

  ["#lan__yongzu-choose"] = "拥族：你可以选择一名角色，与其依次执行一项",
  ["lan__yongzu_skill"] = "获得%arg",
  ["#lan__yongzu-choice"] = "拥族：选择执行的一项",
  ["maxcards2"] = "手牌上限+2",
  ["get_jianxiong"] = "获得〖奸雄〗",
  ["get_tianming"] = "获得〖天命〗",

  ["$lan__yongzu1"] = "既拜我为父，咱家当视汝为骨肉。",
  ["$lan__yongzu2"] = "天地君亲师，此五者最须尊崇。",
}

local function DoYongzu(player, choices, all_choices)
  local room = player.room
  local choice = room:askToChoice(player, {
    choices = choices,
    skill_name = yongzu.name,
    prompt = "#lan__yongzu-choice",
    all_choices = all_choices,
  })
  if choice == "draw2" then
    player:drawCards(2, yongzu.name)
  elseif choice == "recover" then
    room:recover{
      who = player,
      num = 1,
      recoverBy = player,
      skillName = yongzu.name,
    }
  elseif choice == "reset" then
    player:reset()
  elseif choice == "maxcards2" then
    room:addPlayerMark(player, MarkEnum.AddMaxCards, 2)
  elseif choice == "get_jianxiong" then
    if not player:hasSkill("lan__jianxiong", true) then
      room:handleAddLoseSkills(player, "lan__jianxiong")
    end
  else
    if not player:hasSkill("tianming", true) then
      room:handleAddLoseSkills(player, "tianming")
    end
  end
  return choice
end

yongzu:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yongzu.name) and player.phase == Player.Start and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      skill_name = yongzu.name,
      prompt = "#lan__yongzu-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local all_choices = {"draw2", "recover", "reset", "maxcards2", "get_jianxiong", "get_tianming"}
    local choices = table.simpleClone(all_choices)
    if not player:isWounded() then
      table.remove(choices, 2)
    end
    local choice = DoYongzu(player, choices, all_choices)
    if to.dead then return end
    if choices[2] ~= "recover" and to:isWounded() then
      table.insert(choices, 2, "recover")
    end
    table.removeOne(choices, choice)
    DoYongzu(to, choices, all_choices)
  end,
})

return yongzu

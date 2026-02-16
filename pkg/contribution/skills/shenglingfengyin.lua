local fengyin = fk.CreateSkill{
  name = "yyfy_shenglingfengyin",
  tags = { Skill.Permanent, Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["yyfy_shenglingfengyin"] = "圣灵封印",
  [":yyfy_shenglingfengyin"] = "永恒技，锁定技，共鸣技，游戏开始时，你获得七张“圣灵谱尼”武将牌并选择一张出场。"
  .."你死亡时，若存在未出场的武将，则选择一个武将出场并继承此前所有技能。",

  ["@&yyfy_shengling"] = "圣灵",
}

fengyin:addLoseEffect(function(self, player, is_death)
  player.room:handleAddLoseSkills(player, self.name, nil, false, true)
end)

fengyin:addEffect(fk.GameStart, {
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return player and player:hasSkill(self) and
    (player.general == "yyfy_shenglingpuni" or player.deputyGeneral == "yyfy_shenglingpuni")
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "yyfy_puni", 1)
  end,
})

fengyin:addEffect(fk.GameStart, {
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self) and
    (player.general == "yyfy_shenglingpuni" or player.deputyGeneral == "yyfy_shenglingpuni")
  end,
  on_trigger = function (self, event, target, player, data)
    local room = player.room
    local i = 0
    local generals = {}
    while i < 7 do
      table.insert(generals, "yyfy_shenglingpuni")
      i = i + 1
    end
    room:setPlayerMark(player, "@&yyfy_shengling", generals)
    local choice = room:askToChooseGeneral(player, {
      generals = generals,
      n = 1,
      no_convert = true,
      skill_name = fengyin.name,
      prompt = "圣灵封印：请选择一张武将牌出战",
    })
    if not choice then choice = "yyfy_shenglingpuni" end
    table.removeOne(generals, choice)
    room:setPlayerMark(player, "@&yyfy_shengling", generals)
  end
})

fengyin:addEffect(fk.BeforeGameOverJudge, {
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self, true, true) and player:getMark("yyfy_puni") > 0
    and #player:getTableMark("@&yyfy_shengling") > 0
    and target == player
  end,
  on_trigger = function (self, event, target, player, data)
    local room = player.room
    room:setTag("SkipGameRule", true)
    room:revivePlayer(player, false)
    local generals = player:getTableMark("@&yyfy_shengling")
    local choice = room:askToChooseGeneral(player, {
      generals = generals,
      n = 1,
      no_convert = true,
      skill_name = fengyin.name,
      prompt = "圣灵封印：请选择一张武将牌出战",
    })
    table.removeOne(generals, choice)
    local skills = player.player_skills
    local isDeputy = false
    if player.deputyGeneral == "yyfy_shenglingpuni" then
      isDeputy = true
    end
    room:changeHero(player, "yyfy_shenglingpuni", true, isDeputy)
    room:setPlayerMark(player, "@&yyfy_shengling", generals)
    -- 继承所有技能
    for _, skill in ipairs(skills) do
      if not player:hasSkill(skill, true, true) then
        room:handleAddLoseSkills(player, skill.name, fengyin.name)
      end
    end
    if #player:getTableMark("@&yyfy_shengling") > 0 then
      local logic = player.room.logic
      local e = logic:getCurrentEvent()
      logic:breakEvent(e)
    end
    
  end
})

return fengyin
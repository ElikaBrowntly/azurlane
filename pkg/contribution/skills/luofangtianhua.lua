local luofangtianhua = fk.CreateSkill{
  name = "yyfy_luofangtianhua",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["yyfy_luofangtianhua"] = "落芳天华",
  [":yyfy_luofangtianhua"] = "永恒技，游戏/每轮/回合开始时，你可以令任意名角色获得技能"..
  "〖<a href = ':yyfy_fusu'>复苏</a>〗。"
}

luofangtianhua:addLoseEffect(function(self, player, is_death)
  player.room:handleAddLoseSkills(player, self.name, nil, false, true)
end)

---@param player ServerPlayer
local function getFusu(player)
  local room = player.room
  local targets = {}
  for _, p in ipairs(room:getAlivePlayers()) do
    if not p:hasSkill("yyfy_fusu", true) then
      table.insert(targets, p)
    end
  end
  local choices = room:askToChoosePlayers(player, {
    targets = targets,
    min_num = 0,
    max_num = #targets,
    skill_name = luofangtianhua.name,
    prompt = "落芳天华：请令任意名角色获得〖复苏〗"
  })
  for _, p in ipairs(choices) do
    room:handleAddLoseSkills(p, "yyfy_fusu", luofangtianhua.name)
  end
end

luofangtianhua:addEffect(fk.GameStart, {
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self)
  end,
  on_trigger = function (self, event, target, player, data)
    getFusu(player)
  end
})

luofangtianhua:addEffect(fk.RoundStart, {
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self)
  end,
  on_trigger = function (self, event, target, player, data)
    getFusu(player)
  end
})

luofangtianhua:addEffect(fk.TurnStart, {
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self) and target == player
  end,
  on_trigger = function (self, event, target, player, data)
    getFusu(player)
  end
})

return luofangtianhua
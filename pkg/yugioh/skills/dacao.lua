local dacao = fk.CreateSkill {
  name = "yyfy_dacao",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable {
  ["yyfy_dacao"] = "打草",
  [":yyfy_dacao"] = "持恒技，你受到其他角色的伤害后，可以变更为任意武将并保留当前技能。" ..
    "累计使用3次后，你失去此技能。",

  ["@yyfy_dacao"] = "打草"
}

dacao:addEffect(fk.Damaged, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self, true) and data.from and data.from ~= player
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = dacao.name,
      prompt = "打草：是否要变更为任意武将，并保留当前技能？"
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, s in ipairs(player.player_skills) do
      if s:isPlayerSkill(player) then
        room:addTableMark(player, "yyfy_dacao-inherit", s.name)
      end
    end
    local generalNames = {}
    for _, g in ipairs(Fk:getAllGenerals()) do
      table.insertIfNeed(generalNames, g.name)
    end
    for _, g in ipairs(Fk:currentRoom().disabled_generals) do
      table.insertIfNeed(generalNames, g)
    end
    for _, pack in ipairs(Fk:currentRoom().disabled_packs) do
      for _, g in ipairs(Fk.packages[pack].generals) do
        table.insertIfNeed(generalNames, g.name)
      end
    end
    if #generalNames == 0 then return end
    local req = Request:new(player, "CustomDialog")
    req:setData(player, {
      path = "packages/hidden-clouds/qml/GeneralChoice.qml",
      data = {
        generals = generalNames,
        freeAssign = true
      },
    })
    req:setDefaultReply(player, "")
    local choice = req:getResult(player)
    local isDeputy = false
    if player.deputyGeneral == "yyfy_dacaoreshe" then
      isDeputy = true
    end
    room:changeHero(player, choice, true, isDeputy)
    local remove = {}
    for _, s in ipairs(player:getTableMark("yyfy_dacao-inherit")) do
      if not player:hasSkill(self, true, true) then
        room:handleAddLoseSkills(player, s, dacao.name)
      end
      table.insertIfNeed(remove, s)
    end
    for _, s in ipairs(remove) do
      room:removeTableMark(player, "yyfy_dacao-inherit", s)
    end
    room:addPlayerMark(player, "@yyfy_dacao", 1)
    if player:getMark("@yyfy_dacao") >= 3 then
      room:handleAddLoseSkills(player, "-" .. dacao.name, dacao.name)
    end
  end
})

return dacao

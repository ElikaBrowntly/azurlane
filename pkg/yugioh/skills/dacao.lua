local dacao = fk.CreateSkill {
  name = "yyfy_dacao",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable {
  ["yyfy_dacao"] = "打草",
  [":yyfy_dacao"] = "持恒技，你受到其他角色的伤害后，可以变更为全扩任意武将并保留当前技能。" ..
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
    -- 保存当前技能以便继承
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
      for _, g in ipairs((Fk.packages[pack] or {}).generals or {}) do
        table.insertIfNeed(generalNames, g.name)
      end
    end

    if #generalNames == 0 then return end

    local choice
    if room:getSettings('enableFreeAssign') then
      local sum = #generalNames
      local randomNames = {}
      if #generalNames > 16 then
        while #randomNames < 16 do
          local index = math.random(sum)
          local one = table.remove(generalNames, index)
          table.insertIfNeed(randomNames, one)
        end
      else
        randomNames = generalNames
      end
      choice = room:askToChooseGeneral(player, {
        generals = randomNames,
      })
    else
      -- 如果武将数量太多（>100），先让玩家输入搜索词过滤
      local finalGenerals = generalNames
      if #generalNames > 100 then
        local inputReq = Request:new(player, "CustomDialog")
        inputReq:setData(player, {
          path = "packages/hidden-clouds/qml/InputSearch.qml",
          data = {
            num = #generalNames
          },
        })
        inputReq:setDefaultReply(player, "")
        local input = inputReq:getResult(player)
        if input == nil or input == "" then
          return -- 取消或未输入，结束技能
        end
        local keyword = input:lower()
        local filtered = {}
        for _, gen in ipairs(generalNames) do
          local translated = Fk:translate(gen):lower()
          if translated:find(keyword, 1, true) then
            table.insert(filtered, gen)
          end
        end
        if #filtered == 0 then
          room:doBroadcastNotify("ShowToast", "打草惹蛇：没有符合宣言的武将")
          return
        end
        finalGenerals = filtered
      end

      -- 弹出武将选择对话框
      local req = Request:new(player, "CustomDialog")
      req:setData(player, {
        path = "packages/hidden-clouds/qml/GeneralChoice.qml",
        data = {
          generals = finalGenerals,
          freeAssign = true
        },
      })
      req:setDefaultReply(player, "")
      choice = req:getResult(player)
      if choice == nil or choice == "" then
        return -- 取消选择
      end
    end
    -- 换将
    local isDeputy = false
    if player.deputyGeneral == "yyfy_dacaoreshe" then
      isDeputy = true
    end
    if type(choice) == "table" then
      choice = choice[1]
    end
    room:changeHero(player, choice, true, isDeputy)

    -- 继承之前保存的技能
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

    -- 记录使用次数
    room:addPlayerMark(player, "@yyfy_dacao", 1)
    if player:getMark("@yyfy_dacao") >= 3 then
      room:handleAddLoseSkills(player, "-" .. dacao.name, dacao.name)
    end
  end
})

return dacao
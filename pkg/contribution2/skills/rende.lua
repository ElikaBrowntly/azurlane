local rende = fk.CreateSkill {
  name = "yyfy_rende",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable {
  ["yyfy_rende"] = "仁德",
  [":yyfy_rende"] = "持恒技，出牌阶段，你可以：<br>①交给一名其他角色任意个技能，并获得等量个“仁德”标记；<br>" ..
      "②消耗2个“仁德”标记，增加一点体力上限。<br>出牌阶段，或当你濒死时，你可以消耗任意个“仁德”标记回复等量体力。",

  ["#yyfy_rende"] = "仁德：请选择要执行的效果",
  ["@yyfy_rende"] = "仁德",

  ["$yyfy_rende1"] = "仁德为政，自得民心！",
  ["$yyfy_rende2"] = "民心所望，乃吾政所向！",
}

rende:addEffect("active", {
  anim_type = "support",
  prompt = "#yyfy_rende",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player and player:hasSkill(self)
  end,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  interaction = function(self, player)
    local all = {
      "交出技能，获得等量“仁德”标记",
      "消耗2个“仁德”标记增加体力上限",
      "消耗“仁德”标记，回复等量体力"
    }
    local choices = { "交出技能，获得等量“仁德”标记" }
    if player:getMark("@yyfy_rende") > 0 and player:isWounded() then
      table.insert(choices, "消耗“仁德”标记，回复等量体力")
    end
    if player:getMark("@yyfy_rende") > 1 then
      table.insert(choices, 2, "消耗2个“仁德”标记增加体力上限")
    end
    return UI.ComboBox {
      choices = choices,
      all_choices = all
    }
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local choice = self.interaction.data
    if choice == "交出技能，获得等量“仁德”标记" then
      local to = room:askToChoosePlayers(player, {
        targets = room:getOtherPlayers(player),
        min_num = 1,
        max_num = 1,
        skill_name = rende.name,
        prompt = "仁德：请选择要获得技能的角色"
      })
      if not to or #to ~= 1 then return end
      to = to[1]
      local skills = {}
      for _, s in ipairs(player.player_skills) do
        if not (s.attached_equip or s.name[#s.name] == "&") and not string.find(s.name, "#") then
          table.insertIfNeed(skills, s.name)
        end
      end
      skills = room:askToCustomDialog(player, {
        skill_name = rende.name,
        component = {
          url = "packages/utility/qml/ChooseSkillBox.qml",
          model = {
            url = "packages/utility/qml/models/ChooseSkillModel.qml",
            prop = {
              skills = skills,
              min = 1,
              max = #skills,
              prompt = "仁德：请选择要给出的技能",
              cancelable = false,
            }
          }
        },
      })
      if not skills or #skills == 0 then return end
      room:handleAddLoseSkills(to, skills, rende.name)
      for _, s in ipairs(skills) do
        room:handleAddLoseSkills(player, "-"..s)
      end
      room:addPlayerMark(player, "@yyfy_rende", #skills)
    elseif choice == "消耗2个“仁德”标记增加体力上限" then
      room:removePlayerMark(player, "@yyfy_rende", 2)
      room:changeMaxHp(player, 1)
    elseif player:getMark("@yyfy_rende") > 0 then
      local n = room:askToNumber(player, {
        min = 1,
        max = player:getMark("@yyfy_rende"),
        skill_name = rende.name,
        prompt = "仁德：请选择要消耗的标记数"
      })
      if not n or n <= 0 then return end
      room:removePlayerMark(player, "@yyfy_rende", n)
      room:recover({
        who = player,
        num = n,
        recoverBy = player,
        skillName = rende.name
      })
    end
  end,
})

rende:addEffect(fk.EnterDying, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:getMark("@yyfy_rende") > 0
  end,
  on_cost = function(self, event, target, player, data)
    local n = player.room:askToNumber(player, {
      min = 1,
      max = player:getMark("@yyfy_rende"),
      prompt = "仁德：你可以消耗任意个标记，回复等量体力",
      skill_name = rende.name
    })
    if not n or n < 1 then return false end
    event:setCostData(self, { n = n })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = (event:getCostData(self) or {}).n or 0
    room:removePlayerMark(player, "@yyfy_rende", n)
    room:recover({
      who = player,
      num = n,
      recoverBy = player,
      skillName = rende.name
    })
  end
})

return rende
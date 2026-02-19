local guangrongzhimeng = fk.CreateSkill{
  name = "yyfy_guangrongzhimeng",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["yyfy_guangrongzhimeng"] = "光荣之梦",
  [":yyfy_guangrongzhimeng"] = "永恒技，当你出场时，你可以选择执行任意项："..
  "1.一名角色获得你武将牌上的一个技能；2.你获得其他角色武将牌上的一个技能。当你死亡时，你可以令一名角色死亡。"
}

local all_generals = {"yyfy_shenglingpuni"}
local j = 1
while j <= 7 do
  table.insert(all_generals, "yyfy_shenglingpuni"..tostring(j))
  j = j + 1
end

guangrongzhimeng:addLoseEffect(function(self, player, is_death)
  player.room:handleAddLoseSkills(player, self.name, nil, false, true)
end)

guangrongzhimeng:addEffect(fk.AfterPropertyChange, {
  anim_type = "support",
  priority = 2,
  can_trigger = function (self, event, target, player, data)
    if player and target == player and player:hasSkill(self, true, true)
    and (table.contains(all_generals, data.general) or
    data.deputyGeneral and table.contains(all_generals, data.deputyGeneral)) then
      local choices = player.room:askToChoices(player, {
        choices = {"其他角色获得你一个技能", "你获得其他角色一个技能"},
        min_num = 0,
        max_num = 2,
        cancelable = true,
        prompt = "光荣之梦：请选择任意项执行",
        skill_name = guangrongzhimeng.name
      })
      if choices ~= {} then
        event:setCostData(self, {choices = choices})
        return true
      end
    end
  end,
  on_trigger = function (self, event, target, player, data)
    local room = player.room
    local choices = event:getCostData(self).choices ---@type string[]
    if table.contains(choices, "其他角色获得你一个技能") then
      local skills = player.player_skills
      local names = {}
      for _, skill in ipairs(skills) do
        table.insert(names, skill.name)
      end
      local to = room:askToChoosePlayers(player, {
        targets = room:getAlivePlayers(),
        min_num = 1,
        max_num = 1,
        skill_name = guangrongzhimeng.name,
        prompt = "光荣之梦：要让谁获得你的技能？",
        cancelable = false
      })
      if #to ~= 0 and #names ~= 0 then
        local choice = room:askToChoice(to[1], {
          choices = names,
          skill_name = guangrongzhimeng.name,
          prompt = "光荣之梦：请获得“圣灵谱尼”的一个技能",
          cancelable = false
        })
        room:handleAddLoseSkills(to[1], choice, guangrongzhimeng.name)
      end
    end
    if table.contains(choices, "你获得其他角色一个技能") then
      local to = room:askToChoosePlayers(player, {
        targets = room:getAlivePlayers(),
        min_num = 1,
        max_num = 1,
        skill_name = guangrongzhimeng.name,
        prompt = "光荣之梦：要获得谁的技能？",
        cancelable = false
      })
      if #to ~= 1 then return end
      local skills = to[1].player_skills
      if #skills == 0 then return end
      local names = {}
      for _, skill in ipairs(skills) do
        table.insert(names, skill.name)
      end
      local choice = room:askToChoice(player, {
        choices = names,
        skill_name = guangrongzhimeng.name,
        prompt = "光荣之梦：请选择一个技能获得",
        cancelable = false
      })
      room:handleAddLoseSkills(player, choice, guangrongzhimeng.name)
    end
  end
})

guangrongzhimeng:addEffect(fk.Death, {
  anim_type = "masochism",
  can_trigger = function (self, event, target, player, data)
    if not (data.who == player and player:hasSkill(self, true, true)) then return false end
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      targets = room:getAlivePlayers(),
      min_num = 0,
      max_num = 1,
      skill_name = guangrongzhimeng.name,
      prompt = "光荣之梦：请令一名角色死亡",
      cancelable = true
    })
    if #tos ~= 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_trigger = function (self, event, target, player, data)
    player.room:killPlayer({
      who = event:getCostData(self).tos[1],
      killer = player
    })
  end
})

return guangrongzhimeng
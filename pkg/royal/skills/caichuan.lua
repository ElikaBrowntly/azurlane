-- 柴郡【偷图】的【彩船】子技能
local yyfy_toutu_caichuan = fk.CreateSkill{
  name = "yyfy_caichuan",
  anim_type = "support",
  card_num = 0,
  target_num = 0,
  max_phase_use_time = 1,
}

Fk:loadTranslationTable{
  ["yyfy_caichuan"] = "彩船",
  [":yyfy_caichuan"] = "从X个萌武将中选择一个获得",
  ["#yyfy_toutu_caichuan-choose"] = "请选择一个萌势力武将",
  ["@&yyfy_toutu_caichuan"] = "船坞",
}

yyfy_toutu_caichuan:addEffect("active",{
  max_phase_use_time = 1,
  on_cost = function(self, player)
    return player:getMark("@yyfy_toutu_caichuan") > 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local X = player:getMark("@yyfy_toutu_caichuan")
    local numGenerals = X + 1
    
    -- 获取萌势力武将列表
    local mengGenerals = table.filter(Fk:getAllGenerals(), function(g)
      return g.kingdom == "moe"
    end)
    
    if #mengGenerals == 0 then
      room:sendLog{ type = "#没有可选的萌势力武将", from = player.id }
      return
    end
    
    -- 随机选择 X+1 个武将
    local selectedGenerals = table.random(mengGenerals, math.min(numGenerals, #mengGenerals))
    local generalNames = {}
    for _, g in ipairs(selectedGenerals) do
      table.insert(generalNames, g.name)
    end
    
    -- 让玩家选择一个
    local choice = room:askToChooseGeneral(player, {
      generals = generalNames,
      n = 1,
      no_convert = true,
      skill_name = "yyfy_caichuan",
      prompt = "#yyfy_toutu_caichuan-choose",
    })
    
    if not choice then return end
    
    -- 获得该武将的所有技能
    local general = Fk.generals[choice]
    local skills = {}
    for _, skill in ipairs(general:getSkillNameList()) do
      table.insertIfNeed(skills, skill)
    end
    
    if #skills > 0 then
      room:handleAddLoseSkills(player, table.concat(skills, "|"))
    end
    
    -- 添加到私人武将牌堆
    local caichuanGenerals = player:getTableMark("@&yyfy_toutu_caichuan") or {}
    table.insert(caichuanGenerals, choice)
    room:setPlayerMark(player, "@&yyfy_toutu_caichuan", caichuanGenerals)
  end,
})

return yyfy_toutu_caichuan
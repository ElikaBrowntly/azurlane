-- 柴郡【偷图】的【彩船】子技能
local yyfy_toutu_caichuan = fk.CreateSkill{
  name = "yyfy_caichuan",
  anim_type = "support",
  prompt = "#yyfy_caichuan",
  card_num = 0,
  target_num = 0,
  max_phase_use_time = 1,
}

Fk:loadTranslationTable{
  ["yyfy_caichuan"] = "彩船",
  [":yyfy_caichuan"] = "出牌阶段限一次，你可从X+2个武将中选择X个，获得其武将牌上全部技能（X为彩船图纸数量）",
  ["#yyfy_caichuan"] = "彩船：请选择%arg个武将",
  ["#yyfy_toutu_caichuan-choose"] = "彩船：请选择%arg个武将",
  ["@&yyfy_toutu_caichuan"] = "船坞",
}

yyfy_toutu_caichuan:addEffect("active",{
  can_use = function(self, player)
    return player:getMark("@yyfy_toutu_caichuan") > 0 and
           player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local X = player:getMark("@yyfy_toutu_caichuan")
    
    -- 如果X为0，则不执行
    if X <= 0 then return end
    
    -- 获取所有可用武将（排除已登场武将）
    local existingGenerals = {}
    for _, p in ipairs(room.players) do
      table.insert(existingGenerals, p.general)
      if p.deputyGeneral ~= "" then
        table.insert(existingGenerals, p.deputyGeneral)
      end
    end
    
    local allGenerals = Fk:getAllGenerals()
    local availableGenerals = table.filter(allGenerals, function(g)
      return not table.contains(existingGenerals, g.name)
    end)
    
    if #availableGenerals == 0 then
      room:sendLog{ type = "#没有可选的武将", from = player.id }
      return
    end
    
    -- 随机选择 X+2 个武将
    local numToSelect = math.min(X + 2, #availableGenerals)
    local selectedGenerals = table.random(availableGenerals, numToSelect)
    local generalNames = {}
    for _, g in ipairs(selectedGenerals) do
      table.insert(generalNames, g.name)
    end
    
    -- 让玩家选择X个武将
    local choices = room:askToChooseGeneral(player, {
      generals = generalNames,
      n = X,  -- 选择X个
      no_convert = true,
      skill_name = "yyfy_caichuan",
      prompt = "#yyfy_toutu_caichuan-choose:::"..X,
    })
    
    if not choices or #choices == 0 then return end
    
    -- 获取所有选择的武将的技能
    local allSkills = {}
    if type(choices) == "string" then
      choices = {choices}
    end
    for _, generalName in ipairs(choices) do
      local general = Fk.generals[generalName]
      for _, skill in ipairs(general:getSkillNameList()) do
        table.insertIfNeed(allSkills, skill)
      end
      
      -- 添加到私人武将牌堆
      local caichuanGenerals = player:getTableMark("@&yyfy_toutu_caichuan") or {}
      table.insert(caichuanGenerals, generalName)
      room:setPlayerMark(player, "@&yyfy_toutu_caichuan", caichuanGenerals)
    end
    
    -- 获得所有技能
    if #allSkills > 0 then
      room:handleAddLoseSkills(player, table.concat(allSkills, "|"))
    end
  end,
})

return yyfy_toutu_caichuan
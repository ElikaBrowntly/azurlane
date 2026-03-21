local yyfy_shicao = fk.CreateSkill{
  name = "yyfy_shicao",
  anim_type = "drawcard",
}

local F = require("packages.hidden-clouds.functions")

Fk:loadTranslationTable{
  ["yyfy_shicao"] = "识草",
  [":yyfy_shicao"] = "出牌阶段限一次，你可以从牌堆底摸2张牌；然后从牌堆顶摸牌直到获得了类型不同的牌",
  ["#yyfy_shicao"] = "识草：你可从牌堆底摸2张牌，然后从牌堆顶连续摸牌",

  ["$yyfy_shicao1"] = "此药名白术，形如栉草，可解热清毒。",
  ["$yyfy_shicao2"] = "长狼毒之处必生麻黄，其性燥，利发汗散寒。",
}

yyfy_shicao:addEffect("active", {
  prompt = "#yyfy_shicao",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player and player.phase == Player.Play and player:hasSkill(yyfy_shicao.name)
    and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    
    -- 牌堆底摸2，计入战功进度
    room:drawCards(player, 2, yyfy_shicao.name, "bottom")

    local save = player:getGlobalSaveState("hidden-clouds")
    local achieve = save["yyfy_shicao_achievement"] or {}
    local total = achieve.achieved_count or 0
    local update = false
    if total < 100 then
      update = true
      achieve.achieved_count = total + 2
    end
    
    -- 记录已出现类型
    local existingTypes = {}
    
    -- 循环
    while true do
      -- 牌堆为空
      if #room.draw_pile == 0 then break end
      
      local card = room:getNCards(1)[1]
      local cardType = Fk:getCardById(card).type
      
      room:obtainCard(player, card, false, fk.ReasonDraw)
      -- 计入战功进度
      total = achieve.achieved_count or 0
      if total < 100 then
        achieve.achieved_count = total + 1
      end
      
      local isNewType = false
      for _, t in ipairs(existingTypes) do
        if t ~= cardType then
          isNewType = true
          break
        end
      end
      
      if isNewType then
        break
      else
        table.insert(existingTypes, cardType)
      end
    end
    if update then
      save["yyfy_shicao_achievement"] = achieve
      player:saveGlobalState("hidden-clouds", save)
    end
  end,
})

--战功：遍尝百草
yyfy_shicao:addEffect(fk.GameFinished, {
  priority = 0.0001,
  can_refresh = function(self, event, target, player, data)
    local temp = player:getGlobalSaveState("hidden-clouds")
    local tempAchieve = temp["yyfy_shicao_achievement"] or {}
    local save = player:getGlobalSaveState("glory_days_Achieve")
    local saveAchieve = save["遍尝百草"] or {}
    local count = tempAchieve.achieved_count
    return count and count >= 100 --hidden-clouds存档满100，向战功存档进一
  end,
  on_refresh = function(self, event, target, player, data)
    F.addAchievement(player.room, nil, nil, nil, "遍尝百草", nil, nil, {player}, false, "夜隐浮云")
    local temp = player:getGlobalSaveState("hidden-clouds")
    temp["yyfy_shicao_achievement"] = nil -- 清空hidden-clouds的识草存档
    player:saveGlobalState("hidden-clouds", temp)
  end
})

return yyfy_shicao
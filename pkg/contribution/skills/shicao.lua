local yyfy_shicao = fk.CreateSkill{
  name = "yyfy_shicao",
  anim_type = "drawcard",
}

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
  max_phase_use_time = 1,
  on_cost = function(self, player)
    return player.phase == Player.Play and player:hasSkill(yyfy_shicao.name)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    
    -- 牌堆底摸2
    room:drawCards(player, 2, yyfy_shicao.name, "bottom")
    
    -- 记录已出现类型
    local existingTypes = {}
    
    -- 循环
    while true do
      -- 牌堆为空
      if #room.draw_pile == 0 then break end
      
      local card = room:getNCards(1)[1]
      local cardType = Fk:getCardById(card).type
      
      room:obtainCard(player, card, false, fk.ReasonDraw)
      
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
  end,
})

return yyfy_shicao
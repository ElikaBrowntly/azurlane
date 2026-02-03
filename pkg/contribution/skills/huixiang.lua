local huixiang = fk.CreateSkill{
  name = "yyfy_huixiang",
}

Fk:loadTranslationTable{
  ["yyfy_huixiang"] = "回响",
  [":yyfy_huixiang"] = "出牌阶段限一次，你可以选择任意名角色，将各自武将牌上的所有「尖叫」牌分别对其使用（无距离和次数限制）",
  ["#yyfy_huixiang-choose"] = "回响：请选择目标角色",
  ["#yyfy_huixiang-use"] = "回响：%from 对 %to 使用了 %arg",
}
huixiang:addEffect("active", {
  prompt = "#yyfy_huixiang-choose",
  card_num = 0,
  max_phase_use_time = 1,
  target_filter = function(self, to_select, selected)
    return to_select:isAlive()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local targets = effect.tos
    
    for _, target in ipairs(targets) do
      -- 获取目标武将牌上的尖叫牌
      local jianjiaoCards = target:getPile("尖叫") or {}
      
      for _, cardId in ipairs(jianjiaoCards) do
        -- 对目标使用尖叫牌
        local card = Fk:getCardById(cardId)
        if card then
          room:useCard({
            from = player,
            tos = {target},
            card = card,
            skillName = huixiang.name,
            extra_data = {
            bypass_distances = true,
            bypass_times = true,
            }
          })
          room:setCardMark(card, "@@jianjiao_cards", 0)
        end
      end
    end
  end,
})

return huixiang
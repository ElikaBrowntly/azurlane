local woyeyaogeima = fk.CreateSkill {
  name = "yyfy_woyeyaogeima",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable {
  ["yyfy_woyeyaogeima"] = "我也要给吗",
  [":yyfy_woyeyaogeima"] = "每阶段限一次，一名角色不因此技能而获得手牌后，你可以令其获得牌堆顶的牌直到点数总和＞149.38。",

  ["#yyfy_woyeyaogeima-invoke"] = "我也要给吗：是否要令%dest获得牌堆顶的牌,直到点数＞149.38"
}

woyeyaogeima:addEffect(fk.AfterCardsMove, {
  can_trigger = function (self, event, target, player, data)
    if player:usedSkillTimes(woyeyaogeima.name, Player.HistoryPhase) > 0 then return false end
    for _, move in ipairs(data) do
      if move.to and move.toArea == Player.Hand and move.skillName ~= woyeyaogeima.name
      and player and player:hasSkill(self) then
        event:setCostData(self, {tos = {move.to}})
        return true
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = woyeyaogeima.name,
      prompt = "#yyfy_woyeyaogeima-invoke::"..event:getCostData(self).tos[1].id
    })
  end,
  on_use = function (self, event, target, player, data)
    local sum = 0
    local to = event:getCostData(self).tos[1]
    while sum < 149.38 do
      if #player.room.draw_pile == 0 then break end
      local card = player.room.draw_pile[1]
      sum = sum + Fk:getCardById(card).number
      player.room:obtainCard(to, card, false, fk.ReasonPrey, player, woyeyaogeima.name)
    end
  end
})

return woyeyaogeima
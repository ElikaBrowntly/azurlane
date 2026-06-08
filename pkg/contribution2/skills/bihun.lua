local bihun = fk.CreateSkill{
  name = "yyfy_bihun",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["yyfy_bihun"] = "弼昏",
  [":yyfy_bihun"] = "锁定技，当你使用牌指定其他角色为目标时，若你的手牌数大于手牌上限，结算后你令唯一目标获得之。",

  ["$yyfy_bihun1"] = "辅弼天家，以扶朝纲。",
  ["$yyfy_bihun2"] = "为国治政，尽忠匡辅。",
}

bihun:addEffect(fk.TargetSpecifying, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(bihun.name) and not data.cancelled and
      player:getHandcardNum() > player:getMaxCards() and data.to ~= player
  end,
  on_use = function(self, event, target, player, data)
    if data.to:isAlive() and data.firstTarget and data:isOnlyTarget(data.to) then
      player.room:addCardMark(data.card, bihun.name)
    end
  end,
})

bihun:addEffect(fk.CardUseFinished, {
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(bihun.name) and data.card:getMark(bihun.name) > 0
    and data.tos[1] ~= player and player.room:getCardArea(data.card) == Card.Processing
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if data.tos[1].dead then return end
    room:obtainCard(data.tos[1], data.card, true, fk.ReasonJustMove, player, bihun.name)
  end
})

return bihun
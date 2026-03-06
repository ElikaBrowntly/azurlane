local ciallo = fk.CreateSkill {
  name = "yyfy_ciallo",
}

Fk:loadTranslationTable{
  ["yyfy_ciallo"] = "Ciallo",
  [":yyfy_ciallo"] = "回合开始时，你可以令任意名角色将体力值回复至体力上限。若体力值已满，则改为+1点体力上限。",
}

ciallo:addEffect(fk.TurnStart, {
  anim_type = "support",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      targets = room:getAlivePlayers(),
      min_num = 1,
      max_num = 999,
      skill_name = ciallo.name,
      prompt = "Ciallo：你可以令任意名角色将体力值回满或增加体力上限"
    })
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local tos = event:getCostData(self).tos
    if tos == nil or #tos == 0 then return end
    room:doBroadcastNotify("ShowToast", "Ciallo ～ (∠・ω< ) ⌒ ☆")
    for _, t in ipairs(tos) do
      if not t:isWounded() then
        room:changeMaxHp(t, 1)
      else
        room:recover({
          who = t,
          num = t.maxHp - t.hp,
          recoverBy = player,
          skillName = ciallo.name
        })
      end
    end
  end
})

return ciallo
local ziguadongnanzhi = fk.CreateSkill {
  name = "yyfy_ziguadongnanzhi",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable {
  ["yyfy_ziguadongnanzhi"] = "自挂东南枝",
  [":yyfy_ziguadongnanzhi"] = "持恒技，出牌阶段，你可以自缢。你死亡后，令一名其他角色自尽。",
}

ziguadongnanzhi:addEffect(fk.Deathed, {
  is_delay_effect = true,
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self, true, true)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local who = room:askToChoosePlayers(player, {
      targets = room:getAlivePlayers(false),
      min_num = 1,
      max_num = 1,
      skill_name = ziguadongnanzhi.name,
      prompt = "自挂东南枝：请令一名其他角色死亡",
      cancelable = false
    })
    if not who or #who ~= 1 then return end
    who = who[1]
    room:killPlayer({
      who = who,
      killer = who
    })
  end
})

ziguadongnanzhi:addEffect("active", {
  anim_type = "negative",
  can_use = function(self, player)
    return player and player:hasSkill(self, true)
  end,
  prompt = "是否要自挂东南枝？",
  target_num = 0,
  target_filter = Util.FalseFunc,
  card_num = 0,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    room:doBroadcastNotify("ShowToast", "<font color='red'>徘徊庭树下，自挂东南枝。</font>")
    room:killPlayer({
      who = player,
      killer = player
    })
  end
})

return ziguadongnanzhi
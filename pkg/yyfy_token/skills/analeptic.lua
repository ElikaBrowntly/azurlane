local analepticSkill = fk.CreateSkill {
  name = "yyfy_xs_analeptic_skill",
}

analepticSkill:addEffect("cardskill", {
  prompt = function(self, _, _, _, extra_data)
    return extra_data.analepticRecover and "#peach_skill" or "#analeptic_skill"
  end,
  max_turn_use_time = 1,
  mod_target_filter = Util.TrueFunc,
  can_use = function(self, player, card, extra_data)
    return Util.CanUseToSelf(self, player, card, extra_data) and
        (extra_data and (extra_data.bypass_times or
            extra_data.analepticRecover and table.find(player:getCardIds("e"), function(id)
              return Fk:getCardById(id).name == "yyfy_xs_dazhan"           --装备“大盏”才能濒死回血
            end)) or
          self:withinTimesLimit(player, Player.HistoryTurn, card, "analeptic", player))
  end,
  on_use = function(self, room, use)
    if use.extra_data and use.extra_data.analepticRecover then
      use.extraUse = true
    end
  end,
  on_effect = function(self, room, effect)
    local to = effect.to
    if not to.dead then
      room:changeMaxHp(to, 1)
      room:recover({
        who = to,
        num = 1,
        recoverBy = effect.from,
        card = effect.card,
      })
    end
    room:addPlayerMark(to, "@yyfy_xs_tianyi")
    to.drank = to.drank + 1 + ((effect.extra_data or {}).additionalDrank or 0)
    room:broadcastProperty(to, "drank")
  end,
})

-- analepticSkill:addEffect(fk.PreCardUse, {
--   can_refresh = function(self, event, target, player, data)
--     return target == player and data.card.trueName == "slash" and player.drank > 0
--   end,
--   on_refresh = function(self, event, target, player, data)
--     local room = player.room
--     -- 加伤？消耗天意？全局？
--     -- data.additionalDamage = (data.additionalDamage or 0) + player.drank
--     data.extra_data = data.extra_data or {}
--     data.extra_data.drankBuff = player.drank
--     player.drank = 0
--     room:broadcastProperty(player, "drank")
--   end,
-- })

analepticSkill:addEffect(fk.TurnEnd, {
  late_refresh = true,
  can_refresh = function(self, event, target, player, data)
    return player.drank > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.drank = 0
    player.room:broadcastProperty(player, "drank")
  end,
})

return analepticSkill
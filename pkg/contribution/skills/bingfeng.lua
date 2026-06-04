local bingfeng = fk.CreateSkill{
  name = "yyfy_bingfeng",
}

Fk:loadTranslationTable{
  ["yyfy_bingfeng"] = "冰封",
  [":yyfy_bingfeng"] = "当你对其他角色造成伤害时，你摸一张牌，若受伤角色体力值不大于你，你可令其不能使用或打出红色牌直到其回合结束",

  ["@@yyfy_bingfeng"] = "冰封",
  ["#yyfy_bingfeng"] = "冰封：你可以令%dest不能使用或打出红色牌直到其回合结束"
}

bingfeng:addEffect(fk.DamageCaused, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.to ~= player
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = data.to
    room:drawCards(player, 1, bingfeng.name)
    if player.dead or to.dead or to.hp > player.hp or to:getMark("@@yyfy_bingfeng") > 0 or
    not room:askToSkillInvoke(player, {
      skill_name = bingfeng.name,
      prompt = "#yyfy_bingfeng::"..to.id
    }) then return end
    room:addPlayerMark(to, "@@yyfy_bingfeng")
  end
})

bingfeng:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    return player:getMark("@@yyfy_bingfeng") > 0 and card.color == Card.Red
  end,
  prohibit_response = function(self, player, card)
    return player:getMark("@@yyfy_bingfeng") > 0 and card.color == Card.Red
  end,
})

bingfeng:addEffect(fk.TurnEnd, {
  can_refresh = function (self, event, target, player, data)
    return player and player:hasSkill(self) and target ~= player and target:getMark("@@yyfy_bingfeng") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(target, "@@yyfy_bingfeng", 0)
  end
})

return bingfeng
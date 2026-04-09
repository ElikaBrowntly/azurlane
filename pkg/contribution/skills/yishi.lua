local yishi = fk.CreateSkill{
  name = "yyfy_yishi",
  attached_skill_name = "yyfy_yishi&"
}

Fk:loadTranslationTable{
  ["yyfy_yishi"] = "义释",
  [":yyfy_yishi"] = "锁定技，其他角色在出牌阶段内限1次，其可选择1名其他角色，交给其1张牌，若其选择的"..
  "角色与你势力相同，则至多交出4张。其他角色每交给与你同势力的角色2张牌，你对其下次造成的伤害-1。",

  ["@yyfy_yishi"] = "义释"
}

yishi:addEffect(fk.DamageCaused, {
  anim_type = "negative",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.to:getMark("@yyfy_yishi") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    data:changeDamage(- data.to:getMark("@yyfy_yishi"))
    player.room:setPlayerMark(data.to, "@yyfy_yishi", 0)
  end
})

return yishi
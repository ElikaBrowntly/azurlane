local skill = fk.CreateSkill {
  name = "yyfy_leyuanji",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable {
  ["yyfy_leyuanji"] = "<font color='#19FF08'>乐园纪</font>",
  [":yyfy_leyuanji"] = "<font color='#19FF08'>持恒技，你的第三血条被击破后，你获得无敌贯通状态"
  .."直到你进行2个回合之后。你接下来受到的7次伤害减少20%。</font>",
  ["@yyfy_leyuanji"] = "乐园纪"
}

skill:addEffect(fk.AfterPlayerRevived, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
        (player.tag["@yyfy_xietiao_XibalbaORT"] or 0) == 3
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@yyfy_leyuanji", 7)
    room:addPlayerMark(player, "@!fate_wudiguantong", 2)
  end
})

skill:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:getMark("@yyfy_leyuanji") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data:changeDamage(-math.ceil(data.damage * 0.2))
    player.room:addPlayerMark(player, "@yyfy_leyuanji", -1)
  end
})

-- 无敌贯通
skill:addEffect(fk.DamageInflicted, {
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self.name)
    and data.from == player and player:getMark("@!fate_wudiguantong-turn") > 0
    or player:getMark("fate_wudiguantong") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:loseHp(data.to, data.damage, self.name)
    data:preventDamage()
  end
})

skill:addEffect(fk.TurnEnd, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:getMark("@!fate_wudiguantong") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:removePlayerMark(player, "@!fate_wudiguantong", 1)
  end
})

return skill
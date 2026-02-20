local buchen = fk.CreateSkill {
  name = "yyfy_buchen",
  tags = { Skill.Compulsory },
  anim_type = "defensive",
}

Fk:loadTranslationTable {
  ["yyfy_buchen"] = "不沉",
  [":yyfy_buchen"] = "锁定技，你受到伤害时，有25%概率防止之，若未防止则降为1点。你的体力值即将降至0以下时防止之，"..
  "然后：<br>若有〖雪风〗技能选择的角色存活，你回复1点体力并免疫所有伤害直到回合结束；"..
  "否则，你在接下来的6个回合内免疫所有伤害和体力流失，并在6回合后阵亡。",

  ["@yyfy_buchen"] = "不沉剩余",
  ["@@yyfy_buchen-turn"] = "不沉",
  ["$yyfy_buchen1"] = "哼，让你们见识雪风大人的真本事！",
  ["$yyfy_buchen2"] = "我可是雪风哒！"
}

buchen:addEffect(fk.DetermineDamageInflicted, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_trigger = function (self, event, target, player, data)
    if math.random() < 0.25 then
      data:preventDamage()
    else
      data.damage = 1
    end
  end
})

buchen:addEffect(fk.BeforeHpChanged, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.num < 0 and player.hp + data.num <= 0
  end,
  on_trigger = function (self, event, target, player, data)
    local room = player.room
    data.prevented = true
    data.preventDying = true
    local num = 0
    for _, p in ipairs(room:getAlivePlayers()) do
      if p:getMark("@@yyfy_xuefeng") > 0 then
        num = 1
        break
      end
    end
    if num > 0 then
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = buchen.name
      })
      room:setPlayerMark(player, "@@yyfy_buchen-turn", 1)
    else
      room:setPlayerMark(player, "@yyfy_buchen", 6)
    end
  end
})

buchen:addEffect(fk.DetermineDamageInflicted, {
  priority = 2,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and
    (player:getMark("@@yyfy_buchen-turn") > 0 or player:getMark("@yyfy_buchen") > 0)
  end,
  on_trigger = function (self, event, target, player, data)
    data:preventDamage()
  end
})

buchen:addEffect(fk.BeforeHpChanged, {
  priority = 2,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.num < 0
    and player:getMark("@yyfy_buchen") > 0
  end,
  on_trigger = function (self, event, target, player, data)
    data.prevented = true
    data.preventDying = true
  end
})

buchen:addEffect(fk.EventTurnChanging, {
  can_refresh = function (self, event, target, player, data)
    return player and player:hasSkill(self, true, true) and player:getMark("@yyfy_buchen") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@yyfy_buchen", -1)
    if player:getMark("@yyfy_buchen") == 0 then
      room:killPlayer({
        who = player
      })
    end
  end
})

return buchen
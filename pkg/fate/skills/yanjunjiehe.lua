local jiehe = fk.CreateSkill({
  name = "yyfy_yanjunjiehe",
  tags = { Skill.Permanent },
})

Fk:loadTranslationTable {
  ["yyfy_yanjunjiehe"] = "严峻结合",
  [":yyfy_yanjunjiehe"] = "持恒技，你使用【杀】指定目标后，有60%概率令目标每回合失去1点体力，20%概率令目标" ..
      "防御力-1，20%概率令目标回复体力值减半。各项效果均持续3回合，重复获得则刷新计时。",

  ["@yyfy_yanjunjiehe_loseHp"] = "流血剩余",
  ["@yyfy_yanjunjiehe_defense"] = "降防剩余",
  ["@yyfy_yanjunjiehe_recover"] = "抑制回血"
}

jiehe:addEffect(fk.TargetSpecified, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card and
        data.card.trueName == "slash" and #data.tos > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local r = math.random(5)
    local mark = r == 4 and "@yyfy_yanjunjiehe_defense" or r == 5 and "@yyfy_yanjunjiehe_recover"
        or "@yyfy_yanjunjiehe_loseHp"
    for _, p in ipairs(data.tos) do
      room:setPlayerMark(p, mark, 3)
    end
  end
})

jiehe:addEffect(fk.TurnEnd, {
  can_refresh = function(self, event, target, player, data)
    return player and player:hasSkill(self, true, true) and table.find(player.room:getAlivePlayers(), function(p)
      return p:getMark("@yyfy_yanjunjiehe_loseHp") > 0 or p:getMark("@yyfy_yanjunjiehe_defense") > 0
          or p:getMark("@yyfy_yanjunjiehe_recover") > 0
    end)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local tos = table.filter(room:getAlivePlayers(), function(p)
      return p:getMark("@yyfy_yanjunjiehe_loseHp") > 0 or p:getMark("@yyfy_yanjunjiehe_defense") > 0
          or p:getMark("@yyfy_yanjunjiehe_recover") > 0
    end)
    for _, p in ipairs(tos) do
      room:addPlayerMark(p, "@yyfy_yanjunjiehe_loseHp", -1)
      room:addPlayerMark(p, "@yyfy_yanjunjiehe_defense", -1)
      room:addPlayerMark(p, "@yyfy_yanjunjiehe_recover", -1)
    end
  end
})

jiehe:addEffect(fk.TurnEnd, {
  priority = 1.1,
  can_refresh = function(self, event, target, player, data)
    if not (player and player:hasSkill(self, true, true)) then return false end
    local tos = table.filter(player.room:getAlivePlayers(), function(p)
      return p:getMark("@yyfy_yanjunjiehe_loseHp") > 0
    end)
    if #tos > 0 then
      event:setCostData(self, { tos = tos })
      return true
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local tos = (event:getCostData(self) or {}).tos
    if not tos or #tos == 0 then return end
    for _, t in ipairs(tos) do
      player.room:loseHp(t, 1, jiehe.name, player)
    end
  end
})

jiehe:addEffect(fk.DamageInflicted, {
  can_refresh = function(self, event, target, player, data)
    return player and player:hasSkill(self, true, true) and target and target:getMark("@yyfy_yanjunjiehe_defense") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data:changeDamage(1)
  end
})

jiehe:addEffect(fk.PreHpRecover, {
  can_refresh = function(self, event, target, player, data)
    return player and player:hasSkill(self, true, true) and target and target:getMark("@yyfy_yanjunjiehe_recover") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data:changeRecover(-math.ceil(data.num / 2))
  end
})

return jiehe
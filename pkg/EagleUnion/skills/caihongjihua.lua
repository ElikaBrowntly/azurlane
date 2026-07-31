local skill = fk.CreateSkill{
  name = "yyfy_caihongjihua",
  tags = { Skill.Compulsory }
}

Fk:loadTranslationTable {
  ["yyfy_caihongjihua"] = "彩虹计划",
  [":yyfy_caihongjihua"] = "锁定技，当你受到1点伤害后，你摸1张牌，然后对一名角色造成1点伤害。每当你造成"..
  "或受到伤害时，你进行判定并获得判定牌，若结果为<font color='red'>♥</font>，你防止本回合受到的伤害和体力流失。",

  ["@@yyfy_caihongjihua-turn"] = "彩虹计划",
  ["$yyfy_caihongjihua1"] = "……指挥官，举高高！",
  ["$yyfy_caihongjihua2"] = "雷霆……！"
}

skill:addEffect(fk.Damaged, {
  anim_type = "masochism",
  trigger_times = function (self, event, target, player, data)
    return data.damage
  end,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:drawCards(1, skill.name)
    local to = room:askToChoosePlayers(player, {
      targets = room:getAlivePlayers(false),
      min_num = 1,
      max_num = 1,
      cancelable = false,
      skill_name = skill.name,
      prompt = "彩虹计划：请对一名角色造成1点伤害"
    })
    if not to or #to ~= 1 then return end
    to = to[1]
    room:damage({
      from = player,
      to = to,
      skillName = skill.name,
      damage = 1
    })
  end
})

local spec = {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      pattern = ".|.|heart",
      reason = skill.name,
      skipDrop = true
    }
    room:judge(judge)
    local card = judge.card or {}
    if (card.area or 0) == Card.Processing then
      room:obtainCard(player, card, true, fk.ReasonJustMove, player, skill.name)
    end
    if not judge:matchPattern() then return end
    room:setPlayerMark(player, "@@yyfy_caihongjihua-turn", 1)
  end
}

skill:addEffect(fk.DamageCaused, spec)

skill:addEffect(fk.DetermineDamageInflicted, spec)

skill:addEffect(fk.DetermineDamageInflicted, {
  priority = 2,
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:getMark("@@yyfy_caihongjihua-turn") > 0
  end,
  on_use = function (self, event, target, player, data)
    data:preventDamage()
  end
})

skill:addEffect(fk.PreHpLost, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:getMark("@@yyfy_caihongjihua-turn") > 0
  end,
  on_use = function (self, event, target, player, data)
    data:preventHpLost()
  end
})

return skill
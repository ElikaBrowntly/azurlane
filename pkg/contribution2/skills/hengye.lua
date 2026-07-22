local hengye = fk.CreateSkill {
  name = "yyfy_hengye",
  tags = { Skill.Compulsory }
}

Fk:loadTranslationTable {
  ["yyfy_hengye"] = "横野",
  [":yyfy_hengye"] = "锁定技，你造成1点伤害后，本局游戏以下数值+1（至多增加体力上限值）：<br>" ..
      "①摸牌时摸牌数；<br>②出牌阶段使用【杀】的次数；<br>③攻击范围；<br>④手牌上限。<br>" ..
      "每回合开始时，你回复一点体力。",

  ["@yyfy_hengye"] = "横野",

  ["$yyfy_hengye1"] = "负剑觅烽火，狼烟既起战不休！",
  ["$yyfy_hengye2"] = "吴戈漫野，饮马处岂唯长江！",
}

hengye:addLoseEffect(function(self, player, is_death)
  player.room:setPlayerMark(player, "@" .. hengye.name, 0)
end)

hengye:addEffect(fk.Damage, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:getMark("@" .. hengye.name) < player.maxHp
  end,
  trigger_times = function(self, event, target, player, data)
    return data.damage
  end,
  on_use = function(self, event, target, player, data)
    local n = math.min(player:getMark("@" .. hengye.name) + 1, player.maxHp)
    player.room:setPlayerMark(player, "@" .. hengye.name, n)
  end,
})

hengye:addEffect(fk.BeforeDrawCard, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:getMark("@" .. hengye.name) > 0
  end,
  on_use = function(self, event, target, player, data)
    data.num = data.num + player:getMark("@" .. hengye.name)
  end,
})

hengye:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope, card, to)
    if card and card.trueName == "slash" then
      return player:getMark("@" .. hengye.name)
    end
  end,
})

hengye:addEffect("atkrange", {
  correct_func = function(self, player)
    return player:getMark("@" .. hengye.name)
  end
})

hengye:addEffect("maxcards", {
  correct_func = function(self, player)
    return player:getMark("@" .. hengye.name)
  end
})

hengye:addEffect(fk.TurnStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(hengye.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if not player:isWounded() then return end
    room:recover({
      who = player,
      num = 1,
      skillName = hengye.name,
      recoverBy = player
    })
  end,
})

return hengye
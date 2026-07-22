local shendao = fk.CreateSkill {
  name = "yyfy_shendao",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable {
  ["yyfy_shendao"] = "神刀",
  [":yyfy_shendao"] = "限定技，出牌阶段，你可以令一名其他角色成为<a href='yyfy_shendao-Murasame'><font color='red'>丛雨丸</font></a>的使用者，然后你进入<a href='yyfy_lingti'>灵体状态</a>直到其死亡。",

  ["yyfy_shendao-Murasame"] = "获得神刀·丛雨丸的角色，使用【杀】无距离次数限制且不可被响应，【杀】造成的伤害+1。",
  ["yyfy_lingti"] = "灵体状态：<br>不计入距离和座次的计算，防止受到的伤害、体力流失和体力上限减少；同时，跳过自己的出牌阶段。",
  ["@@yyfy_shendao"] = "丛雨",
  ["@@yyfy_shendao-lingti"] = "灵体"
}

shendao:addEffect("active", {
  prompt = "神刀：请令一名其他角色成为丛雨丸的使用者",
  can_use = function(self, player)
    return player and player:hasSkill(shendao.name) and player:usedSkillTimes(shendao.name, Player.HistoryGame) == 0
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  target_num = 1,
  target_filter = function(self, player, to_select, selected, selected_cards, card, extra_data)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local to = effect.tos[1]
    local player = effect.from
    local path = "packages/hidden-clouds/image/skins/yyfy_Murasame__1.png"
    local skindata = {}
    if player.general == "yyfy_Murasame" then
      skindata = { player.id, "changeskin", path, "" }
    elseif (player.deputyGeneral or "") == "yyfy_Murasame" then
      skindata = { player.id, "changeskin", "", path }
    end
    room:doBroadcastNotify("ChangeSkin", skindata)
    room:addPlayerMark(to, "@@yyfy_shendao")
    room:addPlayerMark(player, "@@yyfy_shendao-lingti")
  end,
})

shendao:addEffect("targetmod", {
  remove_func = function(self, player)
    return player:getMark("@@yyfy_shendao-lingti") ~= 0
  end
})

shendao:addEffect(fk.DetermineDamageInflicted, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:getMark("@@yyfy_shendao-lingti") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    data:preventDamage()
  end,
})

shendao:addEffect(fk.PreHpLost, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:getMark("@@yyfy_shendao-lingti") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    data:preventHpLost()
  end,
})

shendao:addEffect(fk.BeforeMaxHpChanged, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:getMark("@@yyfy_shendao-lingti") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    data:preventMaxHpChange()
  end,
})

shendao:addEffect(fk.EventPhaseChanging, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      data.phase == Player.Play and not data.skipped and player:getMark("@@yyfy_shendao-lingti") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.skipped = true
  end,
})

shendao:addEffect(fk.Death, {
  can_trigger = function (self, event, target, player, data)
    return target:getMark("@@yyfy_shendao") ~= 0 and player and player:hasSkill(self)
    and player:getMark("@@yyfy_shendao-lingti") ~= 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@@yyfy_shendao-lingti", 0)
  end
})

shendao:addEffect(fk.PreCardUse, {
  can_refresh = function(self, event, target, player, data)
    return target and player and player:hasSkill(self) and data.card.trueName == "slash"
    and target:getMark("@@yyfy_shendao") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.extraUse = true
  end,
})

shendao:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and card.trueName == "slash" and player and player:getMark("@@yyfy_shendao") ~= 0
  end,
  bypass_distances = function (self, player, skill, card, to)
    return card and card.trueName == "slash" and player and player:getMark("@@yyfy_shendao") ~= 0
  end
})

shendao:addEffect(fk.TargetSpecified, {
  can_refresh = function (self, event, target, player, data)
    return target and target:getMark("@@yyfy_shendao") ~= 0 and player and player:hasSkill(self) and data.card.trueName == "slash"
  end,
  on_refresh = function (self, event, target, player, data)
    data.disresponsive = true
    data.use.disresponsiveList = player.room:getAlivePlayers()
  end
})

shendao:addEffect(fk.DamageCaused, {
  can_refresh = function (self, event, target, player, data)
    return target and target:getMark("@@yyfy_shendao") ~= 0 and player and player:hasSkill(self) and data.card.trueName == "slash"
  end,
  on_refresh = function (self, event, target, player, data)
    data:changeDamage(1)
  end
})

return shendao
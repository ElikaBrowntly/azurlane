local juedao = fk.CreateSkill{
  name = "yyfy_juedao"
}

Fk:loadTranslationTable{
  ["yyfy_juedao"] = "绝刀",
  [":yyfy_juedao"] = "出牌阶段限一次，你可以令你本回合造成伤害时，若该伤害不是蓄力技造成的伤害且大于1点，"
  .."则该伤害翻倍。然后，你获得3点蓄力点。",
  ["@@yyfy_juedao-turn"] = "绝刀",

  ["$yyfy_juedao1"] = "只是余兴，来狩猎吧。",
  ["$yyfy_juedao2"] = "人形的容器还真是不方便呢。",
  ["$yyfy_juedao3"] = "那么，欢迎光临。"
}

local U = require "packages/utility/utility"

juedao:addEffect("active", {
  prompt = "绝刀：你可以令你符合条件时加伤，并获得3蓄力点",
  card_num = 0,
  card_filter = Util.FalseFunc,
  max_phase_use_time = 1,
  target_num = 0,
  target_filter = Util.FalseFunc,
  can_use = function(self, player)
    return player and player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:setPlayerMark(player, "@@yyfy_juedao-turn", 1)
    U.skillCharged(player, 3)
  end
})

juedao:addEffect(fk.DetermineDamageCaused, {
  priority = 2,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@yyfy_juedao-turn") > 0 and player:hasSkill(self)
    and data.damage > 1 and data.skillName and Fk.skills[data.skillName]
    and Fk.skills[data.skillName]:hasTag(Skill.Charge)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data:changeDamage(data.damage)
  end,
})

return juedao
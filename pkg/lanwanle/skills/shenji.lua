local shenji = fk.CreateSkill {
  name = "lan__shenji",
}

Fk:loadTranslationTable{
  ["lan__shenji"] = "神戟",
  [":lan__shenji"] = "的【杀】或【决斗】可额外指定两个目标。你因杀或决斗造成的伤害+2。",

  ["$lan__shenji1"] = "哈哈哈哈，何以伏地不起？",
  ["$lan__shenji2"] = "吾画戟一出，此贼还不饮恨当场！"
}

shenji:addEffect(fk.PreCardUse, {
  late_refresh = true,
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasShownSkill(shenji.name) and (data.card.trueName == "slash"
    or data.card.name == "duel") and #data:getAllTargets() > 1
  end,
  on_refresh = function (self, event, target, player, data)
    player:broadcastSkillInvoke(shenji.name)
    player.room:notifySkillInvoked(player, shenji.name, "offensive")
  end,
})

shenji:addEffect("targetmod", {
  extra_target_func = function(self, player, skill, card)
    if card and (card.trueName == "slash" or card.name == "duel") and player:hasSkill(self) then
      return 2
    end
  end,
})

shenji:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card and
    (data.card.trueName == "slash" or data.card.name == "duel")
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    data:changeDamage(2)
  end
})

return shenji
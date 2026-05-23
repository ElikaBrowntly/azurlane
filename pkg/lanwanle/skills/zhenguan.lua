local zhenguan = fk.CreateSkill{
  name = "lan__zhenguan",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["lan__zhenguan"] = "镇关",
  [":lan__zhenguan"] = "锁定技，摸牌阶段你额外摸3张牌；你使用【杀】的次数上限+2。",

  ["$lan__zhenguan1"] = "小儿猖狂，不知天高地厚",
  ["$lan__zhenguan2"] = "有我出马，君在此安待便是",
}

zhenguan:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_refresh = function(self, event, target, player, data)
    data.n = data.n + 3
  end,
})

zhenguan:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope)
    if skill.trueName == "slash_skill" and player:hasSkill(self) and scope == Player.HistoryPhase then
      return 2
    end
  end,
})

return zhenguan

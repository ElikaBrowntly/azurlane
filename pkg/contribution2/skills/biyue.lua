local biyue = fk.CreateSkill{
  name = "yyfy_biyue",
}

Fk:loadTranslationTable{
  ["yyfy_biyue"] = "闭月",
  [":yyfy_biyue"] = "每名角色的结束阶段，你可以摸2张牌。",

  ["$yyfy_biyue1"] = "闻西施、昭君貌可倾国，妾可比之一二乎？",
  ["$yyfy_biyue2"] = "月下一舞动倾城，素容自添好颜色。",
}

biyue:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(biyue.name) and target and target.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, biyue.name)
  end,
})

biyue:addAI(Fk.Ltk.AI.newInvokeStrategy{
  think = function(self, ai)
    return ai:getBenefitOfEvents(function(logic)
      logic:drawCards(ai.player, 1, self.skill_name)
    end) >= 0
  end,
})

return biyue
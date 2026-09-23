local suodi = fk.CreateSkill {
  name = "yyfy_suodi"
}

Fk:loadTranslationTable {
  ["yyfy_suodi"] = "缩地",
  [":yyfy_suodi"] = "出牌阶段限一次，你可以令自身本回合<a href=':yyfy_wumingsanduantu'>无明三段突</a>"
      .. "造成的伤害+50%，且【杀】造成的伤害+1。",
  ["@@yyfy_suodi-turn"] = "缩地",
  ["$yyfy_suodi1"] = "速攻全部解决！",
  ["$yyfy_suodi2"] = "执行公务！胆敢反抗之人一律斩杀！",
  ["$yyfy_suodi3"] = "迅疾，锐利！！"
}

suodi:addEffect("active", {
  anim_type = "offensive",
  prompt = "缩地：令宝具造成的伤害+50%，【杀】造成的伤害+1",
  card_num = 0,
  max_phase_use_time = 1,
  target_num = 0,
  target_filter = Util.FalseFunc,
  can_use = function(self, player)
    return player and player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:setPlayerMark(player, "@@yyfy_suodi-turn", 1)
  end
})

suodi:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@yyfy_suodi-turn") > 0 and player:hasSkill(self.name)
        and ((data.skillName or "") == "yyfy_wumingsanduantu" or
          ((data.card or {}).trueName or "") == "slash")
  end,
  on_cost = function(self, event, target, player, data)
    local cost = event:getCostData(self) or {}
    cost.case = (data.skillName or "") == "yyfy_wumingsanduantu" and 1 or 2
    event:setCostData(self, cost)
  end,
  on_use = function(self, event, target, player, data)
    local case = (event:getCostData(self) or {}).case or 2
    if case == 1 then
      data:changeDamage(math.floor(data.damage / 2))
      return
    end
    data:changeDamage(1)
  end
})

return suodi
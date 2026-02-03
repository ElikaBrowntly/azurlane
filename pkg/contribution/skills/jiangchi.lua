local jiangchi = fk.CreateSkill {
  name = "lan__jiangchi",
}

Fk:loadTranslationTable{
  ["lan__jiangchi"] = "将驰",
  [":lan__jiangchi"] = "出牌阶段开始时，你可以选择一项：1.摸两张牌，此阶段不能使用或打出【杀】；2.摸一张牌；3.重铸一张牌，"..
  "此阶段使用【杀】无距离限制且可以多使用一张【杀】。",

  ["#lan__jiangchi-invoke"] = "将驰：你可以选一项执行",
  ["@@lan__jiangchi_targetmod-phase"] = "将驰 多出杀",
  ["@@lan__jiangchi_prohibit-phase"] = "将驰 少出杀",

  ["$lan__jiangchi1"] = "谨遵父训，不可逞匹夫之勇。",
  ["$lan__jiangchi2"] = "吾定当身先士卒，振魏武雄风！",
  ["$lan__jiangchi3"] = "丈夫当将十万骑驰沙漠，立功建号耳。",
  ["$lan__jiangchi4"] = "披坚执锐，临危不难，身先士卒。",
}

jiangchi:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiangchi.name) and player.phase == Player.Play
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "lan__jiangchi_active",
      prompt = "#lan__jiangchi-invoke",
      cancelable = true,
    })
    if success and dat then
      event:setCostData(self, {cards = dat.cards, choice = dat.interaction})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice
    if choice == "lan__jiangchi_discard" then
      room:setPlayerMark(player, "@@lan__jiangchi_targetmod-phase", 1)
      -- 重铸一张牌
      room:recastCard(event:getCostData(self).cards, player, jiangchi.name)
    elseif choice == "draw1" then
      player:drawCards(1, jiangchi.name)
    elseif choice == "lan__jiangchi_draw2" then
      room:setPlayerMark(player, "@@lan__jiangchi_prohibit-phase", 1)
      player:drawCards(2, jiangchi.name)
    end
  end,
})

jiangchi:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope)
    if skill.trueName == "slash_skill" and player:getMark("@@lan__jiangchi_targetmod-phase") > 0 and
      scope == Player.HistoryPhase then
      return 1
    end
    if skill.trueName == "slash_skill" and player:getMark("@@lan__jiangchi_prohibit-phase") > 0 and
      scope == Player.HistoryPhase then
      return -1
    end
  end,
  bypass_distances = function(self, player, skill, card, to)
    return skill.trueName == "slash_skill" and player:getMark("@@lan__jiangchi_targetmod-phase") > 0
  end,
})

return jiangchi
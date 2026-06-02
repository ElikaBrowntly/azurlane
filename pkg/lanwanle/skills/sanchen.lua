local sanchen = fk.CreateSkill{
  name = "lan__sanchen",
}

Fk:loadTranslationTable{
  ["lan__sanchen"] = "三陈",
  [":lan__sanchen"] = "出牌阶段对每名角色限一次，你可令一名角色摸四张牌然后弃置三张牌。",

  ["#lan__sanchen"] = "三陈：令一名角色摸四张牌并弃置三张牌",
  ["#lan__sanchen-discard"] = "三陈：请弃置三张牌",
  ["@lan__sanchen"] = "三陈",

  ["$lan__sanchen1"] = "三陈累累，皆老臣珠玑之言，望陛下纳之任之。",
  ["$lan__sanchen2"] = "一陈谏固国，再陈论整军，三陈表吞吴！",
  ["$lan__sanchen3"] = "今天时在北，此书当陈，此战可胜！",
  ["$lan__sanchen4"] = "三陈表奏入金阙，十万虎贲饮长江。",
}

sanchen:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#lan__sanchen",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return table.find(Fk:currentRoom().alive_players, function (p)
      return not table.contains(player:getTableMark("lan__sanchen-turn"), p.id)
    end)
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and not table.contains(player:getTableMark("lan__sanchen-turn"), to_select.id)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:addTableMark(player, "lan__sanchen-turn", target.id)
    target:drawCards(4, sanchen.name)
    room:askToDiscard(target, {
      min_num = 3,
      max_num = 3,
      include_equip = true,
      skill_name = sanchen.name,
      prompt = "#lan__sanchen-discard",
      cancelable = false,
    })
  end,
})

return sanchen
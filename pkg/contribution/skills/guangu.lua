local guangu = fk.CreateSkill {
  name = "yyfy_guangu",
  tags = { Skill.Switch },
  max_branches_use_time = {
    ["yang"] = {
      [Player.HistoryPhase] = 1
    },
    ["yin"] = {
      [Player.HistoryPhase] = 1
    },
  }
}

Fk:loadTranslationTable {
  ["yyfy_guangu"] = "观骨",
  [":yyfy_guangu"] = "转换技，每回合各限一次，阳：你可以观看牌堆顶任意张牌；阴：你可以观看一名角色任意张手牌。然后你可以使用其中一张牌。",

  ["#yyfy_guangu-yang"] = "观骨：你可以观看牌堆顶任意张牌，然后使用其中一张牌",
  ["#yyfy_guangu-yin"] = "观骨：你可以观看一名角色任意张手牌，然后使用其中一张牌",
  ["#yyfy_guangu-choice"] = "观骨：选择你要观看的牌堆顶牌数",
  ["@yyfy_guangu-phase"] = "观骨",
  ["#yyfy_guangu-use"] = "观骨：你可以使用其中一张牌",

  ["$yyfy_guangu1"] = "此才拔萃，然观其形骨，恐早夭。",
  ["$yyfy_guangu2"] = "绯衣者，汝所拔乎？",
  ["$yyfy_guangu3"] = "骨相不言，万千因果皆作红粉骷髅。",
  ["$yyfy_guangu4"] = "寿数贫贱之相，其孕于气运而显于骨相。",
}

guangu:addEffect("active", {
  anim_type = "switch",
  prompt = function(self, player)
    return "#yyfy_guangu-" .. player:getSwitchSkillState(guangu.name, false, true)
  end,
  history_branch = function(self, player, data)
  ---@diagnostic disable-next-line: return-type-mismatch
    return player:getSwitchSkillState(guangu.name, nil, true)
  end,
  card_num = 0,
  ---@diagnostic disable-next-line: assign-type-mismatch
  target_num = function(self, player)
    return player:getSwitchSkillState(guangu.name, false) == fk.SwitchYang and 0 or 1
  end,
  can_use = function(self, player)
  ---@diagnostic disable-next-line: param-type-mismatch
    return guangu:withinBranchTimesLimit(player, player:getSwitchSkillState(guangu.name, nil, true), Player.HistoryPhase) and
        (#Fk:currentRoom().draw_pile > 0 or player:getSwitchSkillState(guangu.name, false) == fk.SwitchYin)
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    if player:getSwitchSkillState(guangu.name, false) == fk.SwitchYang then
      return false
    else
      return #selected == 0 and not to_select:isKongcheng()
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local status = player:getSwitchSkillState("yyfy_guangu", true, true)
    local ids = {}
    local target
    if status == "yang" then
      local x = #room.draw_pile
      if x == 0 then return false end
      local data = {}
      for i = 1, x, 1 do
        table.insert(data, i)
      end
      local result = room:askToNumber(player, {
        skill_name = guangu.name,
        min = 1,
        max = x,
        prompt = "#yyfy_guangu-choice",
        cancelable = false
      }) or 1
      ids = room:getNCards(result)
    else
      target = effect.tos[1]
      ids = room:askToChooseCards(player, {
        target = target,
        min = 1,
        max = #target:getCardIds("h"),
        flag = "h",
        skill_name = guangu.name,
      })
    end
    room:setPlayerMark(player, "@yyfy_guangu-phase", #ids)
    --- 观骨特判【酒】
    local to_use = table.filter(ids, function(id)
      local card = Fk:getCardById(id)
      return card.trueName ~= "analeptic" or card.skill:withinTimesLimit(player, Player.HistoryTurn, card)
    end)
    local use = room:askToUseRealCard(player, {
      pattern = to_use,
      skill_name = guangu.name,
      prompt = "#yyfy_guangu-use",
      extra_data = {
        bypass_times = true,
        extraUse = true,
        expand_pile = target ~= player and ids,
      },
      skip = true
    })
    if use then
      if use.card.trueName == "analeptic" then
        use.extraUse = false
      end
      room:useCard(use)
    end
  end,
})

return guangu
local jianzhi = fk.CreateSkill{
  name = "yyfy_jianzhi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["yyfy_jianzhi"] = "谏直",
  [":yyfy_jianzhi"] = "锁定技，结束阶段，你进行至多X次判定（X为你本回合通过〖切议〗获得的牌数），然后将判定牌中你本回合使用过的花色的牌分配给任意角色。",

  ["#yyfy_jianzhi-choice"] = "谏直：选择要进行判定的次数",
  ["#yyfy_jianzhi-give"] = "谏直：将这些牌分配给任意角色，点“取消”自己保留",

  ["$yyfy_jianzhi1"] = "昔虹贯牛山，管仲谏桓公无近妃宫。",
  ["$yyfy_jianzhi2"] = "老臣三尺讲席未冷，岂容佞言惑君？",
}

jianzhi:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(jianzhi.name) and player.phase == Player.Finish and
      player:getMark("yyfy_qieyi-turn") > 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local choices = {}
    for i = 1, player:getMark("yyfy_qieyi-turn"), 1 do
      table.insert(choices, tostring(i))
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = jianzhi.name,
      prompt = "#yyfy_jianzhi-choice",
    })
    local suits = {}
    room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
      local use = e.data
      if use.from == player then
        table.insertIfNeed(suits, use.card:getSuitString())
      end
    end, Player.HistoryTurn)
    table.removeOne(suits, "nosuit")
    local cards = {}
    for _ = 1, tonumber(choice) do
      local judge = {
        who = player,
        reason = jianzhi.name,
        pattern = ".|.|"..table.concat(suits, ","),
      }
      room:judge(judge)
      if judge.card then
        table.insert(cards, judge.card.id)
      end
    end
    if player.dead then return end
    local ids = table.filter(cards, function (id)
      return table.contains(suits, Fk:getCardById(id):getSuitString()) and table.contains(room.discard_pile, id)
    end)
    if #ids > 0 then
      local result = room:askToYiji(player, {
        min_num = 0,
        max_num = #ids,
        skill_name = jianzhi.name,
        targets = room.alive_players,
        cards = ids,
        prompt = "#yyfy_jianzhi-give",
        expand_pile = ids,
        skip = true,
      })
      for _, value in pairs(result) do
        for _, id in ipairs(value) do
          table.removeOne(ids, id)
        end
      end
      if #ids > 0 then
        table.insertTable(result[player.id], ids)
      end
      room:doYiji(result, player, jianzhi.name)
    end
  end,
})

return jianzhi
local QC_huishi = fk.CreateSkill({
  name = "QC_huishi",
  tags = { Skill.Permanent },
})
Fk:loadTranslationTable {
  ["QC_huishi"] = "慧识",
  [":QC_huishi"] = "持恒技，出牌阶段限一次，你可以判定，若判定点数与本次流程中的其他点数结果均不同，你可加1点体力上限并回复1点体力值，然后重复此流程。"..
                   "最后你获得本次流程中所有生效的判定牌，然后直到你的下一个回合开始，你使用或打出的牌的基础数值+X（X为最后一张判定牌的点数）",
  ["@QC_huishi-turn"] = "慧识数值+",
  ["#QC_huishi-choose"] = "慧识：将这些判定牌交给一名角色，点“取消”自己获得",
  ["#QC_huishi"] = "你可进行判定，然后获得判定牌，其间你增加体力上限",
  ["#QC_huishi-ask"] = "慧识：你可以加1点体力上限并重复此流程",
}

QC_huishi:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#QC_huishi",
  can_use = function(self, player)
    return player:usedSkillTimes(QC_huishi.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local cards = {}
    while true do
      local parsePattern = table.concat(table.map(cards, function(card)
        return card.number
      end), ",")
      local judge = {
        who = player,
        reason = QC_huishi.name,
        pattern = ".|.|" .. (parsePattern == "" and "." or "^(" .. parsePattern .. ")"),
        skipDrop = true,
      }
      room:judge(judge)
      table.insert(cards, judge.card)
      if not table.every(cards, function(card)
            return card == judge.card or judge.card:compareNumberWith(card, true)
          end) or
          player.dead or
          not room:askToSkillInvoke(player, {
            skill_name = QC_huishi.name,
            prompt = "#QC_huishi-ask",
          })
      then
        break
      else
        room:changeMaxHp(player, 1)
        room:recover { num = 1, skillName = QC_huishi.name, who = player, recoverBy = player }
      end
    end
    cards = table.filter(cards, function(card)
      return room:getCardArea(card.id) == Card.Processing
    end)
    if #cards == 0 then
      return
    elseif player.dead then
      room:cleanProcessingArea(cards)
      return
    end
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room.alive_players,
      skill_name = QC_huishi.name,
      prompt = "#QC_huishi-choose",
      cancelable = true,
    })
    if #to > 0 then
      to = to[1]
    else
      to = player
    end
    room:moveCardTo(cards, Card.PlayerHand, to, fk.ReasonGive, QC_huishi.name, nil, true, player)
    local last_card = cards[#cards]
    if last_card then
      room:setPlayerMark(player, "@QC_huishi-turn", last_card.number)
    end
  end,
})

QC_huishi:addEffect(fk.BeforeCardUseEffect, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@QC_huishi-turn") > 0 and data.card and data.card.type ~= Card.TypeEquip
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local num = tonumber(player:getMark("@QC_huishi-turn"))
    data.additionalDamage = (data.additionalDamage or 0) + num
    data.additionalRecover = (data.additionalRecover or 0) + num
  end,
})

return QC_huishi

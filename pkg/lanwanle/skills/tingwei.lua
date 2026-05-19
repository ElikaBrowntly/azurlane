local tingwei = fk.CreateSkill{
  name = "lan__tingwei",
}

Fk:loadTranslationTable{
  ["lan__tingwei"] = "霆威",
  [":lan__tingwei"] = "你使用的伤害牌每指定一个目标，便获得4个“霆”标记。然后你可以选择一名目标角色，其选择任意项（每少选一项，你额外获得2个“霆”标记）：<br>"..
  "1.非锁定技失效至其下个回合结束；<br>"..
  "2.交给你一张装备牌；<br>"..
  "3.此牌对其造成伤害+1：<br>"..
  "4.随机弃一张牌。<br>"..
  "若其均不选择，其进入连环状态。",

  ["@lan__machao_thunder"] = "霆",
  ["#lan__tingwei-choose"] = "霆威：令一名目标角色选择执行任意项",
  ["#lan__tingwei-invoke"] = "霆威：令 %dest 选择执行任意项",
  ["#lan__tingwei-choice"] = "霆威：执行任意项以令 %src 少获得2倍的“霆”标记，不执行则进入连环状态",
  ["lan__tingwei_1"] = "非锁定技失效至你下个回合结束",
  ["lan__tingwei_2"] = "交给其一张装备牌",
  ["lan__tingwei_3"] = "此牌对你造成伤害+1",
  ["lan__tingwei_4"] = "随机弃一张牌",
  ["@@lan__tingwei_invalidity"] = "非锁定技失效",
  ["#lan__tingwei-give"] = "霆威：交给 %src 一张装备牌",

  ["$lan__tingwei1"] = "雷敕已传，三界难逃！",
  ["$lan__tingwei2"] = "跪下！迎接你的神罚！",
  ["$lan__tingwei3"] = "尔可再问没心，岂欲与天一战？",
  ["$lan__tingwei4"] = "望我者惧怖，闻我者悚骇！",
}

tingwei:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tingwei.name) and
      data.firstTarget and data.card.is_damage_card and
      table.find(data.use.tos, function (p)
        return not p.dead
      end)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@lan__machao_thunder", 4 * #data.use.tos)
    local targets = table.filter(data.use.tos, function (p)
      return not p.dead
    end)
    if #targets == 1 then
      if not room:askToSkillInvoke(player, {
        skill_name = tingwei.name,
        prompt = "#lan__tingwei-invoke::" .. targets[1].id,
      }) then
        return
      end
    else
      targets = room:askToChoosePlayers(player, {
        targets = targets,
        min_num = 1,
        max_num = 1,
        prompt = "#lan__tingwei-choose",
        skill_name = tingwei.name,
        cancelable = true,
      })
      if #targets ~= 1 then return end
    end
    local to = targets[1]
    local choices = room:askToChoices(to, {
      choices = { "lan__tingwei_1", "lan__tingwei_2", "lan__tingwei_3", "lan__tingwei_4" },
      min_num = 0,
      max_num = 4,
      skill_name = tingwei.name,
      prompt = "#lan__tingwei-choice::"..player.id,
      cancelable = true,
    })
    if table.contains(choices, "lan__tingwei_1") then
      room:addPlayerMark(to, "@@lan__tingwei_invalidity", 1)
      room:addPlayerMark(to, MarkEnum.UncompulsoryInvalidity, 1)
    end
    if table.contains(choices, "lan__tingwei_2") then
      local card = room:askToCards(to, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = tingwei.name,
        pattern = ".|.|.|.|.|equip",
        prompt = "#lan__tingwei-give:" .. player.id,
        cancelable = true,
      })
      if #card > 0 then
        room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonGive, tingwei.name, nil, false, to)
      else
        table.removeOne(choices, "lan__tingwei_2")
      end
    end
    if table.contains(choices, "lan__tingwei_3") then
      data.extra_data = data.extra_data or {}
      data.extra_data.tingwei = data.extra_data.tingwei or {}
      table.insert(data.extra_data.tingwei, to.id)
    end
    if table.contains(choices, "lan__tingwei_4") then
      local cards = table.filter(to:getCardIds("he"), function (id)
        return not to:prohibitDiscard(id)
      end)
      if #cards > 0 then
        room:throwCard(room:tableRandomPick(cards), tingwei.name, to, to)
      else
        table.removeOne(choices, "lan__tingwei_4")
      end
    end
    if #choices == 0 and not to.chained then
      to:setChainState(true)
    end
    if #choices < 4 then
      room:addPlayerMark(player, "@lan__machao_thunder", 2 * (4 - #choices))
    end
  end,
})

tingwei:addEffect(fk.DamageInflicted, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if player.dead or data.card == nil or target ~= player then return false end
    local room = player.room
    local use_event = room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
    if not use_event then return false end
    local use = use_event.data
    return use.extra_data and use.extra_data.tingwei and table.contains(use.extra_data.tingwei, player.id)
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(1)
  end,
})

tingwei:addEffect(fk.TurnEnd, {
  late_refresh = true,
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@lan__tingwei_invalidity") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:removePlayerMark(player, MarkEnum.UncompulsoryInvalidity, player:getMark("@@lan__tingwei_invalidity"))
    room:setPlayerMark(player, "@@lan__tingwei_invalidity", 0)
  end,
})

return tingwei
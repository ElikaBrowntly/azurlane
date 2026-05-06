local QC_guanxing = fk.CreateSkill{
  name = "QC_guanxing",
  tags = { Skill.Permanent },
  anim_type = "drawcard",
}

Fk:loadTranslationTable{
  ["QC_guanxing"] = "观星",
  [":QC_guanxing"] = "持恒技，准备阶段，你将牌堆顶的七张牌置于武将牌上，称为“星”，然后你可以将任意张“星”以任意顺序置于牌堆顶。你可以如手牌般使用或打出“星”。"..
                     "出牌阶段限一次：你可以弃置任意张“星”，然后选择任意名角色，令其本回合内受到的火焰伤害+X（X为弃置的“星”数）。",
  ["$QC-star"] = "星",
  ["#QC_guanxing-yes"] = "是否将星置于牌堆顶？",
  ["#QC_guanxing-choose"] = "观星：请调整星与牌堆顶的顺序",
  ["#QC_guanxing-choose-fire"] = "观星：选择受到火焰伤害增加的角色",
  ["@QC_guanxing_fire-turn"] = "火焰增伤",
  ["#QC_guanxing-fire"] = "观星：你可以弃置任意张“星”，令所选角色本回合内受到火焰伤害+X",
}

local function GuanXingArrange(player)
  local room = player.room
  if #player:getPile("$QC-star") == 0 then return end
  local choice = room:askToChoice(player, {
    skill_name = QC_guanxing.name,
    prompt = "#QC_guanxing-yes",
    choices = {"是", "否"},
  })
  if choice == "否" then return end
  local cids = room:askToArrangeCards(player, {
    skill_name = QC_guanxing.name,
    card_map = { player:getPile("$QC-star") },
    prompt = "#QC_guanxing-choose",
    free_arrange = true,
    cancelable = true,
  })
  room:swapCardsWithPile(player, cids[1], {}, QC_guanxing.name, "Top")
end

QC_guanxing:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(QC_guanxing.name)
           and player.phase == Player.Start
           and player.room.current == player
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:addToPile("$QC-star", player.room:getNCards(7, "top"), false, QC_guanxing.name)
    GuanXingArrange(player)
  end,
})

QC_guanxing:addEffect("filter", {
  handly_cards = function(self, player)
    if player:hasSkill(QC_guanxing.name) then
      return player:getPile("$QC-star")
    end
  end,
})

QC_guanxing:addEffect("active", {
  anim_type = "offensive",
  prompt = "#QC_guanxing-fire",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return #player:getPile("$QC-star") > 0
           and player:usedSkillTimes(QC_guanxing.name, Player.HistoryPhase) < 1
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local cards = room:askToCards(player, {
      skill_name = QC_guanxing.name,
      prompt = "#QC_guanxing-choose-fire",
      flag = "$QC-star",
      min_num = 1,
      max_num = #player:getPile("$QC-star"),
      pattern = ".|.|.|$QC-star",
      expand_pile = "$QC-star",
    })
    if #cards == 0 then return end
    room:throwCard(cards, QC_guanxing.name, player, player)
    local value = #cards
    local targets = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = #room.alive_players,
      targets = room.alive_players,
      skill_name = QC_guanxing.name,
      prompt = "#QC_guanxing-choose-fire",
      cancelable = false,
    })
    for _, p in ipairs(targets) do
      room:setPlayerMark(p, "@QC_guanxing_fire-turn", value)
    end
    local targetIds = table.map(targets, function(p) return p.id end)
    room:setPlayerMark(player, "_QC_fire_targets", targetIds)
  end,
})

QC_guanxing:addEffect(fk.DamageInflicted, {
  mute = true,
  priority = 101,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@QC_guanxing_fire-turn") > 0 and data.damageType == fk.FireDamage
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + tonumber(player:getMark("@QC_guanxing_fire-turn"))
  end,
})

local function clearFireMarks(player)
  local room = player.room
  local targetIds = player:getTableMark("_QC_fire_targets")
  for _, id in ipairs(targetIds) do
    local p = room:getPlayerById(id)
    if p then
      room:setPlayerMark(p, "@QC_guanxing_fire-turn", 0)
    end
  end
  room:setPlayerMark(player, "_QC_fire_targets", 0)
end

QC_guanxing:addEffect(fk.EventPhaseEnd, {
  mute = true,         
  no_indicate = true,   
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(QC_guanxing.name)
           and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    clearFireMarks(player)
  end,
})

QC_guanxing:addEffect(fk.Death, {
  mute = true,
  no_indicate = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getTableMark("_QC_fire_targets") ~= 0
  end,
  on_use = function(self, event, target, player, data)
    clearFireMarks(player)
  end,
})

QC_guanxing:addEffect(fk.Death, {
  mute = true,
  no_indicate = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target:getMark("@QC_guanxing_fire-turn") > 0
  end,
  on_use = function(self, event, target, player, data)
    target.room:setPlayerMark(target, "@QC_guanxing_fire-turn", 0)
  end,
})

return QC_guanxing
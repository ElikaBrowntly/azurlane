local QC_pojun = fk.CreateSkill{
  name = "QC_pojun",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["QC_pojun"] = "破军",
  [":QC_pojun"] = "持恒技，当你使用伤害牌指定目标后，你可将其至多 X 张牌扣置于该角色的武将牌旁（X 为你与该角色体力值之和），回合结束时，该角色获得这些牌。你对手牌数不大于你的角色造成伤害时伤害 + 1；你对装备区牌数不大于你的角色造成伤害时伤害 + 1；你对没有手牌的角色造成伤害时，该伤害翻倍。",
  ["#QC_pojun-put"] = "破军：你可以将目标至多 %arg 张牌扣置于其武将牌旁",
  ["$QC_pojun"] = "破军",
}

QC_pojun:addEffect(fk.TargetSpecified, {
  priority = 2,
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(QC_pojun.name)
      and data.card and data.card.is_damage_card
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.to
    if to:isNude() then return false end
    local max_num = to.hp + player.hp
    local cards = room:askToChooseCards(player, {
      prompt = "#QC_pojun-put:::" .. max_num,
      target = to,
      min = 1,
      max = max_num,
      flag = "he",
      skill_name = QC_pojun.name,
    })
    if not cards or #cards == 0 then return false end
    to:addToPile("$QC_pojun", cards, false, QC_pojun.name, player)
  end,
})

QC_pojun:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  mute = true,
  no_indicate = true,
  can_trigger = function(self, event, target, player, data)
    return not player.dead and #player:getPile("$QC_pojun") > 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:moveCardTo(player:getPile("$QC_pojun"), Card.PlayerHand, player, fk.ReasonPrey, QC_pojun.name)
  end,
})

QC_pojun:addEffect(fk.DamageCaused, {
  priority = 3,
  mute = true,
  no_indicate = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return data.from == player and player:hasSkill(QC_pojun.name) and data.card
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local to = data.to
    local addDamage = 0
    if #to:getCardIds("h") <= #player:getCardIds("h") then
      addDamage = addDamage + 1
    end
    if #to:getCardIds("e") <= #player:getCardIds("e") then
      addDamage = addDamage + 1
    end
    if addDamage > 0 then
      data.damage = data.damage + addDamage
    end
  end,
})

QC_pojun:addEffect(fk.DamageCaused, {
  priority = 0.01,
  mute = true,
  no_indicate = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return data.from == player and player:hasSkill(QC_pojun.name)
      and data.card and data.card.is_damage_card
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    if #data.to:getCardIds("h") <= 0 then
      data.damage = data.damage * 2
    end
  end,
})

return QC_pojun
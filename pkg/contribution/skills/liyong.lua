local liyong = fk.CreateSkill {
  name = "yyfy_liyong",
  tags = { Skill.Compulsory },
  dynamic_desc = function (self, player)
    if player:getMark("yyfy_liyong_update") > 0 then
      return "yyfy_liyong_update"
    end
  end
}

Fk:loadTranslationTable{
  ["yyfy_liyong"] = "厉勇",
  [":yyfy_liyong"] = "锁定技，你的锦囊牌和防御坐骑牌均视为【杀】。<br>"..
  "你以此法使用的【杀】无距离限制。你使用的黑色【杀】不可被响应，你使用的红色【杀】伤害值+1。<br>"..
  "<b>二级：</b>锁定技，你的牌均视为【杀】。你以此法使用的【杀】拥有以下效果："..
  "1.无距离限制且无视防具；2.不可被响应且伤害+1。",

  [":yyfy_liyong_update"] = "锁定技，你的牌均视为【杀】。你以此法使用的【杀】拥有以下效果："..
  "1.无距离限制且无视防具；2.不可被响应且伤害+1。",

  ["$yyfy_liyong1"] = "吾为神祇，当镇压三界顽敌！",
  ["$yyfy_liyong2"] = "作奸犯科之徒，必以刑裁之！",
}
-- 视为杀
liyong:addEffect("filter", {
  anim_type = "offensive",
  card_filter = function(self, card, player)
    if player:getMark("yyfy_liyong_update") > 0 then
      return player:hasSkill(self.name) and table.contains(player:getCardIds("h"), card.id)
    end
    return player:hasSkill(self.name) and table.contains(player:getCardIds("h"), card.id)
    and (card.type == Card.TypeTrick or card.sub_type == Card.SubtypeDefensiveRide)
  end,
  view_as = function(self, player, to_select)
    to_select:setMark("yyfy_liyong-method", 1) -- “以此法”
    return Fk:cloneCard("slash", to_select.suit, to_select.number)
  end,
})

-- 无距离限制
liyong:addEffect("targetmod", {
  bypass_distances = function (self, player, skill, card)
    return player:hasSkill(self.name) and card and card:getMark("yyfy_liyong-method") > 0
  end
})

-- 不可被响应
liyong:addEffect(fk.CardUsing, {
  mute = true,
  on_cost = function(self, event, target, player, data)
    if player:getMark("yyfy_liyong_update") > 0 then
      return data.card.trueName == "slash" and data.card:getMark("yyfy_liyong-method") > 0
    end
    return player:hasSkill(self.name) and data.card.trueName == "slash"
    and data.card.color == Card.Black
  end,
  on_use = function(self, event, target, player, data)
    data.disresponsiveList = data.disresponsiveList or {}
    for _, p in ipairs(player.room.alive_players) do
      table.insertIfNeed(data.disresponsiveList, p)
    end
  end,
})

-- 伤害+1
liyong:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if player:getMark("yyfy_liyong_update") > 0 then
      return target == player and data.card and data.card.trueName == "slash"
      and data.card:getMark("yyfy_liyong-method") > 0
    end
    return
      target == player and data.card and data.card.trueName == "slash" and
      data.card.color == Card.Red and player.room.logic:damageByCardEffect()
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(1)
  end,
})

-- 无视防具
liyong:addEffect(fk.TargetSpecified, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card and data.card.trueName == "slash"
    and not data.to.dead and player:getMark("yyfy_liyong_update") > 0 and data.card:getMark("yyfy_liyong-method") > 0
  end,
  on_cost = function(self, event, target, player, data)
    event:setCostData(self, { tos = { data.to } })
    return true
  end,
  on_use = function(self, event, target, player, data)
    data.to:addQinggangTag(data)
  end,
})

return liyong
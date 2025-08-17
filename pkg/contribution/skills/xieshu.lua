local xieshu = fk.CreateSkill{
  name = "lan__xieshu",
}

Fk:loadTranslationTable{
  ["lan__xieshu"] = "挟术",
  [":lan__xieshu"] = "当你造成或受到牌的伤害后，你可以弃置伤害牌名字数张牌，摸已损失体力值数张牌。",
  ["#lan__xieshu-invoke"] = "挟术：是否弃置%arg张牌并摸%arg2张牌",
  ["$lan__xieshu1"] = "今长缨在手，欲问鼎九州。",
  ["$lan__xieshu2"] = "我有佐国之术，可缚苍龙。",
  ["$lan__xieshu3"] = "大丈夫胸怀四海，有提携玉龙之术。",
  ["$lan__xieshu4"] = "王霸之志在胸，我岂池中之物？",
  ["$lan__xieshu5"] = "历经风浪至此，会不可止步于龙门。",
  ["$lan__xieshu6"] = "我若束手无策，诸位又有何施为？",
  ["$lan__xieshu7"] = "于天下觉春秋尚早，于伯约恨相见太迟",
}

local spec = {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xieshu.name) and data.card
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xieshu.name,
      prompt = "#lan__xieshu-invoke:::"..Fk:translate(data.card.trueName, "zh_CN"):len()..":"..player:getLostHp(),
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player.dead then return false end
    local n = Fk:translate(data.card.trueName, "zh_CN"):len()
    local cards = room:askToDiscard(player, {
      min_num = n,
      max_num = n,
      include_equip = true,
      skill_name = xieshu.name,
      cancelable = false,
    })
    if #cards == 0 or player.dead then return end
    if player:isWounded() then
      player:drawCards(player:getLostHp(), xieshu.name)
    end
  end,
}
xieshu:addEffect(fk.Damage, spec)
xieshu:addEffect(fk.Damaged, spec)

return xieshu
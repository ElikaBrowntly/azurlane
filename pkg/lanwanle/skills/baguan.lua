local baguan = fk.CreateSkill {
  name = "lan__baguan",
  tags = { Skill.Combo },
}

Fk:loadTranslationTable{
  ["lan__baguan"] = "霸关",
  [":lan__baguan"] = "连招技（单目标牌+武器牌），你可以将至多5张手牌当一张【杀】使用，此【杀】伤害增加你用于转化的牌数。",

  ["#lan__baguan-use"] = "霸关：你可以将至多5张手牌当【杀】使用（伤害增加你选择的牌数）",
  ["@@lan__baguan"] = "霸关 +武器牌",

  ["$lan__baguan1"] = "颅献白骨观，血祭黄沙场！",
  ["$lan__baguan2"] = "拥酒炙胡马，北虏复唱匈奴歌！",
}

baguan:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(baguan.name) and
      data.card.sub_type == Card.SubtypeWeapon and
      data.extra_data and data.extra_data.combo_skill and data.extra_data.combo_skill[baguan.name] and
      table.contains(player:getEquipments(Card.SubtypeWeapon), data.card.id) and
      #player:getHandlyIds() > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local use = room:askToUseVirtualCard(player, {
      name = "slash",
      skill_name = baguan.name,
      prompt = "#lan__baguan-use",
      cancelable = true,
      extra_data = {
        bypass_times = true,
        extraUse = true,
      },
      card_filter = {
        n = { 1, 5 },
        cards = player:getHandlyIds(),
      },
      skip = true,
    })
    if use then
      event:setCostData(self, {extra_data = use})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@lan__baguan", 0)
    local use = event:getCostData(self).extra_data
    use.additionalDamage = #Card:getIdList(use.card)
    room:useCard(use)
  end,
})

baguan:addEffect(fk.AfterCardUseDeclared, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(baguan.name, true) and
      not table.contains(data.card.skillNames, baguan.name)
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    if player:getMark("@@lan__baguan") > 0 and data.card.sub_type == Card.SubtypeWeapon then
      data.extra_data = data.extra_data or {}
      data.extra_data.combo_skill = data.extra_data.combo_skill or {}
      data.extra_data.combo_skill[baguan.name] = true
    end
    --此技能的单目标牌为使用时的目标数为1，非牌面属性
    if data.tos and #data.tos == 1 then
      room:setPlayerMark(player, "@@lan__baguan", 1)
    else
      room:setPlayerMark(player, "@@lan__baguan", 0)
    end
  end,
})

return baguan
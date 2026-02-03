local jixi = fk.CreateSkill {
  name = "lan__jixi",
}

Fk:loadTranslationTable {
  ["lan__jixi"] = "急袭",
  [":lan__jixi"] = "你可以将一张“田”当【顺手牵羊】使用。",

  ["#lan__jixi"] = "急袭：你可以将一张“田”当【顺手牵羊】使用",

  ["$lan__jixi1"] = "良田为济，神兵天降！",
  ["$lan__jixi2"] = "明至剑阁，暗袭蜀都！",
}

jixi:addEffect("active", {
  can_use = function(self, player)
    return player:hasSkill(jixi.name) and #player:getPile("lan__dengai_field") > 0
  end,
  target_num = 0,
  card_num = 0,
  prompt = "#lan__jixi",
  on_use = function(self, room, effect)
    local player = effect.from
    if #player:getPile("lan__dengai_field") == 0 then return end
    local target, chosenField, confirm = room:askToChooseCardsAndPlayers(player, {
      min_card_num = 1,
      max_card_num = 1,
      skill_name = self.name,
      targets = room:getAlivePlayers(false),
      min_num = 1,
      max_num = 1,
      pattern = ".|.|.|lan__dengai_field",
      expand_pile = "lan__dengai_field",
      prompt = "#lan__jixi"
    })
    if not confirm then return false end
    room:useVirtualCard("snatch", chosenField, player, target, jixi.name)
  end,
})

return jixi
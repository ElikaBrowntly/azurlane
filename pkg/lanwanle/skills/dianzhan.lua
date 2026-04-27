local dianzhan = fk.CreateSkill {
  name = "lan__dianzhan",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["lan__dianzhan"] = "点盏",
  [":lan__dianzhan"] = "锁定技，当你使用牌后，你令此牌所有目标横置，然后你重铸任意张此花色的手牌，并摸一张牌。",

  ["$lan__dianzhan1"] = "此灯如我，独向光明。",
  ["$lan__dianzhan2"] = "此间皆暗，唯灯瞩明。",
}

dianzhan:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.tos and #data.tos > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(data.tos) do
      p:setChainState(true)
    end
    local cards = table.filter(player:getCardIds("h"), function(id)
      return Fk:getCardById(id):compareSuitWith(data.card)
    end)
    -- 没该花色的牌，直接一张都不摸
    if #cards == 0 then return end
    -- 有该花色的牌，但是不想重铸，会保底摸一张
    cards = room:askToCards(player, {
      min_num = 0,
      max_num = #cards,
      skill_name = dianzhan.name,
      prompt = "点盏：请重铸任意张"..Fk:translate(data.card:getSuitString(true)).."手牌",
      pattern = ".|.|"..data.card:getSuitString().."|hand",
      cancelable = false -- 虽然不能点取消，但可以0张牌点确定
    })
    if #cards > 0 then
      room:recastCard(cards, player, dianzhan.name)
    end
    if player.dead then return end
    player:drawCards(1, dianzhan.name)
  end,
})

return dianzhan
local lilu = fk.CreateSkill {
  name = "lan__lilu",
  anim_type = "support",
}

Fk:loadTranslationTable{
  ["lan__lilu"] = "礼赂",
  [":lan__lilu"] = "摸牌阶段，你可以多摸体力上限张牌。此阶段结束时，你可以将至少一张手牌交给一名其他角色，"
  .."然后增加1点体力上限并回复1点体力。",

  ["#lan__lilu-invoke"] = "礼赂：你可以多摸体力上限张牌，然后将任意张手牌交给一名其他角色",
  ["@lan__lilu"] = "礼赂",
  ["#lan__lilu-give"] = "礼赂：将至少一张手牌交给一名其他角色，然后你加1点体力上限并回复1点体力",

  ["$lan__lilu1"] = "乱狱滋丰，以礼赂之。",
  ["$lan__lilu2"] = "微薄之礼，聊表敬意！",
  ["$lan__lilu3"] = "卿天人之姿，请纳此薄礼以修两家之好！",
  ["$lan__lilu4"] = "昔吕氏奇货天下，吾观君姿胜异人十倍！"
}

lilu:addEffect(fk.DrawNCards, {
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "#lan__lilu-invoke",
    }) and player and player:hasSkill(self.name) and target == player
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n + player.maxHp
  end
})

lilu:addEffect(fk.EventPhaseEnd, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player.phase == Player.Draw
    and not player:isKongcheng() and #player.room:getOtherPlayers(player, false) ~= 0
  end,
  on_cost = function ()
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to, cards, confirm = room:askToChooseCardsAndPlayers(player, {
      min_card_num = 1,
      max_card_num = 999,
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      pattern = ".|.|.|hand",
      skill_name = lilu.name,
      prompt = "#lan__lilu-give",
      cancelable = true,
    })
    if not confirm then return false end
    room:moveCardTo(cards, Card.PlayerHand, to[1], fk.ReasonGive, lilu.name, nil, false, player)
    if player.dead then return end
    player.room:changeMaxHp(player, 1)
    if player:isAlive() and player:isWounded() then
      player.room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = lilu.name,
      }
    end
  end
})
return lilu

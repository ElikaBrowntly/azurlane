local zhuishi = fk.CreateSkill {
  name = "yyfy_zhuishi",
  tags = {Skill.Compulsory},
  anim_type = "negative"
}

Fk:loadTranslationTable {
  ["yyfy_zhuishi"] = "追势",
  [":yyfy_zhuishi"] = "锁定技，你不能响应其他角色使用的【杀】。每当你成为【杀】的目标时，"..
  "你从牌堆中获得一张坐骑牌并与一名装备区有坐骑牌的角色交换位置。" ,

  ["yyfy_has-horse"] = "有坐骑牌",

  ["$yyfy_zhuishi1"] = "马踏祁连山河动，兵起玄黄奈何天！",
  ["$yyfy_zhuishi2"] = "一骑破霄汉，饮马星河、醉卧广寒！"
}

zhuishi:addEffect("prohibit", {
  prohibit_use = function (self, player, card)
    return player and player:hasSkill(self.name) and card.name == "jink"
  end
})

zhuishi:addEffect(fk.TargetConfirming, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:isAlive() and player:hasSkill(self.name) and data.card.name == "slash"
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local length = #room.draw_pile
    local cards = {}
    for i = 1, length, 1 do
      local card = Fk:getCardById(room.draw_pile[i])
      if card.sub_type == Card.SubtypeOffensiveRide or card.sub_type == Card.SubtypeDefensiveRide then
        cards = {card}
        break
      end
    end
    if player.dead then return end
    if #cards == 1  then
      room:obtainCard(player, cards, false, fk.ReasonPrey, player, zhuishi.name)
    end
    local players = {}
    for _, p in ipairs(room:getAlivePlayers()) do
      if p:getEquipment(Card.SubtypeOffensiveRide) or p:getEquipment(Card.SubtypeDefensiveRide) then
        table.insert(players, p)
      end
    end
    if #players == 0 then return false end
    players = room:askToChoosePlayers(player, {
      targets = players,
      min_num = 1,
      max_num = 1,
      skill_name = zhuishi.name,
      cancelable = false,
      prompt = "追势：请与一名装备区有坐骑牌的角色交换位置",
      target_tip_name = "yyfy_zhuishi-tip",
    })
    -- 交换player与players[1]的座位
    room:swapSeat(player, players[1])
  end
})

-- 目标提示：显示哪些角色有坐骑牌
Fk:addTargetTip{
  name = "yyfy_zhuishi-tip",
  target_tip = function(_, _, to_select)
    if to_select:getEquipment(Card.SubtypeOffensiveRide) or
    to_select:getEquipment(Card.SubtypeDefensiveRide) then
      return "yyfy_has-horse"
    end
  end,
}

return zhuishi
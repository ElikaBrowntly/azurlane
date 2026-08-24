local jiufa = fk.CreateSkill {
  name = "lan__jiufa",
}

Fk:loadTranslationTable{
  ["lan__jiufa"] = "九伐",
  [":lan__jiufa"] = "每当你使用或打出九张牌后，你可以获得牌堆顶的九张牌。",

  ["@lan__jiufa"] = "九伐",

  ["$lan__jiufa1"] = "九伐中原，以圆先帝遗志。",
  ["$lan__jiufa2"] = "日日砺剑，相报丞相厚恩。",
  ["$lan__jiufa3"] = "担北伐重托，当兴复汉室，还于旧都。",
  ["$lan__jiufa4"] = "任将军之职，应厉兵秣马，军出陇右。"
}

local spec = {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiufa.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room ---@type Room
    room:addPlayerMark(player, "@lan__jiufa")
    if player:getMark("@lan__jiufa") < 9 or not room:askToSkillInvoke(player, {
      skill_name = jiufa.name,
      prompt = "九伐：是否获得牌堆顶的九张牌",
    }) then return false end
    room:setPlayerMark(player, "@lan__jiufa", 0)
    room:obtainCard(player, room:getNCards(math.min(9, #room.draw_pile)), false, fk.ReasonJustMove, player, jiufa.name)
  end,
}

jiufa:addEffect(fk.CardUsing, spec)
jiufa:addEffect(fk.CardResponding, spec)

jiufa:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@lan__jiufa", 0)
end)

return jiufa
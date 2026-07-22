local renfa = fk.CreateSkill{
  name = "yyfy_renfa",
}

Fk:loadTranslationTable{
  ["yyfy_renfa"] = "忍法",
  [":yyfy_renfa"] = "一名角色的结束阶段，你可以随机发动一项忍术：<br><font color='#8300FF'>雷遁：对一名角色造成1点雷电伤害"..
  "</font><br><font color='red'>火遁：对一名角色造成1点火焰伤害</font><br><font color='blue'>水遁：令一名角色回复一点体力"..
  "</font><br><font color='#FFA500'>土遁：令一名角色获得1点护甲</font><br><font color='#19FF08'>风遁：令一名角色计算距离时获得+1/-1。</font>",

  ["@yyfy_renfa+"] = "+",
  ["@yyfy_renfa-"] = "-",
}

renfa:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(renfa.name) and target and target.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local i = math.random(5)
    local prompt = {
      "雷遁：你可以对一名角色造成1点雷电伤害",
      "火遁：你可以对一名角色造成1点火焰伤害",
      "水遁：你可以令一名角色回复一点体力",
      "土遁：你可以令一名角色获得1点护甲",
      "风遁：你可以令一名角色到其他角色-1，其他角色到其+1"
    }
    local to = room:askToChoosePlayers(player, {
      targets = room:getAlivePlayers(),
      min_num = 1,
      max_num = 1,
      cancelable = true,
      skill_name = renfa.name,
      prompt = prompt[i]
    })
    if not to or #to ~= 1 then return end
    to = to[1]
    if i == 5 then
      room:addPlayerMark(to, "@yyfy_renfa+")
      room:addPlayerMark(to, "@yyfy_renfa-")
      return
    end
    if i == 4 then
      room:changeShield(to, 1)
      return
    end
    if i == 3 then
      room:recover({
        who = to,
        num = 1,
        skillName = renfa.name,
        recoverBy = player
      })
      return
    end
    room:damage({
      from = player,
      to = to,
      damageType = i + 1,
      damage = 1,
      skillName = renfa.name
    })
  end,
})

renfa:addEffect("distance", {
  correct_func = function(self, from, to)
    if from:getMark("@yyfy_renfa-") then
      return -1
    end
    if to:getMark("@yyfy_renfa+") then
      return 1
    end
    return 0
  end,
})

return renfa
local bangshou = fk.CreateSkill {
  name = "yyfy_bangshou",
  tags = { Skill.Permanent, },
}
Fk:loadTranslationTable {
  ["yyfy_bangshou"] = "榜首",
  [":yyfy_bangshou"] = "持恒技，游戏开始时，你有51%的概率可以获得胜利。",
}

bangshou:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(self)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = bangshou.name,
      prompt = "榜首：是否尝试以51%的概率获得胜利？"
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if math.random(100) > 51 then
      room:doBroadcastNotify("ShowToast", "很遗憾，无事发生……")
      return
    end
    room:doBroadcastNotify("ShowToast", "投入了<font color='orangered'>调和之天救龙</font>的玩家赢得了决斗胜利！")
    if player.role == "lord" or player.role == "loyalist" then
      room:gameOver("lord+loyalist")
    else
      room:gameOver(player.role)
    end
  end,
})

return bangshou
local tongguan = fk.CreateSkill {
  name = "yyfy_tongguan",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable {
  ["yyfy_tongguan"] = "通关",
  [":yyfy_tongguan"] = "持恒技，当你解锁所有可攻略角色后，你获得游戏胜利。"
}

tongguan:addEffect(fk.AfterSkillEffect, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.skill.name == "yyfy_gonglue"
    and #player:getTableMark("@&yyfy_gonglue") == 4
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if player.role == "lord" or player.role == "loyalist" then
      room:gameOver("lord+loyalist")
    else
      room:gameOver(player.role)
    end
  end
})

return tongguan
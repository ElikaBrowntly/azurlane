local skel = fk.CreateSkill {
  name = "yyfy_muyang",
  tags = {Skill.Limited, Skill.Permanent},
}

Fk:loadTranslationTable{
  ["yyfy_muyang"] = "牡羊",
  [":yyfy_muyang"] = "限定技，你死亡时改为修整一轮。",
}

skel:addEffect(fk.BeforeGameOverJudge, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return data.who == player and player:hasSkill(skel.name, false, true) and player.rest == 0
    and player:usedSkillTimes(self.name) == 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    target._splayer:setDied(false)
    room:setPlayerRest(target, 1)
    if player == room.current then
      room:endTurn()
    end
  end,
})

return skel

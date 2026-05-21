local xunbie = fk.CreateSkill {
  name = "lan__xunbie",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["lan__xunbie"] = "殉别",
  [":lan__xunbie"] = "限定技，当你进入濒死状态时，你可以获得〖淑慎〗〖皇恩〗〖闺秀〗〖存嗣〗，然后将体力值回复至上限，防止你本回合受到的伤害。",

  ["@@lan__xunbie-turn"] = "殉别",

  ["$lan__xunbie1"] = "既为君之妇，何惧为君之鬼。",
  ["$lan__xunbie2"] = "今临难将罹，唯求不负皇叔。",
}

xunbie:addEffect(fk.EnterDying, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xunbie.name) and player.dying and player:usedSkillTimes(xunbie.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skills = {"dl__shushen", "dl__huangsi", "dl__guixiu", "dl__cunsi" }
    room:handleAddLoseSkills(player, skills, xunbie.name)
    room:setPlayerMark(player, "@@lan__xunbie-turn", 1)
    if player:isWounded() then
      room:recover{
        who = player,
        num = player.maxHp - player.hp,
        recoverBy = player,
        skillName = xunbie.name,
      }
    end
  end,
})

xunbie:addEffect(fk.DetermineDamageInflicted, {
  anim_type = "defensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@lan__xunbie-turn") > 0
  end,
  on_use = function(self, event, target, player, data)
    data:preventDamage()
  end,
})

return xunbie
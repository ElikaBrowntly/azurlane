local shenpei = fk.CreateSkill{
  name = "lan__shenpei",
  tags = { Skill.Permanent, Skill.Limited },
  related_skills = { "lan__huitian", "lan__ranjin" }
}

Fk:loadTranslationTable{
  ["lan__shenpei"] = "神霈",
  [":lan__shenpei"] = "持恒技，限定技，你进入濒死时，可增加X点体力上限并将体力回复至上限（X为你本局游戏进入过濒死的次数），"..
    "对一名角色造成等量雷电伤害并获得〖<a href=':lan__huitian'>回天</a>〗和〖<a href=':lan__ranjin'>燃尽</a>〗。",

  ["#lan__shenpei-invoke"]= "神霈：可回复%arg点体力并获得 回天",
  ["#lan__shenpei-choose"]= "神霈：选择1名其他角色，对其造成%arg点雷电伤害",

  ["$lan__shenpei1"] = "雄山峻壑终踏过，须信寒过总是春。",
  ["$lan__shenpei2"] = "世有云霓之望，维必借天馈之！",
}

shenpei:addEffect(fk.EnterDying, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player.hp < 1 and player:hasSkill(self) and
      player:usedSkillTimes(shenpei.name, Player.HistoryGame) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local x = 0
    room.logic:getEventsOfScope(GameEvent.Dying, 1, function(e)
      if e.data.who == player then
        x = x + 1
      end
    end, Player.HistoryGame)
    return room:askToSkillInvoke(player, {skill_name = shenpei.name, prompt = "#lan__shenpei-invoke:::" .. x,})
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local x = 0
    room.logic:getEventsOfScope(GameEvent.Dying, 1, function(e)
      if e.data.who == player then
        x = x + 1
      end
    end, Player.HistoryGame)
    room:changeMaxHp(player, x)
    room:recover {
      who = player,
      num = player.maxHp - player.hp,
      recoverBy = player,
      skillName = shenpei.name
    }
    if player.dead then return end
    room:handleAddLoseSkills(player, "lan__huitian|lan__ranjin")
    if player.dead then return end
    local others = room:getOtherPlayers(player, false)
    if #others == 0 then return end
    room:damage {
      from = player,
      to = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = others,
        skill_name = shenpei.name,
        prompt = "#lan__shenpei-choose:::" .. x,
        cancelable = false,
      })[1],
      damage = x,
      damageType = fk.ThunderDamage,
      skillName = shenpei.name
    }
  end,
})

return shenpei
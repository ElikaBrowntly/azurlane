local chengmo = fk.CreateSkill {
  name = "yyfy_chengmo",
  tags = { Skill.Wake },
  related_skills = { "yyfy_xieling" }
}

Fk:loadTranslationTable {
  ["yyfy_chengmo"] = "成魔",
  [":yyfy_chengmo"] = "觉醒技，当你成为场上体力上限唯一最大的角色时，你将武将牌变更为魔曹操，并获得技能〖挟令〗。",
}

local spec = {
  anim_type = "big",
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(self) and Fk.generals["sx__caocao"]
  end,
  can_wake = function (self, event, target, player, data)
    return not table.find(player.room:getOtherPlayers(player), function (p)
      return (p.maxHp or 0) >= player.maxHp
    end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local deputy = (player.deputyGeneral or "") == "yyfy_tumo__caocao" and true or false
    room:changeHero(player, "sx__caocao", true, deputy, true, false)
    room:handleAddLoseSkills(player, "yyfy_xieling")
  end,
}

chengmo:addEffect(fk.MaxHpChanged, spec)

chengmo:addEffect(fk.GameStart, spec)

chengmo:addEffect(fk.Deathed, spec)

return chengmo
local xieshi = fk.CreateSkill {
  name = "yyfy_xieshi",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable {
  ["yyfy_xieshi"] = "血噬",
  [":yyfy_xieshi"] = "持恒技，当你对一名角色造成伤害后，你可以增加1点体力上限并回复1点体力，然后令其减少1点体力上限。",

  ["#yyfy_xieshi-invoke"] = "血噬：你可以加1上限回1血，然后令%dest减1上限"
}

xieshi:addEffect(fk.Damage, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xieshi.name,
      prompt = "#yyfy_xieshi-invoke::" .. data.to.id
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, 1)
    room:recover {
      who = player,
      num = 1,
      recoverBy = player,
      skillName = xieshi.name
    }
    room:changeMaxHp(data.to, -1)
  end,
})

return xieshi
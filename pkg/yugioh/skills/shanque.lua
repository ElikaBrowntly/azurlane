local shanque = fk.CreateSkill {
  name = "yyfy_shanque",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable {
  ["yyfy_shanque"] = "山雀",
  [":yyfy_shanque"] = "持恒技，每回合限40次，其他角色使用牌或技能时，你摸1张牌、增加1点体力上限并回复1点体力。",

  ["@yyfy_shanque-turn"] = "山雀"
}

shanque:addLoseEffect(function(self, player, is_death)
  player.room:handleAddLoseSkills(player, self.name, nil, false, true)
end)

shanque:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(shanque.name) and player:getMark("@yyfy_shanque-turn") < 40
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, shanque.name)
    room:changeMaxHp(player, 1)
    room:recover({
      who = player,
      num = 1,
      skillName = shanque.name,
    })
    -- 计数
    room:addPlayerMark(player, "@yyfy_shanque-turn")
  end,
})

shanque:addEffect(fk.SkillEffect, {
  is_delay_effect = true,
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if target and target ~= player and data.skill.name ~= self.name
        and player:getMark("@yyfy_shanque-turn") < 40
        and player:hasSkill(shanque.name) and data.skill:isPlayerSkill(target) then
      player.room:addPlayerMark(player, "@yyfy_shanque-turn")
      return true
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, shanque.name)
    room:changeMaxHp(player, 1)
    room:recover({
      who = player,
      num = 1,
      skillName = shanque.name,
    })
  end,
})

return shanque
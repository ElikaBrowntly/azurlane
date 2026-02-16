local yuansu = fk.CreateSkill {
  name = "yyfy_yuansu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["yyfy_yuansu"] = "元素",
  [":yyfy_yuansu"] = "锁定技，当你即将造成属性伤害时，令目标获得“元素”标记，拥有此标记的角色发动技能时取消之，直到伤害结算。",

  ["@@yyfy_yuansu"] = "元素"
}

yuansu:addEffect(fk.PreDamage, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return data.from and data.from == player and player:hasSkill(self) and data.to ~= player
    and data.damageType ~= fk.NormalDamage
  end,
  on_trigger = function(self, event, target, player, data)
    player.room:setPlayerMark(data.to, "@@yyfy_yuansu", 1)
  end,
})

yuansu:addEffect(fk.SkillEffect, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target and player and player:hasSkill(self, true, true) and target:getMark("@@yyfy_yuansu") > 0
    and data.skill:isPlayerSkill(target) and target:hasSkill(data.skill:getSkeleton().name, true, true)
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    local e = room.logic:getCurrentEvent():findParent(GameEvent.SkillEffect)
    if e then
      room.logic:breakEvent(e)
    end
  end,
})

yuansu:addEffect(fk.DamageFinished, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self, true, true) and data.to:getMark("@@yyfy_yuansu") > 0
  end,
  on_trigger = function(self, event, target, player, data)
    player.room:setPlayerMark(data.to, "@@yyfy_yuansu", 0)
  end,
})

return yuansu
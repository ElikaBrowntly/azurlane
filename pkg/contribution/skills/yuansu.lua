local yuansu = fk.CreateSkill {
  name = "yyfy_yuansu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["yyfy_yuansu"] = "元素",
  [":yyfy_yuansu"] = "锁定技，当你使用属性伤害牌指定目标后，令其获得“元素”标记，拥有此标记的角色发动技能时取消之，且不能使用牌，直到此牌结算结束。",

  ["@@yyfy_yuansu"] = "元素"
}

yuansu:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return data.from and data.from == player and player:hasSkill(self) and data.to ~= player
    and data.card and table.contains({"fire__slash", "thunder__slash", "fire_attack"}, data.card.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(data.to, "@@yyfy_yuansu", 1)
  end,
})

yuansu:addEffect(fk.SkillEffect, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if target and player and player:hasSkill(self, true, true) and target:getMark("@@yyfy_yuansu") > 0
    and data.skill:isPlayerSkill(target) and target:hasSkill(data.skill:getSkeleton().name, true, true)
    and (player.tag[yuansu.name] or 0) < 20 then
      local n = player.tag[yuansu.name] or 0
      player.tag[yuansu.name] = n + 1
      return true
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local e = room.logic:getCurrentEvent():findParent(GameEvent.SkillEffect)
    if e then
      room.logic:breakEvent(e)
    end
  end,
})

yuansu:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    return player and player:getMark("@@yyfy_yuansu") > 0
  end
})

yuansu:addEffect(fk.CardUseFinished, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if not (player and player:hasSkill(self, true, true)) then return false end
    for _, to in ipairs(data.tos) do
      if to:getMark("@@yyfy_yuansu") > 0 then
        return true
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    for _, to in ipairs(data.tos) do
      if to:getMark("@@yyfy_yuansu") > 0 then
        player.room:setPlayerMark(to, "@@yyfy_yuansu", 0)
      end
    end
  end,
})

yuansu:addEffect(fk.EventTurnChanging, {
  is_delay_effect = true,
  can_refresh = function (self, event, target, player, data)
    return player and player:hasSkill(self) and player.tag[yuansu.name] ~= 0
  end,
  on_refresh = function (self, event, target, player, data)
    player.tag[yuansu.name] = 0
  end
})

return yuansu
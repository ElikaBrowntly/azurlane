local zengzhi = fk.CreateSkill {
  name = "yyfy_zengzhi",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable {
  ["yyfy_zengzhi"] = "增殖",
  [":yyfy_zengzhi"] = "永恒技，其他角色使用牌或技能时，你摸1张牌、增加1点体力上限并回复1点体力。",
  
  ["#yyfy_zengzhi_trigger"] = "%from 使用%arg，触发 %to 的「增殖」",
}

-- 永恒技：失去此技能时重新添加
zengzhi:addLoseEffect(function(self, player, is_death)
  player.room:handleAddLoseSkills(player, self.name, nil, false, true)
end)

-- 监听其他角色使用牌
zengzhi:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    -- 其他角色使用牌时触发，且技能持有者存活
    return target ~= player and player:hasSkill(zengzhi.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 摸1张牌
    player:drawCards(1, zengzhi.name)
    -- 增加1点体力上限
    room:changeMaxHp(player, 1)
    -- 回复1点体力
    room:recover({
      who = player,
      num = 1,
      skillName = zengzhi.name,
    })
    -- 发送日志
    room:sendLog{
      type = "#yyfy_zengzhi_trigger",
      from = data.from.id,
      to = {player.id},
      arg = data.card and data.card.name or "",
    }
  end,
})

-- 监听其他角色使用技能（发动技能）
zengzhi:addEffect(fk.SkillEffect, {
  is_delay_effect = true,
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target and target ~= player and data.skill.name ~= self.name and
           player:hasSkill(zengzhi.name) and data.skill:isPlayerSkill(target)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room  
    -- 摸1张牌
    player:drawCards(1, zengzhi.name)
    -- 增加1点体力上限
    room:changeMaxHp(player, 1)
    -- 回复1点体力
    room:recover({
      who = player,
      num = 1,
      skillName = zengzhi.name,
    })
    
    -- 发送日志
    room:sendLog{
      type = "#yyfy_zengzhi_trigger",
      from = target.id,
      to = {player.id},
      arg = data.skill.name,
    }
  end,
})

return zengzhi
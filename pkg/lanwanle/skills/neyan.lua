local neyan = fk.CreateSkill {
  name = "lan__neyan",
  tags = { Skill.Switch, Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["lan__neyan"] = "讷言",
  [":lan__neyan"] = "转换技，锁定技，你使用非装备牌时，阳：若此牌可以额外结算则多结算一次；阴：此牌无距离次数限制且不可被响应。",
}

neyan:addEffect(fk.CardUsing, {
  anim_type = "switch",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card.type ~= Card.TypeEquip
  end,
  on_use = function (self, event, target, player, data)
    if player:getSwitchSkillState(self.name, true) == fk.SwitchYang then
      -- 阳效果：杀、桃、酒、普通锦囊牌（不包含无懈可击）额外结算一次
      local card = data.card
      if card.trueName ~= "jink" and card.trueName ~= "nullification" and
        card.sub_type ~= Card.SubtypeDelayedTrick then
        data.additionalEffect = (data.additionalEffect or 0) + 1
      end
    else
      -- 阴效果
      data.disresponsiveList = player.room:getAlivePlayers(false)
      data.extraUse = true
    end
  end,
})

-- 阴效果：无距离和次数限制
neyan:addEffect("targetmod", {
  bypass_times = function (self, player, skill, scope, card, to)
    return player:hasSkill(neyan.name) and player:getSwitchSkillState(neyan.name) == fk.SwitchYin
    and card.type ~= Card.TypeEquip
  end,
  bypass_distances = function (self, player, skill, card, to)
    return player:hasSkill(neyan.name) and player:getSwitchSkillState(neyan.name) == fk.SwitchYin
    and card.type ~= Card.TypeEquip
  end,

})

return neyan
local yongheng = fk.CreateSkill{
  name = "yyfy_yongheng",
  tags = { Skill.Compulsory },
}


Fk:loadTranslationTable{
  ["yyfy_yongheng"] = "永恒",
  [":yyfy_yongheng"] = "锁定技，你的手牌数始终不少于体力上限。当你的体力上限增加时，你令一名角色失去等量体力上限。",
}

yongheng:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player:getHandcardNum() < player.maxHp
  end,
  on_trigger = function (self, event, target, player, data)
    local num = player.maxHp - player:getHandcardNum()
    if num > 0 then
      player:drawCards(num, yongheng.name)
    end
  end,
})

yongheng:addEffect(fk.MaxHpChanged, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.num > 0
  end,
  on_trigger = function (self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      targets = room:getAlivePlayers(),
      min_num = 1,
      max_num = 1,
      skill_name = yongheng.name,
      prompt = "永恒：请令一名角色减少"..tostring(data.num).."点体力上限",
      cancelable = false
    })
    if #to == 1 then
      room:changeMaxHp(to[1], - data.num)
    end
  end
})

return yongheng
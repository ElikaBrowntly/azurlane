local shengjianchujue = fk.CreateSkill{
  name = "shengjianchujue",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["shengjianchujue"] = "圣剑处决",
  [":shengjianchujue"] = "锁定技，当你造成或受到伤害后，你获得一层「圣剑」，对方获得一层「处决」。"..
  "每名角色每拥有一层「圣剑」/「处决」则造成/受到的伤害+1。",
  
  ["@shengjian"] = "圣剑",
  ["@chujue"] = "处决",
}

shengjianchujue:addEffect(fk.Damage, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and data.from == player
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    room:addPlayerMark(player, "@shengjian", 1)

    if data.to and not data.to.dead then
      room:addPlayerMark(data.to, "@chujue", 1)
    end
  end,
})

shengjianchujue:addEffect(fk.Damaged, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and data.to == player
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    room:addPlayerMark(player, "@shengjian", 1)
    
    if data.from and not data.from.dead then
      room:addPlayerMark(data.from, "@chujue", 1)
    end
  end,
})

shengjianchujue:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
    return data.from and data.from:getMark("@shengjian") > 0 and player:hasSkill(self.name)
  end,
  on_use = function(self, event, target, player, data)
    local from = data.from
    if from == nil then return false end
    local shengjianCount = from:getMark("@shengjian")
    data.damage = data.damage + shengjianCount
  end,
})

shengjianchujue:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return data.to and data.to:getMark("@chujue") > 0 and player and player:hasSkill(self.name)
  end,
  on_use = function(self, event, target, player, data)
    local to = data.to
    local chujueCount = to:getMark("@chujue")
    data.damage = data.damage + chujueCount
  end,
})

return shengjianchujue
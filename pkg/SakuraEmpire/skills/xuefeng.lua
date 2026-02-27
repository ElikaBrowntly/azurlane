local xuefeng = fk.CreateSkill {
  name = "yyfy_xuefeng",
  tags = { Skill.Compulsory }
}

Fk:loadTranslationTable {
  ["yyfy_xuefeng"] = "雪风",
  [":yyfy_xuefeng"] = "锁定技，游戏开始时，你选择至多3名其他角色，这些角色本局游戏受到的伤害-1；"..
  "每局游戏限1次，这些角色中有人体力值降到1以下时，你可以令其回复至2点体力。" ,

  ["@@yyfy_xuefeng"] = "雪风之佑",
  ["#yyfy_xuefeng"] = "雪风：是否要令%dest回复1点体力？",
  ["$yyfy_xuefeng1"] = "你能平安无事也是多亏了我的幸运，快感谢我吧！",
  ["$yyfy_xuefeng2"] = "注意到雪风大人的伟大了吗？眼光不错嘛"
}

xuefeng:addEffect(fk.GameStart, {
  anim_type = "support",
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      targets = room:getOtherPlayers(player, false, false),
      min_num = 0,
      max_num = 3,
      skill_name = xuefeng.name,
      prompt = "雪风：请选择至多3名角色，这些角色受到的伤害-1",
      cancelable = true
    })
    if #tos == 0 then return end
    for _, to in ipairs(tos) do
      room:setPlayerMark(to, "@@yyfy_xuefeng", 1)
    end
  end
})

xuefeng:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self) and target and target:getMark("@@yyfy_xuefeng") > 0
  end,
  on_use = function (self, event, target, player, data)
    data.damage = data.damage - 1
  end
})

xuefeng:addEffect(fk.HpChanged, {
  anim_type = "big",
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self) and target and target:getMark("@@yyfy_xuefeng") > 0
    and target.hp <= 1 and player.tag[xuefeng.name] == nil and data.num < 0
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xuefeng.name,
      prompt = "#yyfy_xuefeng::"..target.id
    })
  end,
  on_use = function (self, event, target, player, data)
    player.room:recover({
      who = target,
      num = 2 - target.hp,
      recoverBy = player,
      skillName = xuefeng.name
    })
    player.tag[xuefeng.name] = true
  end
})

return xuefeng
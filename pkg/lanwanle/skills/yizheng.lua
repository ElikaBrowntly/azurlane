local yizheng = fk.CreateSkill {
  name = "lan__yizheng",
}

Fk:loadTranslationTable{
  ["lan__yizheng"] = "翊正",
  [":lan__yizheng"] = "结束阶段，你可以选择一名角色。直到你的下回合开始，当该角色造成伤害或回复体力时，此伤害或回复值+1。",

  ["@@lan__yizheng"] = "翊正",
  ["#lan__yizheng-choose"] = "翊正：你可以指定一名角色，直到你下回合开始，其造成伤害/回复体力时数值+1",

  ["$lan__yizheng1"] = "玉树盈阶，望子成龙！",
  ["$lan__yizheng2"] = "择善者，翊赞季兴。",
}

yizheng:addLoseEffect(function (self, player, is_death)
  local room = player.room
  if player:getMark(yizheng.name) ~= 0 then
    local to = room:getPlayerById(player:getMark(yizheng.name))
    room:removeTableMark(to, "@@lan__yizheng", player.id)
  end
end)

yizheng:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yizheng.name) and player.phase == Player.Finish and
      #player.room:getAlivePlayers(false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      targets = room:getAlivePlayers(false),
      min_num = 1,
      max_num = 1,
      prompt = "#lan__yizheng-choose",
      skill_name = yizheng.name,
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    room:addTableMarkIfNeed(to, "@@lan__yizheng", player.id)
    room:setPlayerMark(player, yizheng.name, to.id)
  end
})

yizheng:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target and player:getMark(yizheng.name) == target.id
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = {target}})
    return true
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(1)
  end
})

yizheng:addEffect(fk.PreHpRecover, {
  anim_type = "support",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark(yizheng.name) == target.id
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = {target}})
    return true
  end,
  on_use = function(self, event, target, player, data)
    data:changeRecover(1)
  end
})

yizheng:addEffect(fk.TurnStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark(yizheng.name) ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(player:getMark(yizheng.name))
    room:setPlayerMark(player, yizheng.name, 0)
    room:removeTableMark(to, "@@lan__yizheng", player.id)
  end
})

return yizheng
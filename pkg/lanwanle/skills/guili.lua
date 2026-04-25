local guili = fk.CreateSkill {
  name = "lan__guili",
  tags = { Skill.Compulsory }
}

Fk:loadTranslationTable {
  ["lan__guili"] = "归离",
  [":lan__guili"] = "锁定技，获得此技能时，你选择一名其他角色。该角色的回合结束时，你执行一个额外的回合。",

  ["#lan__guili-choose"] = "归离：选择一名角色，其回合结束时，你执行额外回合",
  ["@@lan__guili"] = "归离",

  ["$lan__guili1"] = "既离厄海，当归泸沽。",
  ["$lan__guili2"] = "山野如春，不如归去。",
}

guili:addAcquireEffect(function(self, player, is_start, src)
  if #player.room:getOtherPlayers(player) == 0 then return end
  local room = player.room
  local to = room:askToChoosePlayers(player, {
    min_num = 1,
    max_num = 1,
    targets = room:getOtherPlayers(player, false),
    prompt = "#lan__guili-choose",
    skill_name = guili.name,
    cancelable = false,
  })[1]
  room:setPlayerMark(player, guili.name, to.id)
  room:addTableMark(to, "@@lan__guili", player.id)
end)

guili:addEffect(fk.TurnEnd, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(guili.name) and player:getMark(guili.name) == target.id
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:gainAnExtraTurn(true)
  end,
})

guili:addLoseEffect(function(self, player, is_death)
  local room = player.room
  for _, p in ipairs(room.alive_players) do
    room:removeTableMark(p, "@@lan__guili", player.id)
  end
end)

return guili
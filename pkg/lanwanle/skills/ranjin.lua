local ranjin = fk.CreateSkill {
  name = "lan__ranjin"
}

Fk:loadTranslationTable {
  ["lan__ranjin"] = "燃尽",
  [":lan__ranjin"] = "你的额外回合结束时，若你在该回合内杀死了其他角色，你可以再次发动〖<a href=':lan__huitian'>回天</a>〗；" ..
      "若你累计X个额外回合没有杀死过其他角色，则你死亡（X为本局游戏人数）。",
  ["@lan__ranji"] = "燃尽",

  ["$lan__ranji1"] = "何方后人评说，维自……无愧苍生。",
  ["$lan__ranji2"] = "山河依在，碧血……长流。"
}

ranjin:addEffect(fk.TurnEnd, {
  mute = true,
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and not player.dead and player:hasSkill(ranjin.name) and
        player:getCurrentExtraTurnReason() ~= "game_rule"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if #room.logic:getEventsOfScope(GameEvent.Death, 1, function(e)
          return e.data.killer == player and e.data.who ~= player
        end, Player.HistoryTurn) == 0
    then
      player:broadcastSkillInvoke(ranjin.name, 2)
      room:addPlayerMark(player, "@lan__ranji")
      if player:getMark("@lan__ranji") >= #room:getAllPlayers(false) then
        room:killPlayer({ who = player })
      end
      return
    end
    player:broadcastSkillInvoke(ranjin.name, 1)
    player:clearSkillHistory("lan__huitian")
  end,
})

return ranjin
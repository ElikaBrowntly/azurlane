local yyfy_xiongxi = fk.CreateSkill{
  name = "yyfy_xiongxi",
  anim_type = "offensive",
  tags = {Skill.Limited},
}

Fk:loadTranslationTable{
  ["yyfy_xiongxi"] = "凶袭",
  [":yyfy_xiongxi"] = "限定技，出牌阶段，你可选择一名角色，对其造成1点伤害，然后摸三张牌，"..
  "本回合你对其使用牌无距离次数限制且无视防具。",
  ["$yyfy_xiongxi1"] = "此战虽凶，得益颇高。",
  ["$yyfy_xiongxi2"] = "谋算计策，吾二人尚有险招。",
  ["#yyfy_xiongxi-invoke"] = "凶袭：请选择一名角色",
  ["@@yyfy_xiongxi_target"] = "被凶袭",
}

yyfy_xiongxi:addEffect("active", {
  prompt = "#yyfy_xiongxi-invoke",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  card_num = 0,
  target_num = 1,
  target_filter = function(self, player, to_select)
    return true
  end,
  on_use = function (self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    
    room:damage{
      from = player,
      to = target,
      damage = 1,
      skillName = yyfy_xiongxi.name,
    }
    
    player:drawCards(3, yyfy_xiongxi.name)
    
    room:setPlayerMark(target, "@@yyfy_xiongxi_target", 1)
    room:setPlayerMark(target, "yyfy_xiongxi_source", player.id)
  end,
})

yyfy_xiongxi:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return to and to:getMark("@@yyfy_xiongxi_target") > 0 and to:getMark("yyfy_xiongxi_source") == player.id
  end,
  bypass_distances = function(self, player, skill, card, to)
    return to and to:getMark("@@yyfy_xiongxi_target") > 0 and to:getMark("yyfy_xiongxi_source") == player.id
  end,
  ignore_armor = function(self, player, card, to)
    return to and to:getMark("@@yyfy_xiongxi_target") > 0 and to:getMark("yyfy_xiongxi_source") == player.id
  end,
})

yyfy_xiongxi:addEffect(fk.TurnEnd, {
  mute = true,
  on_cost = function(self, event, target, player, data)
    for _, p in ipairs(player.room.alive_players) do
      if p:getMark("yyfy_xiongxi_source") == player.id then
        return true
      end
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      if p:getMark("yyfy_xiongxi_source") == player.id then
        room:setPlayerMark(p, "@@yyfy_xiongxi_target", 0)
        room:setPlayerMark(p, "yyfy_xiongxi_source", 0)
      end
    end
  end,
})

return yyfy_xiongxi
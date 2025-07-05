local zhihuizhuangtian = fk.CreateSkill{
  name = "zhihuizhuangtian",
  anim_type = "support",
}

Fk:loadTranslationTable({
  ["zhihuizhuangtian"] = "指挥装填",
  [":zhihuizhuangtian"] = "每轮开始时，你可以令至多三名角色本轮以下项数值+1：1.摸牌阶段摸牌数；2.出牌阶段使用杀的次数上限。",
  
  ["#zhihuizhuangtian-choose"] = "指挥装填：请选择至多三名角色",
  ["@zhihuizhuangtian_draw"] = "摸牌+",
  ["@zhihuizhuangtian_slash"] = "杀+",
  
  ["$zhihuizhuangtian1"] = "独角兽…这次有帮上哥哥的忙吗？",
  ["$zhihuizhuangtian2"] = "独角兽，帮上哥哥了呢…欸嘿嘿~",
})

local draw_effect = fk.CreateSkill{
  name = "#zhihuizhuangtian_draw_effect",
  status_skill = true,
  global = true,
}

draw_effect:addEffect(fk.DrawNCards, {
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@zhihuizhuangtian_draw") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.n = data.n + 1
    player.room:removePlayerMark(player, "@zhihuizhuangtian_draw")
    player.room:notifySkillInvoked(player, "zhihuizhuangtian")
    player:broadcastSkillInvoke("zhihuizhuangtian")
  end,
})

local slash_effect = fk.CreateSkill{
  name = "#zhihuizhuangtian_slash_effect",
  status_skill = true,
  global = true,
}

slash_effect:addEffect("targetmod", {
  times = function(self, player, skill, scope, card)
    if player:getMark("@zhihuizhuangtian_slash") > 0 and
       scope == Player.HistoryPhase and
       skill.trueName == "slash_skill" then
      return 1
    end
  end,
})

local remove_mark_effect = fk.CreateSkill{
  name = "#zhihuizhuangtian_remove_mark",
  status_skill = true,
  global = true,
}

remove_mark_effect:addEffect(fk.EventPhaseEnd, {
  can_trigger = function(self, event, target, player, data)
    return player.phase == Player.Play and
           player:getMark("@zhihuizhuangtian_slash") > 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:removePlayerMark(player, "@zhihuizhuangtian_slash")
  end,
})

zhihuizhuangtian:addEffect(fk.RoundStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = room:getAlivePlayers()
    local to = room:askToChoosePlayers(player,{
      targets=targets,
      min_num=0,
      max_num=3, 
      skill_name=zhihuizhuangtian.name,
      prompt="#zhihuizhuangtian-choose", 
      cancelable=true})
    if #to > 0 then
      room:notifySkillInvoked(player, self.name)
      for _, targetPlayer in ipairs(to) do
        room:addPlayerMark(targetPlayer, "@zhihuizhuangtian_draw", 1)
       room:addPlayerMark(targetPlayer, "@zhihuizhuangtian_slash", 1)
      end
    end
  end
})

return zhihuizhuangtian
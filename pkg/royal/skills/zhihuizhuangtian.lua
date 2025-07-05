local zhihuizhuangtian = fk.CreateSkill{
  name = "zhihuizhuangtian",
  anim_type = "support",
}

Fk:loadTranslationTable({
  ["zhihuizhuangtian"] = "指挥装填",
  [":zhihuizhuangtian"] = "每轮开始时，你可以令至多三名角色本轮以下项数值+1：1.摸牌阶段摸牌数；2.出牌阶段使用杀的次数上限。",
  
  ["#zhihuizhuangtian-choose"] = "指挥装填：请选择至多三名角色",
  ["@zhihuizhuangtian_draw-round"] = "摸牌+ ",
  ["@zhihuizhuangtian_slash-round"] = "杀+ ",
  ["#AddMark"] = "%to 获得了「%arg2」效果（来自 %arg）",
  
  ["$zhihuizhuangtian1"] = "独角兽…这次有帮上哥哥的忙吗？",
  ["$zhihuizhuangtian2"] = "独角兽，帮上哥哥了呢…欸嘿嘿~",
  
  ["#zhihuizhuangtian-draw"] = "%from 的「指挥装填」效果触发，额外摸 %arg 张牌",
  ["#zhihuizhuangtian-slash"] = "%from 的「指挥装填」效果触发，出杀次数上限增加 %arg",
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
      prompt="#zhihuizhuangtian-choose", 
      skill_name=self.name, 
      cancelable=true}
    )
    if #to > 0 then
      room:notifySkillInvoked(player, self.name)
      player:broadcastSkillInvoke(self.name)
    
      for _, targetPlayer in ipairs(to) do
        room:addPlayerMark(targetPlayer, "@zhihuizhuangtian_draw-round", 1)
        room:addPlayerMark(targetPlayer, "@zhihuizhuangtian_slash-round", 1)
      end
      return false
    end
  end 
})

-- 摸牌
zhihuizhuangtian:addEffect(fk.DrawNCards, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@zhihuizhuangtian_draw-round") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local bonus = player:getMark("@zhihuizhuangtian_draw-round")
    data.n = data.n + bonus
    
    player.room:sendLog{
      type = "#zhihuizhuangtian-draw",
      from = player.id,
      arg = bonus,
    }
  end,
})

-- 杀
zhihuizhuangtian:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope)
    if skill.trueName == "slash_skill" and 
       player:getMark("@zhihuizhuangtian_slash-round") ~= 0 and 
       scope == Player.HistoryPhase then
      return player:getMark("@zhihuizhuangtian_slash-round")
    end
  end,
  on_refresh = function(self, player, skill, scope)
    if skill.trueName == "slash_skill" and 
       player:getMark("@zhihuizhuangtian_slash-round") ~= 0 and 
       scope == Player.HistoryPhase then
      local bonus = player:getMark("@zhihuizhuangtian_slash-round")
      
      player.room:sendLog{
        type = "#zhihuizhuangtian-slash",
        from = player.id,
        arg = bonus,
      }
    end
  end,
})

return zhihuizhuangtian
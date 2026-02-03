local zhaxiang = fk.CreateSkill{
  name = "lan__zhaxiang",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["lan__zhaxiang"] = "诈降",
  [":lan__zhaxiang"] = "锁定技，摸牌阶段，你多摸已损体力值数张牌。每当你失去1点体力后，你摸三张牌，然后此出牌阶段内"
  .."（若此时不为出牌阶段，则改为下个出牌阶段）你使用【杀】次数上限+1、使用红色【杀】无距离限制且不可被响应。",

  ["@lan__zhaxiang-phase"] = "诈降",
  ["@lan__zhaxiang-delay"] = "诈降",

  ["$lan__zhaxiang1"] = "铁锁连舟而行，东吴水师可破！",
  ["$lan__zhaxiang2"] = "两军阵前，不斩降将！",
  ["$lan__zhaxiang3"] = "江东六郡之卒，怎敌丞相百万雄师！",
  ["$lan__zhaxiang4"] = "闻丞相虚心纳士，盖愿率众归降！",
}

zhaxiang:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player:isWounded()
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n + player:getLostHp()
  end,
})

zhaxiang:addEffect(fk.HpLost, {
  anim_type = "drawcard",
  trigger_times = function(self, event, target, player, data)
    return data.num
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(3, self.name)
    
    if player.phase == Player.Play then
      -- 当前是出牌阶段，立即生效
      room:setPlayerMark(player, "@lan__zhaxiang-phase", 1)
      room:addPlayerMark(player, MarkEnum.SlashResidue.."-phase")
    else
      -- 不是出牌阶段，设置延迟标记
      room:addPlayerMark(player, "@lan__zhaxiang-delay", 1)
    end
  end,
})

-- 出牌阶段开始时检查延迟标记
zhaxiang:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Play and player:getMark("@lan__zhaxiang-delay") > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local delayCount = player:getMark("@lan__zhaxiang-delay")
    
    -- 应用延迟的效果
    room:setPlayerMark(player, "@lan__zhaxiang-phase", 1)
    room:addPlayerMark(player, MarkEnum.SlashResidue.."-phase", delayCount)
    
    -- 清除延迟标记
    room:setPlayerMark(player, "@lan__zhaxiang-delay", 0)
  end,
})

zhaxiang:addEffect(fk.PreCardUse, {
  can_refresh = function(self, event, target, player, data)
    return player == target and player.phase == Player.Play and
      data.card.trueName == "slash" and data.card.color == Card.Red and
      player:getMark("@lan__zhaxiang-phase") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.disresponsiveList = table.simpleClone(player.room.alive_players)
  end,
})

zhaxiang:addEffect("targetmod", {
  bypass_distances = function(self, player, skill, card)
    return card and card:matchVSPattern("slash|.|red") and player.phase == Player.Play and
      player:getMark("@lan__zhaxiang-phase") > 0
  end,
})

-- 出牌阶段结束时清除标记
zhaxiang:addEffect(fk.EventPhaseEnd, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@lan__zhaxiang-phase", 0)
  end,
})

zhaxiang:addTest(function(room, me)
  FkTest.runInRoom(function()
    room:handleAddLoseSkills(me, zhaxiang.name)
  end)
  FkTest.runInRoom(function()
    room:loseHp(me, 2)
  end)
  lu.assertEquals(#me:getCardIds("h"), 6)
end)

return zhaxiang
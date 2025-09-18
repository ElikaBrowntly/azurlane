local yijin = fk.CreateSkill {
  name = "lan__yijin",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["lan__yijin"] = "亿金",
  [":lan__yijin"] = "锁定技，游戏开始时，你获得6枚“金”标记；出牌阶段结束时，若你没有“金”，"..
  "你可以弃置至多6张手牌并获得等量“金”。出牌阶段开始时，你令一名没有“金”的其他角色获得一枚“金”"..
  "和对应的效果直到其下回合结束：<br><font color='red'>膴士</font>：摸牌阶段摸牌数+4、"..
  "出牌阶段使用【杀】次数上限+1；<br><font color='orange'>厚任</font>：回合结束时回复3点体力；"..
  "<br><font color='green'>贾凶</font>：出牌阶段开始时失去1点体力，本回合手牌上限-3；<br>"..
  "<font color='cyan'>拥蔽</font>：跳过摸牌阶段；<br><font color='blue'>通神</font>："..
  "防止受到的非雷电伤害；<br><font color='purple'>金迷</font>：跳过出牌阶段和弃牌阶段。",

  ["@[:]lan__yijin_owner"] = "亿金",
  ["@[:]lan__yijin"] = "",
  ["#lan__yijin-choose"] = "亿金：将一种“金”交给一名其他角色",
  ["#lan__yijin-discard"] = "亿金：你可以弃置至多6张手牌并获得等量“金”",
  ["#lan__yijin-choose-gold"] = "亿金：请选择%arg种“金”",
  ["@$lan__yijin"] = "金",
  ["lan__yijin_wushi"] = "膴士",
  [":lan__yijin_wushi"] = "摸牌阶段摸牌数+4、出牌阶段使用【杀】次数+1",
  ["lan__yijin_houren"] = "厚任",
  [":lan__yijin_houren"] = "回合结束时回复3点体力",
  ["lan__yijin_guxiong"] = "贾凶",
  [":lan__yijin_guxiong"] = "出牌阶段开始时失去1点体力，手牌上限-3",
  ["lan__yijin_yongbi"] = "拥蔽",
  [":lan__yijin_yongbi"] = "跳过摸牌阶段",
  ["lan__yijin_tongshen"] = "通神",
  [":lan__yijin_tongshen"] = "防止受到的非雷电伤害",
  ["lan__yijin_jinmi"] = "金迷",
  [":lan__yijin_jinmi"] = "跳过出牌阶段和弃牌阶段",

  ["$lan__yijin1"] = "吾家资巨万，无惜此两贯三钱！",
  ["$lan__yijin2"] = "小儿持金过闹市，哼！杀人何需我多劳！",
  ["$lan__yijin3"] = "普天之下，竟有吾难市之职？",
}

yijin:addEffect(fk.GameStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(yijin.name)
  end,
  on_use = function(self, event, target, player, data)
    ---@type string
    local skillName = yijin.name
    local room = player.room
    player:broadcastSkillInvoke(skillName, 1)
    room:notifySkillInvoked(player, skillName, "special")

    local golds = {
      "lan__yijin_wushi",
      "lan__yijin_houren",
      "lan__yijin_guxiong",
      "lan__yijin_yongbi",
      "lan__yijin_tongshen",
      "lan__yijin_jinmi",
    }
    room:setPlayerMark(player, "@[:]lan__yijin_owner", golds)
  end,
})

-- 添加出牌阶段结束时获得金的效果
yijin:addEffect(fk.EventPhaseEnd, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Play and
           #player:getTableMark("@[:]lan__yijin_owner") == 0 and
           not player:isKongcheng() and player:hasSkill(self.name)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    return room:askToSkillInvoke(player, {
      skill_name = yijin.name,
      prompt = "#lan__yijin-discard",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    -- 让玩家选择弃置的手牌
    local discardNum = math.min(6, #player:getCardIds("h"))
    local cards = room:askToDiscard(player, {
      min_num = 1,  -- 至少弃置1张牌
      max_num = discardNum,
      include_equip = false,
      skill_name = yijin.name,
      prompt = "#lan__yijin-discard",
      cancelable = false,
    })
    -- 让玩家选择要获得的金类型
    local goldTypes = {
      "lan__yijin_wushi",
      "lan__yijin_houren", 
      "lan__yijin_guxiong",
      "lan__yijin_yongbi",
      "lan__yijin_tongshen",
      "lan__yijin_jinmi",
    }
    
    local selected = room:askToChoices(player, {
      choices = goldTypes,
      skill_name = self.name,
      min_num = #cards,
      max_num = #cards,
      prompt = "#lan__yijin-choose-gold:::" .. #cards,
      detailed = true,  -- 显示详细描述
    })
    -- 获得选择的金
    if #selected > 0 then
      room:setPlayerMark(player, "@[:]lan__yijin_owner", selected)
      
      -- 播放音效
      player:broadcastSkillInvoke(self.name, 1)
      room:notifySkillInvoked(player, self.name, "support")
    end
  end,
})

-- 以下保持原有的其他效果不变
yijin:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and target == player and player.phase == Player.Play and #player:getTableMark("@[:]lan__yijin_owner") > 0
  end,
  on_use = function(self, event, target, player, data)
    ---@type string
    local skillName = self.name
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function(p) return p:getMark("@[:]lan__yijin") == 0 end)

    if #targets == 0 then
      return false
    end
    local confirm, dat = room:askToUseActiveSkill(player, { skill_name = "lan__yijin_active", prompt = "#lan__yijin-choose", cancelable = true })
    if not confirm then return false end
    local to = (dat and #dat.targets > 0) and dat.targets[1] or table.random(targets)
    local mark = player:getMark("@[:]lan__yijin_owner")
    local choice = dat and dat.interaction or table.random(mark)
    table.removeOne(mark, choice)
    room:setPlayerMark(player, "@[:]lan__yijin_owner", mark)
    room:setPlayerMark(to, "@[:]lan__yijin", choice)
    if table.contains({ "lan__yijin_wushi", "lan__yijin_houren", "lan__yijin_tongshen" }, choice) then
      player:broadcastSkillInvoke(skillName, 1)
      room:notifySkillInvoked(player, skillName, "support")
    else
      player:broadcastSkillInvoke(skillName, 2)
      room:notifySkillInvoked(player, skillName, "control")
    end
  end,
})

yijin:addEffect(fk.DrawNCards, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    local mark = player:getMark("@[:]lan__yijin")
    return target == player and mark ~= 0 and mark == "lan__yijin_wushi"
  end,
  on_use = function(self, event, target, player, data)
    ---@type string
    local skillName = yijin.name
    local room = player.room
    local src = table.find(room.alive_players, function(p) return p:hasSkill(skillName, true) end)
    if src then
      src:broadcastSkillInvoke(skillName, 1)
      room:notifySkillInvoked(src, skillName, "support")
    end
    data.n = data.n + 4
  end,
})

yijin:addEffect(fk.EventPhaseChanging, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    local mark = player:getMark("@[:]lan__yijin")
    return
      target == player and
      (
        (data.phase == Player.Draw and mark == "lan__yijin_yongbi") or
        ((data.phase == Player.Play or data.phase == Player.Discard) and mark == "lan__yijin_jinmi")
      )
  end,
  on_use = function(self, event, target, player, data)
    ---@type string
    local skillName = yijin.name
    local room = player.room
    local src = table.find(room.alive_players, function(p) return p:hasSkill(skillName, true) end)
    if src then
      src:broadcastSkillInvoke(skillName, 2)
      room:notifySkillInvoked(src, skillName, "control")
    end
    data.skipped = true
  end,
})

yijin:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    local mark = player:getMark("@[:]lan__yijin")
    return target == player and player:isWounded() and mark == "lan__yijin_houren"
  end,
  on_use = function(self, event, target, player, data)
    ---@type string
    local skillName = yijin.name
    local room = player.room
    local src = table.find(room.alive_players, function(p) return p:hasSkill(skillName, true) end)
    if src then
      src:broadcastSkillInvoke(skillName, 1)
      room:notifySkillInvoked(src, skillName, "support")
    end
    room:recover{
      who = player,
      num = math.min(3, player:getLostHp()),
      recoverBy = player,
      skillName = skillName,
    }
  end,

  late_refresh = true,
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@[:]lan__yijin") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@[:]lan__yijin", 0)
  end,
})

yijin:addEffect(fk.EventPhaseStart, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    local mark = player:getMark("@[:]lan__yijin")
    return target == player and player.phase == Player.Play and mark == "lan__yijin_guxiong"
  end,
  on_use = function(self, event, target, player, data)
    ---@type string
    local skillName = yijin.name
    local room = player.room
    local src = table.find(room.alive_players, function(p) return p:hasSkill(skillName, true) end)
    if src then
      src:broadcastSkillInvoke(skillName, 2)
      room:notifySkillInvoked(src, skillName, "control")
    end
    room:addPlayerMark(player, MarkEnum.MinusMaxCardsInTurn, 3)
    room:loseHp(player, 1, skillName)
  end,
})

yijin:addEffect(fk.DetermineDamageInflicted, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    local mark = player:getMark("@[:]lan__yijin")
    return target == player and data.damageType ~= fk.ThunderDamage and mark == "lan__yijin_tongshen"
  end,
  on_use = function(self, event, target, player, data)
    ---@type string
    local skillName = yijin.name
    local room = player.room
    local src = table.find(room.alive_players, function(p) return p:hasSkill(skillName, true) end)
    if src then
      src:broadcastSkillInvoke(skillName, 1)
      room:notifySkillInvoked(src, skillName, "support")
    end
    data:preventDamage()
  end,
})

yijin:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope)
    if skill.trueName == "slash_skill" and player:getMark("@[:]lan__yijin") == "lan__yijin_wushi" and scope == Player.HistoryPhase then
      return 1
    end
  end,
})


return yijin
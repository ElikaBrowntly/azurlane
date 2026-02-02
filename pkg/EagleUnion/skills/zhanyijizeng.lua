local zhanyijizeng = fk.CreateSkill {
  name = "yyfy_zhanyijizeng",
  tags = { Skill.Compulsory }
}

Fk:loadTranslationTable {
  ["yyfy_zhanyijizeng"] = "战意激增",
  [":yyfy_zhanyijizeng"] = "锁定技，废除你的宝物栏，视为装备着<a href=':yyfy_tutudajizhe'>【兔兔打击者】</a>"
  .."和<a href=':yyfy_sunguan'>【白鹰精英损管】</a>。你使用的【杀】无法被响应，当你造成或受到伤害时，获得一个「战意」标记。",
  
  ["$yyfy_zhanyijizeng1"] = "……总之，要先打败敌人……速战速决……",
  ["$yyfy_zhanyijizeng2"] = "操作完毕，出击……！",

  ["@yyfy_AL_zhanyi"] = "战意",
  ["@@yyfy_tutudajizhe"] = "兔兔打击者",
  ["yyfy_tutudajizhe"] = "兔兔打击者",
  [":yyfy_tutudajizhe"] = "回合开始时，你可以视为使用一张无距离次数限制的【杀】，此杀造成的伤害-1且最低为1。",
  ["@@yyfy_sunguan"] = "白鹰精英损管",
  ["yyfy_sunguan"] = "白鹰精英损管",
  [":yyfy_sunguan"] = "当你死亡时，复活并使你的「战意」标记清0，且「背水之战」的可用次数改为0。之后，此装备失效。",
  ["#yyfy_tutudajizhe-target"] = "兔兔打击者：请选择一名角色作为【杀】的目标",
  ["#yyfy_sunguan_trigger"] = "%from 的「%arg」效果触发，复活并清除了所有标记",
}

-- 监听装备栏恢复事件
zhanyijizeng:addEffect(fk.AreaResumed, {
  mute = true,
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(zhanyijizeng.name) then
      -- 检查恢复的装备栏是否包含宝物栏
      for _, slot in ipairs(data.slots) do
        if slot == Player.TreasureSlot then
          return true
        end
      end
    end
    return false
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    if not table.contains(player.sealedSlots, Player.TreasureSlot) then
      player.room:abortPlayerArea(player, { Player.TreasureSlot })
    end
  end,
})

-- 必中
zhanyijizeng:addEffect(fk.CardUsing, {
  on_cost = function(self, event, target, player, data)
    return player:hasSkill(zhanyijizeng.name) and
           data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    data.disresponsiveList = data.disresponsiveList or {}
    for _, p in ipairs(player.room.alive_players) do
      table.insertIfNeed(data.disresponsiveList, p)
    end
  end,
})

-- 造成伤害时获得战意标记
zhanyijizeng:addEffect(fk.Damage, {
  can_trigger = function (self, event, target, player, data)
    return data.from == player and player:hasSkill(zhanyijizeng.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local currentMark = player:getMark("@yyfy_AL_zhanyi") or 0
    room:setPlayerMark(player, "@yyfy_AL_zhanyi", currentMark + 1)
  end,
})

-- 受到伤害时获得战意标记
zhanyijizeng:addEffect(fk.Damaged, {
  can_trigger = function (self, event, target, player, data)
    return data.to == player and player:hasSkill(zhanyijizeng.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local currentMark = player:getMark("@yyfy_AL_zhanyi") or 0
    room:setPlayerMark(player, "@yyfy_AL_zhanyi", currentMark + 1)
  end,
})

-- 技能获得时处理标记相关技能
zhanyijizeng:addAcquireEffect(function (self, player)
  local room = player.room
  if not table.contains(player.sealedSlots, Player.TreasureSlot) then
    room:abortPlayerArea(player, { Player.TreasureSlot })
  end
    room:setPlayerMark(player, "@@yyfy_tutudajizhe", 1)
    room:setPlayerMark(player, "@@yyfy_sunguan", 1)
    
    if not player:hasSkill("yyfy_tutudajizhe") then
      room:handleAddLoseSkills(player, "yyfy_tutudajizhe", self.name)
    end
    if not player:hasSkill("yyfy_sunguan") then
      room:handleAddLoseSkills(player, "yyfy_sunguan", self.name)
    end
end)

-- 技能失去时移除标记和技能
zhanyijizeng:addLoseEffect(function (self, player, is_death)
  local room = player.room
  room:setPlayerMark(player, "@yyfy_AL_zhanyi", 0)
  room:setPlayerMark(player, "@@yyfy_sunguan", 0)
  room:handleAddLoseSkills(player, "-yyfy_tutudajizhe|-yyfy_sunguan")
end)

return zhanyijizeng
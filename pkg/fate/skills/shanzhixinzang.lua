local yyfy_shanzhixinzang = fk.CreateSkill{
  name = "yyfy_shanzhixinzang",
  anim_type = "support",
}

Fk:loadTranslationTable{
  ["yyfy_shanzhixinzang"] = "山之心脏",
  [":yyfy_shanzhixinzang"] = "出牌阶段限一次，你可以赋予自身<a href=':fate_yili_1*3'>毅力状态</a>"
  .."(1次·3回合)，然后你本回合蓄力技造成的伤害+1。",
  
  [":fate_yili_1*3"] = "<b>「毅力」状态 (1次·3回合):</b><br>进入濒死时，消耗1个此状态将体力值改为1；<br>"..
  "死亡时，消耗1个此状态复活并将体力值改为1。<br>经过3个回合后无论是否使用都会失效。",
  ["@!fate_yili"] = "毅力",
  
  ["#yyfy_shanzhixinzang_prompt"] = "山之心脏：赋予自身毅力状态(1次·3回合)，下一次蓄力技伤害+1",
  ["#yyfy_shanzhixinzang_yili"] = "由于「山之心脏」的「毅力」效果，%from 将体力值改为1",
  ["#yyfy_shanzhixinzang_yili_revive"] = "由于「山之心脏」的「毅力」效果，%from 复活并将体力值改为1",
  ["#yyfy_shanzhixinzang_damage_boost"] = "%from 的「%arg」效果触发，伤害+1",
  
  ["$yyfy_shanzhixinzang1"] = "心脏！　献上闪耀的心脏！",
  ["$yyfy_shanzhixinzang2"] = "呜啊啊啊——！",
  ["$yyfy_shanzhixinzang3"] = "积攒点力量吧。",
  ["$yyfy_shanzhixinzang4"] = "准备顶级的活祭吧。"
}

-- 主动效果：赋予毅力标记和伤害标记
yyfy_shanzhixinzang:addEffect("active", {
  prompt = "#yyfy_shanzhixinzang_prompt",
  card_num = 0,
  max_phase_use_time = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    
    -- 赋予毅力状态(1次·3回合)
    room:addPlayerMark(player, "@!fate_yili", 1)
    room:setPlayerMark(player, "yyfy_shanzhixinzang_yili_turns", 3) -- 剩余3个回合
    
    -- 设置下一次蓄力技伤害+1
    room:setPlayerMark(player, "yyfy_shanzhixinzang_damage-turn", 1)
  end,
})

-- 进入濒死时触发毅力
yyfy_shanzhixinzang:addEffect(fk.EnterDying, {
  can_trigger = function(self, event, target, player, data)
    return target:getMark("@!fate_yili") > 0 and target == player and data.who == player
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = target.room
    
    -- 消耗毅力状态
    room:setPlayerMark(target, "@!fate_yili", 0)
    room:setPlayerMark(target, "yyfy_shanzhixinzang_yili_turns", 0)
    
    -- 将体力值改为1，效仿武诸葛亮
    target.hp = 1
    room:broadcastProperty(target, "hp")
    
    -- 发送日志
    room:sendLog{
      type = "#yyfy_shanzhixinzang_yili",
      from = target.id,
    }
  end,
})

yyfy_shanzhixinzang:addEffect(fk.BeforeGameOverJudge, {
  anim_type = "support",
  priority = 2,
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self, true, true) and target:getMark("@!fate_yili") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:setTag("SkipGameRule", true)
    local skills_snapshot = {}
    room:revivePlayer(player, false)
  end
})

yyfy_shanzhixinzang:addEffect(fk.TurnEnd, {
  mute = true,
  can_refresh = function(self, event, target, player, data)
    -- 检查是否有毅力状态且回合数大于0
    return target:getMark("yyfy_shanzhixinzang_yili_turns") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local remainingTurns = player:getMark("yyfy_shanzhixinzang_yili_turns") - 1
    
    if remainingTurns <= 0 then
      -- 回合数用完，移除毅力状态
      room:setPlayerMark(player, "@!fate_yili", 0)
      room:setPlayerMark(player, "yyfy_shanzhixinzang_yili_turns", 0)
    else
      -- 更新剩余回合数
      room:setPlayerMark(player, "yyfy_shanzhixinzang_yili_turns", remainingTurns)
    end
  end,
})

yyfy_shanzhixinzang:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
    -- 检查是否有伤害加成标记，且造成伤害的技能是蓄力技
    return data.from:getMark("yyfy_shanzhixinzang_damage-turn") > 0 and
           player and player:hasSkill(self.name) and
           data.skillName and Fk.skills[data.skillName] and
           Fk.skills[data.skillName]:hasTag(Skill.Charge)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    -- 伤害+1
    data:changeDamage(1)
    
    -- 发送日志
    room:sendLog{
      type = "#yyfy_shanzhixinzang_damage_boost",
      from = player.id,
      arg = "yyfy_shanzhixinzang",
    }
  end,
})

return yyfy_shanzhixinzang
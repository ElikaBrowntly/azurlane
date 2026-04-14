local yyfy_kongxiangjvxianhua = fk.CreateSkill({
  name = "yyfy_kongxiangjvxianhua",
  tags = { Skill.Charge },
})

Fk:loadTranslationTable{
  ["yyfy_kongxiangjvxianhua"] = "空想具现化",
  [":yyfy_kongxiangjvxianhua"] = "蓄力技（0/30），出牌阶段限一次，你可以消耗10点蓄力点，"..
  "对任意名其他角色造成2点伤害，然后可令任意名有蓄力技的其他角色获得2点蓄力点。",
  
  ["#yyfy_kongxiangjvxianhua-choose"] = "空想具现化：请选择任意名角色",
  ["#yyfy_kongxiangjvxianhua-damage"] = "空想具现化：对 %src 造成 %arg 点伤害",
  ["#yyfy_kongxiangjvxianhua-charge-choose"] = "空想具现化：请令任意名有蓄力技的其他角色各获得2点蓄力点",
  ["yyfy_kongxiangjvxianhua_has_charge"] = "有蓄力技",

  ["$yyfy_kongxiangjvxianhua1"] = "被吾之千锁吞没吧。人智未及，灵峰梦幻。让你见识一下吧，覆盖星辰的华盖！",
  ["$yyfy_kongxiangjvxianhua2"] = "甘心承受吧。故乡遥远，没有道路。这座城，是终焉之牢。——欢迎来到月之城。",
  ["$yyfy_kongxiangjvxianhua3"] = "那就赐予汝等报酬吧。水、热、颤，分别，在吾之手中迸发吧……！"
}

local U = require "packages/utility/utility"

yyfy_kongxiangjvxianhua:addEffect("active", {
  mute = true,
  prompt = "#yyfy_kongxiangjvxianhua-choose",
  anim_type = "big",
  card_num = 0,
  max_phase_use_time = 1,
  can_use = function(self, player)
    return player:getMark("skill_charge") >= 10
  end,
  target_filter = function(self, player, to_select, selected)
    return to_select:isAlive() and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local targets = effect.tos
    
    -- 消耗100点蓄力点
    U.skillCharged(player, -10)
    -- 播放动画和语音
    player:broadcastSkillInvoke(self.name)
    room:doSuperLightBox("packages/hidden-clouds/qml/kongxiangjvxianhua.qml")
    -- 计算基础伤害和额外伤害
    local baseDamage = 2
    local extraDamage = player:getMark("yyfy_xingzhituxi_mark") or 0
    
    -- 造成伤害
    for _, target in ipairs(targets) do
      local totalDamage = baseDamage + extraDamage
      
      room:sendLog{
        type = "#yyfy_kongxiangjvxianhua-damage",
        from = player.id,
        to = {target.id},
        arg = totalDamage,
      }
      
      room:damage{
        from = player,
        to = target,
        damage = totalDamage,
        damageType = fk.NormalDamage,
        skillName = self.name,
      }
    end
    
    -- 清除星之吐息标记
    if extraDamage > 0 then
      room:setPlayerMark(player, "yyfy_xingzhituxi_mark", 0)
    end
    
    -- 获得2点蓄力点
    local availableTargets = table.filter(room:getOtherPlayers(player), function(p)
      if table.find(p:getSkillNameList(), function(s) return Fk.skills[s]:hasTag(Skill.Charge) end)
      then return true end
    end)
    
    if #availableTargets > 0 then
      local chargeTargets = room:askToChoosePlayers(player, {
        targets = availableTargets,
        min_num = 0,
        max_num = #availableTargets,
        prompt = "#yyfy_kongxiangjvxianhua-charge-choose",
        skill_name = self.name,
        cancelable = true,
        target_tip_name = "yyfy_kongxiangjvxianhua",
      })
      
      if #chargeTargets > 0 then
        for _, p in ipairs(chargeTargets) do
          U.skillCharged(p, 2)
        end
      end
    end
  end,
})

-- 技能获得时初始化蓄力点
yyfy_kongxiangjvxianhua:addAcquireEffect(function (self, player)
  U.skillCharged(player, 0, 30)
end)

-- 技能失去时移除蓄力点
yyfy_kongxiangjvxianhua:addLoseEffect(function (self, player)
  U.skillCharged(player, 0, -30)
end)

-- 目标提示：显示哪些角色有蓄力技
Fk:addTargetTip{
  name = "yyfy_kongxiangjvxianhua",
  target_tip = function(_, _, to_select)
    if table.find(to_select:getSkillNameList(), function(s)
      return Fk.skills[s]:hasTag(Skill.Charge)
    end) then
      return "yyfy_kongxiangjvxianhua_has_charge"
    end
  end,
}

return yyfy_kongxiangjvxianhua
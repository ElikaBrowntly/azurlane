local diyitaiyang = fk.CreateSkill{
  name = "fate_diyitaiyang",
  anim_type = "big",
  tags = { Skill.Charge },
}

Fk:loadTranslationTable{
  ["fate_diyitaiyang"] = "第一太阳",
  [":fate_diyitaiyang"] = "蓄力技（0/30），出牌阶段限一次，你可以消耗10点蓄力点，"..
  "赋予自身<a href=':fate_diyitaiyang_difference'>无敌贯通</a>状态，"..
  "并对任意名其他角色各造成2点伤害。然后，你令任意名有蓄力技的角色各获得1点蓄力点。",

  [":fate_diyitaiyang_difference"] = "<b>无敌贯通：</b><br>令其他角色本回合内受到你的伤害时改为失去体力。"
  .."<br>该描述与<b>绝情:你造成的伤害均视为失去体力</b>的区别在于时机更晚。<br>"
  .."〖绝情〗的描述既无法享受造成伤害时的加伤，也无法享受对方受到伤害时的加伤；而本描述可以享受造成伤害时的加伤，"
  .."仅无法享受对方受到伤害时的加伤。<br>其实该描述在官方武将中出现过，比如ol审配",
  ["@@fate_wudiguantong-turn"] = "无敌贯通",
  ["$fate_diyitaiyang1"] = "风啊，风啊。夜之风啊，奴役吾等之人。灭亡之时已至。——去往下一个世界吧。别相·山之心脏。",
  ["$fate_diyitaiyang2"] = "只要是冥界就都一样。九个地下世界，十二之恐怖在太阳之下被统一。黑之特斯卡特利波卡……"
}

local U = require "packages/utility/utility"

diyitaiyang:addEffect("active", {
  mute = true,
  prompt = "第一太阳：你可以对任意名其他角色各造成2点伤害",
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
    
    -- 消耗10点蓄力点
    U.skillCharged(player, -10)
    room:addPlayerMark(player, "@@fate_wudiguantong-turn")
    -- 随机播放动画和语音，但要配套
    local order = math.random(2)
    player:broadcastSkillInvoke(self.name, order)
    room:doSuperLightBox("packages/hidden-clouds/qml/diyitaiyang"..tostring(order)..".qml")
    
    -- 造成伤害
    for _, target in ipairs(targets) do
      room:damage{
        from = player,
        to = target,
        damage = 2,
        damageType = fk.NormalDamage,
        skillName = self.name,
      }
    end
    
    -- 获得1点蓄力点
    local availableTargets = table.filter(room:getOtherPlayers(player), function(p)
      if table.find(p:getSkillNameList(), function(s) return Fk.skills[s]:hasTag(Skill.Charge) end)
      then return true end
    end)
    
    if #availableTargets > 0 then
      local chargeTargets = room:askToChoosePlayers(player, {
        targets = availableTargets,
        min_num = 0,
        max_num = #availableTargets,
        prompt = "请为任意名有蓄力技的角色增加1点蓄力点",
        skill_name = self.name,
        cancelable = true,
        target_tip_name = "fate_kongxiangjvxianhua",
      })
      
      if #chargeTargets > 0 then
        for _, p in ipairs(chargeTargets) do
          U.skillCharged(p, 1)
        end
      end
    end
  end,
})

-- 技能获得时初始化蓄力点
diyitaiyang:addAcquireEffect(function (self, player)
  U.skillCharged(player, 0, 30)
end)

-- 技能失去时移除蓄力点
diyitaiyang:addLoseEffect(function (self, player)
  U.skillCharged(player, 0, -30)
end)

diyitaiyang:addEffect(fk.DamageInflicted, {
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self.name)
    and data.from == player and player:getMark("@@fate_wudiguantong-turn") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:loseHp(data.to, data.damage, self.name)
    data:preventDamage()
  end
})

return diyitaiyang
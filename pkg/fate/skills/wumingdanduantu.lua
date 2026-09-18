local wumingsanduantu = fk.CreateSkill {
  name = "yyfy_wumingsanduantu",
  anim_type = "big",
  tags = { Skill.Charge },
}

Fk:loadTranslationTable {
  ["yyfy_wumingsanduantu"] = "无明三段突",
  [":yyfy_wumingsanduantu"] = "蓄力技（0/30），出牌阶段限一次，你可以消耗10点蓄力点，" ..
      "对一名其他角色造成4点伤害，并令其在接下来3回合内防御力降低50%。",

  ["@!yyfy_wumingsanduantu"] = "防御力降低50%",
  ["$yyfy_wumingsanduantu1"] = "风啊，风啊。夜之风啊，奴役吾等之人。灭亡之时已至。——去往下一个世界吧。别相·山之心脏。",
  ["$yyfy_wumingsanduantu2"] = "只要是冥界就都一样。九个地下世界，十二之恐怖在太阳之下被统一。黑之特斯卡特利波卡……"
}

local U = require "packages/utility/utility"
local F = require("packages.hidden-clouds.functions")

wumingsanduantu:addEffect("active", {
  mute = true,
  prompt = "无明三段突：对一名其他角色造成4点伤害，并降低其防御力",
  card_num = 0,
  max_phase_use_time = 1,
  can_use = function(self, player)
    return player:getMark("skill_charge") >= 10
  end,
  target_num = 1,
  target_filter = function(self, player, to_select, selected)
    return to_select:isAlive() and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    U.skillCharged(player, -10)
    -- 根据皮肤播放动画和语音，要配套
    -- local order = 1
    -- if F.setEmotion(player, "yyfy_Tezcatlipoca__2", diyitaiyang.name, 0, "", true)
    -- or F.setEmotion(player, "yyfy_Tezcatlipoca__3", diyitaiyang.name, 0, "", true) then
    --   order = 2
    -- end
    -- player:broadcastSkillInvoke(self.name, order)
    -- room:doSuperLightBox("packages/hidden-clouds/qml/diyitaiyang"..tostring(order)..".qml")
    room:damage {
      from = player,
      to = target,
      damage = 4,
      damageType = fk.NormalDamage,
      skillName = wumingsanduantu.name,
    }
    room:setPlayerMark(target, "@!yyfy_wumingsanduantu", 3)
  end
})

wumingsanduantu:addEffect(fk.DamageInflicted, {
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self) and target and target:getMark("@!yyfy_wumingsanduantu") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    data:changeDamage(math.floor(data.damage / 2))
  end
})

wumingsanduantu:addEffect(fk.TurnEnd, {
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self) and table.find(player.room:getAlivePlayers(false), function (t)
      return t:getMark("@!yyfy_wumingsanduantu") > 0
    end)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local targets = table.filter(player.room:getAlivePlayers(false), function (t)
      return t:getMark("@!yyfy_wumingsanduantu") > 0
    end)
    for _, t in ipairs(targets) do
      player.room:addPlayerMark(t, "@!yyfy_wumingsanduantu", -1)
    end
  end
})

return wumingsanduantu
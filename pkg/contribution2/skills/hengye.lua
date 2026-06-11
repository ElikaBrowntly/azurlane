local hengye = fk.CreateSkill {
  name = "yyfy_hengye",
  tags = { Skill.Compulsory }
}

Fk:loadTranslationTable {
  ["yyfy_hengye"] = "横野",
  [":yyfy_hengye"] = "锁定技，你造成1点伤害后，本局游戏以下数值+1：<br>" ..
      "①摸牌阶段摸牌数；<br>②出牌阶段使用【杀】的次数；<br>③攻击范围；<br>④手牌上限。",

  ["@yyfy_hengye"] = "横野",

  ["$yyfy_hengye1"] = "负剑觅烽火，狼烟既起战不休！",
  ["$yyfy_hengye2"] = "吴戈漫野，饮马处岂唯长江！",
}

hengye:addLoseEffect(function(self, player, is_death)
  player.room:setPlayerMark(player, "@" .. hengye.name, 0)
end)

hengye:addEffect(fk.Damage, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  trigger_times = function (self, event, target, player, data)
    return data.damage
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@" .. hengye.name)
  end,
})

--2V2模式1号位不会少摸牌；可以受怀橘、劫营、督粮影响再多摸牌
--FIXME: 线上貌似是能直接在摸牌阶段开始时修改摸牌数的，这里姑且使用refresh来处理
hengye:addEffect(fk.DrawNCards, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@" .. hengye.name) > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.n = data.n + player:getMark("@" .. hengye.name)
  end,
})

hengye:addEffect(fk.EventPhaseStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
        player.phase == Player.Play and player:getMark("@" .. hengye.name) > 0
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:addPlayerMark(player, MarkEnum.SlashResidue .. "-phase", player:getMark("@" .. hengye.name))
  end
})

hengye:addEffect("atkrange", {
  correct_func = function (self, player)
    return player:getMark("@" .. hengye.name)
  end
})

hengye:addEffect("maxcards", {
  correct_func = function (self, player)
    return player:getMark("@" .. hengye.name)
  end
})

return hengye
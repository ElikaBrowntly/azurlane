local xingzhituxi = fk.CreateSkill{
  name = "yyfy_xingzhituxi",
  anim_type = "drawcard",
  limit_mark = "@yyfy_xingzhituxi_used-turn",
}

Fk:loadTranslationTable{
  ["yyfy_xingzhituxi"] = "星之吐息",
  [":yyfy_xingzhituxi"] = "出牌阶段限一次，你可以获得10点蓄力点，并令下一次〖空想具象化〗造成的伤害+1。",
  
  ["#yyfy_xingzhituxi-use"] = "星之吐息：是否获得10点蓄力点？",

  ["$yyfy_xingzhituxi1"] = "光体，抑制——",
  ["$yyfy_xingzhituxi2"] = "为了遏止这焦急的心情。",
  ["$yyfy_xingzhituxi3"] = "……啊啊，这是多么的……",
}

local U = require "packages/utility/utility"

xingzhituxi:addEffect("active", {
  card_num = 0,
  anim_type = "drawcard",
  prompt = "#yyfy_xingzhituxi-use",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    
    -- 获得10点蓄力点
    U.skillCharged(player, 10)
    
    -- 获得一个不可见的标记，用于宝具增伤计算
    room:setPlayerMark(player, "yyfy_xingzhituxi_mark", 1)
  end,
})

return xingzhituxi
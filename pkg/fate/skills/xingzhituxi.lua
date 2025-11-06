local xingzhituxi = fk.CreateSkill{
  name = "fate_xingzhituxi",
  anim_type = "drawcard",
  limit_mark = "@fate_xingzhituxi_used-turn",
}

Fk:loadTranslationTable{
  ["fate_xingzhituxi"] = "星之吐息",
  [":fate_xingzhituxi"] = "出牌阶段限一次，你可以获得1点蓄力点，并令下一次〖空想具象化〗造成的伤害+1。",
  
  ["#fate_xingzhituxi-use"] = "星之吐息：是否获得1点蓄力点？",

  ["$fate_xingzhituxi1"] = "光体，抑制——",
  ["$fate_xingzhituxi2"] = "为了遏止这焦急的心情。",
  ["$fate_xingzhituxi3"] = "……啊啊，这是多么的……",
}

local U = require "packages/utility/utility"

xingzhituxi:addEffect("active", {
  card_num = 0,
  anim_type = "drawcard",
  prompt = "#fate_xingzhituxi-use",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    
    -- 获得1点蓄力点
    U.skillCharged(player, 1)
    
    -- 获得一个不可见的标记，用于宝具增伤计算
    room:setPlayerMark(player, "fate_xingzhituxi_mark", 1)
  end,
})

return xingzhituxi
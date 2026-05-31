local fengzhu = fk.CreateSkill{
  name = "lan__fengzhu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["lan__fengzhu"] = "逢主",
  [":lan__fengzhu"] = "锁定技，游戏开始时，你拜所有人为“义父”，摸三倍游戏人数张牌。",
  ["@@lan__fengzhu_father"] = "义父",

  ["$lan__fengzhu"] = "吕布飘零半生，只恨未逢明主，公若不弃，布愿拜为义父！",
}

fengzhu:addLoseEffect(function (self, player, is_death)
  local room = player.room
  for _, p in ipairs(room:getAlivePlayers()) do
    if p:getMark("@@lan__fengzhu_father") > 0 then
      room:setPlayerMark(p, "@@lan__fengzhu_father", 0)
    end
  end
end)

fengzhu:addEffect(fk.GameStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(fengzhu.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getOtherPlayers(player)) do
      room:setPlayerMark(p, "@@lan__fengzhu_father", 1)
    end -- 对于开场就死了的人，不给标记，但是摸牌吧
    player:drawCards(3 * #room:getAllPlayers(), fengzhu.name)
  end,
})

return fengzhu
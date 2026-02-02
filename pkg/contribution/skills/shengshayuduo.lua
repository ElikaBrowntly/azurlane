local shengshayuduo = fk.CreateSkill{
  name = "shengshayuduo",
}

Fk:loadTranslationTable{
  ["shengshayuduo"] = "生杀予夺",
  [":shengshayuduo"] = "出牌阶段，若你拥有「圣剑」标记，你可以对一名角色造成1点伤害，"..
  "然后移除所有「圣剑」标记并摸等量张牌。",
  
  ["#shengshayuduo-invoke"] = "生杀予夺：请对一名角色造成1点伤害",
  
}

shengshayuduo:addEffect("active", {
  anim_type = "offensive",
  prompt = "#shengshayuduo-invoke",
  can_use = function(self, player)
    return player:getMark("@shengjian") > 0
  end,
  card_num = 0,
  target_num = 1,
  target_filter = function(self, player, to_select)
    return true
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    
    local shengjianCount = player:getMark("@shengjian")

    room:damage{
      from = player,
      to = target,
      damage = 1,
      skillName = shengshayuduo.name,
    }
    
    room:setPlayerMark(player, "@shengjian", 0)

    if shengjianCount > 0 and not player.dead then
      player:drawCards(shengjianCount, shengshayuduo.name)
    end
  end,
})

return shengshayuduo
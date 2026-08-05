local yuxi = fk.CreateSkill {
  name = "yyfy_yuxi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["yyfy_yuxi"] = "愚戏",
  [":yyfy_yuxi"] = "锁定技，你的摸牌阶段改为令所有角色获得2张【<a href='yyfy_yuxi-lihe'>惊喜礼盒</a>】。当你受到伤害时，你视为使用一张【惊喜礼盒】。",
  ["yyfy_yuxi-lihe"] = "<br>只有在开启二次元包（action_water_game）时，此技能才会生效。"
}

if not table.contains(Fk.extension_names, "action_water_game") then return yuxi end

yuxi:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Draw and not data.phase_end
  end,
  on_use = function(self, event, target, player, data)
    data.phase_end = true
    local room = player.room
    for _, p in ipairs(room:getAlivePlayers()) do
      if p:isAlive() then
        local cards = {}
        for _, i in ipairs({ 1, 2 }) do
          table.insert(cards, room:printCard("acg_jingxilihe", Card.Heart, 3).id)
        end
        room:moveCards({
          ids = cards,
          to = p,
          toArea = Card.PlayerHand,
          moveReason = fk.ReasonJustMove,
          proposer = player,
          skillName = yuxi.name,
          moveVisible = true,
        })
      end
    end
  end,
})

yuxi:addEffect(fk.DamageInflicted, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:canUse(player.room:printCard("acg_jingxilihe"))
  end,
  on_use = function(self, event, target, player, data)
    player.room:useVirtualCard("acg_jingxilihe", nil, player, player, yuxi.name)
  end
})

return yuxi
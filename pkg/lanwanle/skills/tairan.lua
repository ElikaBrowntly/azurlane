local tairan = fk.CreateSkill{
  name = "lan__tairan",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["lan__tairan"] = "泰然",
  [":lan__tairan"] = "锁定技，结束阶段，你回复体力至体力上限，将手牌摸至体力上限。（未完待续）",

  ["$lan__tairan1"] = "撼山易，撼我司马氏难。",
  ["$lan__tairan2"] = "云卷云舒，处之泰然。",
}

tairan:addEffect(fk.EventPhaseStart, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tairan.name) and player.phase == Player.Finish and
      (player:isWounded() or player:getHandcardNum() < player.maxHp)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player:isWounded() then
      local n = player:getLostHp()
      room:recover{
        who = player,
        num = n,
        recoverBy = player,
        skillName = tairan.name,
      }
      if player.dead then return end
    end
    if player:getHandcardNum() < player.maxHp then
      player:drawCards(player.maxHp - player:getHandcardNum(), tairan.name)
    end
  end,
})

return tairan
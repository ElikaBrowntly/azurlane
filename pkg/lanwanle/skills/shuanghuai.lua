local shuanghuai = fk.CreateSkill {
  name = "lan__shuanghuai",
}

Fk:loadTranslationTable {
  ["lan__shuanghuai"] = "霜怀",
  [":lan__shuanghuai"] = "每回合限一次，当与你距离1以内的角色受到伤害时，你可以防止此伤害，并令其从弃牌堆中获得一张【桃】。" ..
      "若其为此技能上次发动的目标，你与其各摸一张牌。",

  ["@lan__shuanghuai"] = "霜怀",

  ["$lan__shuanghuai1"] = "妾闻古之烈女，守节持义，至死不渝。",
  ["$lan__shuanghuai2"] = "吾生虽艰，然不改己志；烈女虽穷，然不负其节。",
  ["$lan__shuanghuai3"] = "颜子贵于能改，仲尼嘉其不贰，而况妇人者哉。",
  ["$lan__shuanghuai4"] = "兄长若违我愿，身赴清池可矣。",
  ["$lan__shuanghuai5"] = "女子有节，宁兰摧玉折，无负心违愿。",
}

shuanghuai:addEffect(fk.DetermineDamageInflicted, {
  anim_type = "defensive",
  times = function(self, player)
    return 1 - player:usedSkillTimes(shuanghuai.name)
  end,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(shuanghuai.name) and player:usedSkillTimes(shuanghuai.name) < 1 and
        target:distanceTo(player) <= 1
  end,
  on_cost = function(self, event, target, player, data)
    if not player.room:askToSkillInvoke(player, {
      skill_name = shuanghuai.name,
      prompt = "霜怀：是否要可以防止此伤害，并令其从弃牌堆中获得一张【桃】？"
    }) then 
      return false
    end
    local index = math.random(3)
    local mark = player:getMark("@lan__shuanghuai")
    if mark ~= target and mark ~= 0 then
      index = math.random(4, 5)
    end
    event:setCostData(self, { tos = { target }, audio_index = index })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local skillName = shuanghuai.name
    local room = player.room

    local side_effect = ""
    local mark = player:getMark("@lan__shuanghuai")
    if mark == 0 then
      room:setPlayerMark(player, "@lan__shuanghuai", target)
    elseif mark == target then
      side_effect = "draw"
    end

    data:preventDamage()

    local cards = room:getCardsFromPileByRule("peach", 1, "discardPile")
    if #cards > 0 then
      room:obtainCard(target, cards, true, fk.ReasonJustMove, player, skillName)
    end

    if side_effect == "draw" then
      if not player.dead then
        player:drawCards(1, skillName)
      end
      if not target.dead then
        target:drawCards(1, skillName)
      end
    end
  end,
})

shuanghuai:addLoseEffect(function(self, player, is_death)
  player.room:setPlayerMark(player, "@lan__shuanghuai", 0)
end)

return shuanghuai
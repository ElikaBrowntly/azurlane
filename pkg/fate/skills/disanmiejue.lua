local miejue = fk.CreateSkill {
  name = "yyfy_disanmiejue",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable {
  ["yyfy_disanmiejue"] = "<font color='#D969D4'>第三灭绝</font>",
  [":yyfy_disanmiejue"] = "<font color='#D969D4'>持恒技，获得此技能时，令敌方全体角色失去一半体力。"
  .."你接下来受到的4次伤害减少20%。</font>",
  ["@yyfy_disanmiejue"] = "第三灭绝"
}

local F = require "packages.hidden-clouds.functions"

miejue:addAcquireEffect(function(self, player, is_start, src)
  local room = player.room
  for _, p in ipairs(room:getAlivePlayers()) do
    if F.isEnemy(player, p) then
      room:loseHp(p, math.ceil(p.hp / 2), miejue.name, player)
    end
  end
  room:addPlayerMark(player, "@yyfy_disanmiejue", 4)
end)

miejue:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:getMark("@yyfy_disanmiejue") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data:changeDamage(-math.ceil(data.damage * 0.2))
    player.room:addPlayerMark(player, "@yyfy_disanmiejue", -1)
  end
})

return miejue
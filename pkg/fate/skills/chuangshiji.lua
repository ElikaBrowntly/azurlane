local skill = fk.CreateSkill {
  name = "yyfy_chuangshiji",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable{
  ["yyfy_chuangshiji"] = "<font color='#FF520B'>创世纪·起源</font>",
  [":yyfy_chuangshiji"] = "<font color='#FF520B'>持恒技，你的第一血条被击破后，你令所有敌方角色在其"
  .."下两个回合无法使用【杀】，然后你接下来受到的5次伤害减少20%。</font>",
  ["@yyfy_chuangshiji"] = "创世纪"
}

local F = require "packages.hidden-clouds.functions"

skill:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    return card.trueName == "slash" and player:getMark("@yyfy_chuangshiji") > 0
  end,
})

skill:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(self) and table.find(player.room.alive_players, function (p)
      return p:getMark("@yyfy_chuangshiji") > 0
    end)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tos = table.filter(player.room.alive_players, function (p)
      return p:getMark("@yyfy_chuangshiji") > 0
    end)
    for _, p in ipairs(tos) do
      room:addPlayerMark(p, "@yyfy_chuangshiji", -1)
    end
  end
})

skill:addEffect(fk.AfterPlayerRevived, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.tag["@yyfy_xietiao_XibalbaORT"] == 5
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getAlivePlayers()) do
      if F.isEnemy(player, p) then
        room:setPlayerMark(p, "@yyfy_chuangshiji", 2)
      end
    end
    room:setPlayerMark(player, "yyfy_chuangshiji", 5)
  end
})

skill:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:getMark("yyfy_chuangshiji") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data:changeDamage(-math.ceil(data.damage * 0.2))
    player.room:addPlayerMark(player, "yyfy_chuangshiji", -1)
  end
})

return skill
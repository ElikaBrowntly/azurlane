local skill = fk.CreateSkill {
  name = "yyfy_kuayuebianjiezhiren",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable {
  ["yyfy_kuayuebianjiezhiren"] = "<font color='#FF0405'>跨越边界之人</font>",
  [":yyfy_kuayuebianjiezhiren"] = "<font color='#FF0405'>持恒技，你的第六血条被击破后，你接下来受到的5次"..
  "伤害减少70%，造成大于1的伤害时随机即死一名敌方角色。</font>",
  ["@yyfy_kuayuebianjiezhiren"] = "跨越边界之人"
}

local F = require("packages.hidden-clouds.functions")

skill:addEffect(fk.AfterPlayerRevived, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
        (player.tag["@yyfy_xietiao_XibalbaORT"] or 0) == 1
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@yyfy_kuayuebianjiezhiren", 8)
    room:setPlayerMark(player, "yyfy_kuayuebianjie-jisi", 1)
  end
})

skill:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:getMark("@yyfy_kuayuebianjiezhiren") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data:changeDamage(-math.ceil(data.damage * 0.7))
    player.room:addPlayerMark(player, "@yyfy_kuayuebianjiezhiren", -1)
  end
})

skill:addEffect(fk.DamageCaused, {
  can_trigger = function (self, event, target, player, data)
    if not (target == player and player:hasSkill(self) and data.damage > 1
      and player:getMark("yyfy_kuayuebianjie-jisi") > 0) then
      return false
    end
    local tos = table.filter(player.room.players, function (p)
      return (p:isAlive() or p.rest > 0) and F.isEnemy(player, p)
    end)
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local tos = (event:getCostData(self) or {}).tos
    if not tos or #tos == 0 then return end
    player.room:killPlayer({
      who = table.random(tos),
      killer = player,
    })
  end
})

return skill
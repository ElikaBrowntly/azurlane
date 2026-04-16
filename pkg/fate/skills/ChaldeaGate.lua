local gate = fk.CreateSkill {
  name = "yyfy_ChaldeaGate",
}

local CS = require("packages.hidden-clouds.functions")

Fk:loadTranslationTable {
  ["yyfy_ChaldeaGate"] = "迦勒底之门",
  [":yyfy_ChaldeaGate"] = "游戏结束后，若本局游戏没有开启自由选将，所有玩家获得1圣晶石。" ..
      "胜者额外获得1圣晶石。<font color = 'red'>若不想获取圣晶石，可以禁用此武将</font>",
}

gate:addEffect(fk.GameFinished, {
  priority = 0.00001,
  global = true,
  can_refresh = function(self, event, target, player, data)
    return not player.room:getSettings("enableFreeAssign") and player.id > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local winners = data:split("+")
    local num = 1
    if table.contains(winners, player.role) then
      num = 2
    end
    CS.ChangePlayerSaintQuartz(player, num)
  end
})

return gate
local gate = fk.CreateSkill {
  name = "yyfy_ChaldeaGate",
}

local CS = require("packages.hidden-clouds.functions")
local U = require "packages/utility/utility"

Fk:loadTranslationTable {
  ["yyfy_ChaldeaGate"] = "迦勒底之门",
  [":yyfy_ChaldeaGate"] = "①游戏结束后，若本局游戏没有开启自由选将，所有玩家获得1圣晶石。" ..
      "胜者额外获得1圣晶石。<br>②你可以于游戏菜单的“迦勒底之门”内交换概念礼装，概念礼装所持有的"..
      "技能将在你参与的所有模式生效。<font color = 'red'><br>若不想获取圣晶石，可以禁用此武将</font>",
}

gate:addEffect(fk.GameFinished, {
  priority = 0.00001,
  global = true,
  can_refresh = function(self, event, target, player, data)
    return player and not player.room:getSettings("enableFreeAssign") and player.id > 0
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

gate:addEffect(fk.GameStart, {
  global = true,
  can_trigger = function(self, event, target, player, data)
    if not (player and player.id > 0) then return false end
    local state = player:getGlobalSaveState("hidden-clouds")
    local quartz = state["SaintQuartz"] or {}
    local clothes = quartz.clothes or {} -- 键值表，key为礼装名称，value为所持数量
    local count = 0
    for c in pairs(clothes) do
      if (clothes[c] or 0) > 0 then
        count = count + 1
      end
    end
    if count == 0 then return false end
    local costData = event:getCostData(self) or {}
    costData.clothes = clothes
    event:setCostData(self, costData)
    return true
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local costData = event:getCostData(self) or {}
    local clothes = costData.clothes or {}
    -- 万华镜
    if clothes["wanhuajing"] then
      local num = clothes["wanhuajing"] == 5 and 10 or 8
      U.skillCharged(player, num)
    end
  end,
})

return gate
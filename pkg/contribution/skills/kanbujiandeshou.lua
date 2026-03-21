local shou = fk.CreateSkill {
  name = "yyfy_kanbujiandeshou",
}

local ok, CS = pcall(require, "packages.coins-system.csfs")

Fk:loadTranslationTable {
  ["yyfy_kanbujiandeshou"] = "看不见的手",
  [":yyfy_kanbujiandeshou"] = "每天限一次，<a href = 'yyfy_kanbujiandeshou-gamemode'>" ..
      "游戏结束</a>后，你获得5%的已拥有金币。",
  ["$yyfy_kanbujiandeshou"] = "叮~",
  ["yyfy_kanbujiandeshou-gamemode"] = "除了白名单模式以外，不允许存在人机。<br>白名单模式：机关造物，" ..
      "后浪模式，虎牢关1v3，虎牢关2022，虎牢关炼狱。<br><br><br><font color='blue'><i>&nbsp;&nbsp;" ..
      "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;我们的晚餐并非来自屠宰商、酿酒师和面包师的恩惠，而是来自" ..
      "他们对自身利益的关切。<div style = 'text-align:right;'>———亚当·斯密《国富论》</div></i></font>"
}

if not ok then return shou end

local function whitelist(room)
  local list = { "houlang_mode", "jiguanzaowu_mode", "m_1v3_mode", "hx__1v3_mode", "hulaoguan" }
  for _, mode in ipairs(list) do
    if room:isGameMode(mode) then
      return true
    end
  end
  return false
end

local sayings = {
  "我们的晚餐并非来自屠宰商、酿酒师和面包师的恩惠，而是来自他们对自身利益的关切。",
  "人对自身利益的关注自然会……青睐最利于社会的用途。这就像“有一只无形的手”在引导着他。",
  "人天生，并且永远，是自私的动物。",
  "只要不违反公正的法律，那么人人都有完全的自由以自己的方式追求自己的利益。"
}

shou:addEffect(fk.GameFinished, {
  priority = 0.0001,
  can_refresh = function(self, event, target, player, data)
    if not player or not player:hasSkill(self) then return false end
    local state = player:getGlobalSaveState("hidden-clouds")
    local save = state["yyfy_kanbujiandeshou"] or {}
    local today = os.date("%Y-%m-%d")
    if save.last_date == today then
      return false
    end
    return true
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if not whitelist(room) then
      for _, p in ipairs(room:getAllPlayers()) do
        if p.id < 0 then
          room:doBroadcastNotify("ShowToast", "由于存在人机，看不见的手无法获得金币。")
          return
        end
      end
    end
    local coinsData = CS.GetcoinsData(player)
    local gold = coinsData.gold or 0
    local reward = math.floor(gold * 0.05)
    if reward > 0 then
      CS.ChangePlayerMoney(player, reward)
    end
    local state = player:getGlobalSaveState("hidden-clouds")
    local save = state["yyfy_kanbujiandeshou"] or {}
    save.last_date = os.date("%Y-%m-%d")
    --仅存储一个 last_date 字段，记录最后一次触发日期。如果当天已触发则跳过。
    state["yyfy_kanbujiandeshou"] = save
    player:saveGlobalState("yyfy_kanbujiandeshou", state)
  end
})

shou:addEffect(fk.TurnStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_refresh = function(self, event, target, player, data)
    player:chat(sayings[math.random(4)])
  end
})

return shou

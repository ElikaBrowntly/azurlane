local shou = fk.CreateSkill{
  name = "yyfy_kanbujiandeshou",
}
local ok, CS = pcall(require, "packages.coins-system.csfs")

Fk:loadTranslationTable{
  ["yyfy_kanbujiandeshou"] = "看不见的手",
  [":yyfy_kanbujiandeshou"] = "每天限一次，<a href = 'yyfy_kanbujiandeshou-gamemode'>游戏结束</a>后，你获得5%的已拥有金币。",
  ["$yyfy_kanbujiandeshou"] = "叮~",
  ["yyfy_kanbujiandeshou-gamemode"] = "除了“机关造物”和“后浪模式”以外，不允许存在人机。"
}

if not ok then return shou end

shou:addEffect(fk.GameFinished, {
  priority = 0.0001,
  can_refresh = function(self, event, target, player, data)
    if not player or not player:hasSkill(self) then return false end
    local save = player:getGlobalSaveState("yyfy_kanbujiandeshou") or {}
    local today = os.date("%Y-%m-%d")
    if save.last_date == today then
      return false
    end
    return true
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if not (room:isGameMode("houlang_mode") or room:isGameMode("jiguanzaowu_mode")) then
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
    local save = player:getGlobalSaveState("yyfy_kanbujiandeshou") or {}
    save.last_date = os.date("%Y-%m-%d")
    --仅存储一个 last_date 字段，记录最后一次触发日期。如果当天已触发则跳过。
    player:saveGlobalState("yyfy_kanbujiandeshou", save)
  end
})

return shou
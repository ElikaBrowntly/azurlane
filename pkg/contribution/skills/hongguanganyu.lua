local ganyu = fk.CreateSkill {
  name = "yyfy_hongguanganyu",
}

local CS = require("packages.hidden-clouds.functions")

Fk:loadTranslationTable {
  ["yyfy_hongguanganyu"] = "宏观干预",
  [":yyfy_hongguanganyu"] = "共鸣技，游戏结束后，你的金币与<a href='yyfy_hongguanganyu_start'>游戏开始时"..
    "</a>相比：<br><font color = '#32CD32'><b>顺差</b></font>：你获得加倍的金币；"..
    "<font color = 'red'><b>逆差</b></font>：你获得失去的金币。",
  ["yyfy_hongguanganyu_start"] = "<br><b>注：</b>实际为获得此技能时。<br><br><font color='blue'>"..
    "<br><i>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;长远来看，我们都已入土为安。"..
    "<div style = 'text-align:right;'>———凯恩斯《货币论》</div></i></font>",
  ["$yyfy_hongguanganyu"] = "叮~",
}

local sayings = {
  "长远来看，我们都已入土为安。",
  "保护政策如能带来贸易顺差，必将有利于提高投资水平和扩大就业。",
  "重商主义，学说里含有科学成分。。",
  "实行重商主义所能取得的好处，只仅限一国，不会泽及全世界。"
}

ganyu:addEffect(fk.GameStart, {
  priority = 100000,
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(self) and player.id > 0 and
    (player.general == "yyfy_Keynes" or player.deputyGeneral or "" == "yyfy_Keynes")
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local coinsData = CS.GetcoinsData(player)
    local before = coinsData.gold or 0
    player.room:setPlayerMark(player, ganyu.name, before)
  end
})

ganyu:addEffect(fk.GameFinished, {
  priority = 0.00001,
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(self) and player.id > 0 and
    (player.general == "yyfy_Keynes") or (player.deputyGeneral or "" == "yyfy_Keynes")
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local coinsData = CS.GetcoinsData(player)
    local after = coinsData.gold or 0
    local before = player:getMark(ganyu.name)
    CS.ChangePlayerMoney(player, math.abs(after - before))
  end
})

ganyu:addEffect(fk.TurnStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
    (player.general == "yyfy_Keynes" or player.deputyGeneral or "" == "yyfy_Keynes")
  end,
  on_refresh = function(self, event, target, player, data)
    player:chat(sayings[math.random(4)])
  end
})

return ganyu
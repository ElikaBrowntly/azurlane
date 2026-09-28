-- SPDX-License-Identifier: GPL-3.0-or-later
-- 夜隐浮云·麻将模式规则技能：驱动引擎主流程
-- 手牌无上限；系统初始发牌仅发 1 张（由引擎发 13/14 张，避免干扰）；
-- 禁止 DrawNCards 摸牌（所有摸牌由引擎自建牌山处理）。

local rule = fk.CreateSkill {
  name = "#yyfy_mahjong_rule&",
}

--手牌无上限
rule:addEffect("maxcards", {
  correct_func = function(self, player)
    return player and 999
  end
})

--初始手牌，牌由引擎自建牌山分发
rule:addEffect(fk.DrawInitialCards, {
  priority = 0.001,
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    data.num = 1
  end,
})

--禁止摸牌
rule:addEffect(fk.DrawNCards, {
  priority = 0.001,
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    data.n = 0
  end,
})

local M = require "packages.hidden-clouds.pkg.gamemodes.yyfy_mahjong_engine"

--游戏流程
rule:addEffect(fk.GameStart, {
  priority = 0.001,
  can_refresh = function(self, event, target, player, data)
    return player.role == "lord"
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    -- 座次已由框架 adjustSeats 统一：庄家为 1 号位、其余按逆时针排列，直接沿用框架自带顺序
    M.Run(room, room.players, self.name)
  end,
})

return rule

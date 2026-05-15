local lingke = fk.CreateSkill {
  name = "lan__lingke",
  tags = { Skill.Compulsory }
}

Fk:loadTranslationTable {
  ["lan__lingke"] = "零氪",
  [":lan__lingke"] = "锁定技，场上每存在一个<a href='lan_xiyou'>比你稀有</a>的武将，" ..
      "你令〖安国〗中的数字+1；你对这些角色造成的伤害+X（X为这些角色的数量）。",
  ["lan_xiyou"] = "分为普通、稀有、史诗、传说、限定五档，非OL武将会被分为“其他”，视为比朱治稀有。",
  ["$lan__lingke1"] = "祭祀吧。开启战士的时间吧。",
  ["$lan__lingke2"] = "——不错，非常好。",
}

local F = require("packages.hidden-clouds.functions")

lingke:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self.name) and data.to and data.to ~= player) then
      return false end
    local rank = {
      ["普通"] = 0,
      ["稀有"] = 1,
      ["史诗"] = 2,
      ["传说"] = 3,
      ["限定"] = 4,
      ["其他"] = 5
    }
    return rank[F.rareRank(data.to.general)] > 1
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(F.rarerCount(player, "稀有"))
    local sayings = {
      "这些充钱也勾可真难对付",
      "富哥们玩三国杀真精彩",
      "这武将直接说你赢了得了",
      "你知道我要说什么吧",
      "我也充钱了！"
    }
    player:chat(sayings[math.random(5)])
  end,
})

return lingke
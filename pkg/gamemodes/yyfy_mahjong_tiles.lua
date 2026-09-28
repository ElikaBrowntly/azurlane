-- SPDX-License-Identifier: GPL-3.0-or-later
-- 夜隐浮云麻将模式的占位牌（正式牌面由作者后续补充）
-- 36 种数牌（含三赤）+ 7 种字牌，共 136 张：
--   万子：yyfy_1m~yyfy_9m 各 4 张，yyfy_0m(红五) 1 张
--   筒子：yyfy_1p~yyfy_9p 各 4 张，yyfy_0p(红五) 1 张
--   索子：yyfy_1s~yyfy_9s 各 4 张，yyfy_0s(红五) 1 张
--   字牌：東南西北白發中（ton/nan/sha/pei/haku/hatsu/chun）各 4 张

local tiles = Package:new("yyfy_mahjong_tiles", Package.CardPack)
tiles.extensionName = "hidden-clouds"

local numbers = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }
local suits = { m = "万", p = "筒", s = "索" }
local honors = {
  ton = "東", nan = "南", sha = "西", pei = "北",
  haku = "白", hatsu = "發", chun = "中",
}

local translationData = {}

local function makeTile(name, trans)
  local card = fk.CreateCard{
    name = "&" .. name,
    type = Card.TypeBasic,
  }
  tiles:loadCardSkels{ card }
  translationData[name] = trans
  translationData[":" .. name] = "这是一张" .. trans .. "牌"
end

for suit, suitName in pairs(suits) do
  for _, num in ipairs(numbers) do
    local name = ("yyfy_%s%s"):format(num, suit)
    local digit = tonumber(num)
    tiles:addCardSpec(name, Card.NoSuit, digit)
    makeTile(name, num .. suitName)
  end
  -- 红五：视作 5 点，一张
  local akaName = ("yyfy_0%s"):format(suit)
  tiles:addCardSpec(akaName, Card.NoSuit, 5)
  makeTile(akaName, "红五" .. suitName)
end

for roman, trans in pairs(honors) do
  local name = "yyfy_" .. roman
  tiles:addCardSpec(name, Card.NoSuit, 1)
  makeTile(name, trans)
end

Fk:loadTranslationTable(translationData)

return tiles

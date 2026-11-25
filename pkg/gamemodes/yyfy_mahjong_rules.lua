-- SPDX-License-Identifier: GPL-3.0-or-later
-- 夜隐浮云·麻将：地方规则开关
-- 引擎（yyfy_mahjong_engine.lua）与模式定义（yyfy_mahjong_mode.lua）共用同一份配置，
-- 便于按不同规则预设组合出多个玩法。默认值 = 此前实现的行为。

local RULES = {
  -- 1. 赤宝牌数量：0 = 无红五（五种数字各 4 张普通五）；
  --    1 = 三赤（0m / 0p / 0s 各 1 张）；2 = 四赤（筒子 2 张 0p + 2 张普通 5p）。
  redFives = 1,
  -- 2. 食断：副露后仍可成立断幺九。关闭后，有副露时断幺九不计番、不能作为起胡役。
  kuitan = true,
  -- 3. 西入：南四过庄后若无人达到 30000 点，则续战西场 / 北场，最多至北四。
  --    关闭时南四流局或庄家以外的人和牌即结束（庄家和牌仍可连庄）。
  seiu = true,
  -- 4. 和了终局（原"尾亲连庄"取反）：开启时，南四庄家和牌连庄时，
  --    若庄家是一位且点数超过 30000，则不能继续连庄（本半庄结束）。关闭时允许连庄。
  winEndgame = true,
  -- 5. 击飞：有人点数为负则结束半庄（0 分不击飞）。此时点数不足 1000 不允许立直。
  --    关闭时允许负分继续游戏，立直也不受 1000 点限制。
  tobi = true,
  -- 6. 流局满贯：承认流局满贯（本局弃牌全为幺九牌且从未被副露者视为满贯自摸）。
  nagashiMangan = true,
  -- 7. 切上满贯：3 番 60 符 / 4 番 30 符按满贯 2000 基础点计算（不再有 7700 / 11600）。
  kiriageMangan = false,
  -- 8. 表宝牌：关闭后表宝牌不计入番。
  omoteDora = true,
  -- 9. 杠表宝牌：关闭后开杠不再追加表宝牌。
  kanOmoteDora = true,
  -- 10. 里宝牌：关闭后不翻开里宝牌（立直家和牌也不揭晓、不计番）。
  uraDora = true,
  -- 11. 杠里宝牌：关闭后开杠不再追加里宝牌。
  kanUraDora = true,
  -- 12. 明杠宝牌即翻：开启时明杠与暗杠相同，开杠瞬间翻出新宝牌；
  --     关闭时明杠改为开杠者切牌之后再翻。
  kanDoraImmediate = true,
  -- 13. 四风连打：第一巡四家首次打出的均为同一张风牌 → 途中流局。
  fourWindAbort = true,
  -- 14. 四杠散了：第四次杠后若未岭上开花，开杠者照常打出一张牌；
  --     该牌被荣和则正常放铳（不算流局也不算河底），通过（无人荣和且无人副露）则立即流局。
  fourKanAbort = true,
  -- 15. 五杠流局：开启时允许第五次杠，开杠通过后（未被抢杠）立即流局；
  --     关闭时摸到第五个杠不能宣言开杠，只能当作普通牌处理。
  fiveKanAbort = false,
  -- 16. 四家立直：第四家立直宣言通过（弃牌无人荣和）后立即流局。
  fourRiichiAbort = false,
  -- 17. 九种九牌：起手有九种以上幺九牌时，亮起"九种九牌流局"按钮，
  --     宣告后本局流局，并在结算界面展示其手牌。
  nineTerminals = false,

  -- 18. 三家和了流局：同一张舍牌（或加杠）同时被另外三家荣和时，放铳无效，
  --     该局按中途流局处理（本场 +1、庄家连庄）。仅在关闭头跳时可能发生。
  tripleRonAbort = false,
  -- 19. 头跳：开启时不承认一炮多响，由放铳家的下家开始按顺序取第一个和牌者为唯一和牌者。
  --     关闭时允许一炮多响（双响照常结算；三响按第 18 项决定是否流局）。
  atamahane = false,
  -- 20. 胡牌连庄：关闭后即使庄家和牌也会过庄。
  dealerWinRenchan = true,
  -- 21. 听牌连庄：关闭后庄家听牌流局不会连庄（途中流局不受此开关影响，仍连庄）。
  tenpaiRenchan = true,
  -- 22. 听牌终局：南四流局且庄家为一位时，按"庄家是否听牌"决定是否终局：
  --     听牌 → 开西入则看庄家是否达到 30000（到则终局，不到则连庄），无西入则终局；
  --     没听 → 终局。
  tenpaiEndgame = false,
  -- 23. 一发：关闭时不承认一发这个役。
  ippatsu = true,
  -- 24. 番缚：不算宝牌的役合计至少几番才能和牌（0/1/2/3/4/6/8/10/12/13）。
  --     0 表示无役也能和牌；默认 1 即"有役即可和、无役不可和"。
  hanShibari = 1,
  -- 25. 双倍役满：开启时四暗刻单骑、纯正九莲宝灯、国士无双十三面、大四喜按双倍役满计算。
  doubleYakuman = true,
  -- 26. 复合役满：开启时多个役满可以叠加（每多一倍，闲家 +32000、庄家 +48000）。
  --     关闭时只取倍数最高的一个役满。
  compoundYakuman = true,
  -- 27. 食替：开启时允许吃/碰后打出与副露相关的牌（食替）。
  --     关闭时沿用此前规则（鸣牌后同筋/同牌不可立即打出）。
  kuikaeAllowed = false,
  -- 28. 尾巡立直：是否允许在"已无下一次摸牌机会"的尾巡立直。
  --     默认不允许（true 为允许）。
  tailRiichi = false,
  -- 29. 连风雀头：役牌雀头加符数。"双东""双南"等连风雀头按 2 符或 4 符（默认 4）。
  doubleWindPairFu = 4,
  -- 30. 国士抢杠：开启时国士无双可以抢暗杠，关闭时不能。
  kokushiChankan = false,
  -- 31. 人和：开启时把人和算作役满（第一巡轮到自己摸牌前、全场无人副露时荣和）。
  --     与复合役满同时开启时可与其他役满叠加。
  renhou = false,
  -- 32. 包牌：键为大三元 / 大四喜 / 四杠子，值为 1 表示该役满触发包牌、0 表示不触发。
  --     被包牌者自摸时包牌者支付全部；荣和时包牌者与放铳者各付一半；
  --     复合役满时包牌者只负责所包役满对应的点数部分。
  --     四杠子的责任者为打出第四杠（大明杠）那张牌的人。
  pao = { daisangen = 0, daisuushi = 0, suukantsu = 0 },
  -- 33. 累计役满：开启时 13 番以上统一按一倍役满（32000/48000）计算。
  --     关闭时 13 番及以上按三倍满（24000/36000）计算。
  kazoeYakuman = true,
  -- 34. 古役：开启后承认以下役种
  --     （燕返、杠上炮、十二落抬、五门齐、三连刻、一色三同顺、一筒摸月、九筒捞鱼、
  --       大车轮、大竹林、大数邻、石上三年、大七星）。
  oldYaku = false,
}

--------------------------------------------------------------------------
-- 预设规则
-- 创建房间时通过"游戏规则"下拉框选择，键为翻译表中的预设名称。
-- 选中某套预设后，会把该预设的全部开关写入 RULES（其余未列出的键保持当前值）。
--------------------------------------------------------------------------

local PRESETS = {
  -- 雀魂规则
  ["yyfy_mj_rule_jousou"] = {
    redFives = 1, kuitan = true, seiu = true, winEndgame = true, tobi = true,
    nagashiMangan = true, kiriageMangan = false,
    omoteDora = true, kanOmoteDora = true, uraDora = true, kanUraDora = true,
    kanDoraImmediate = false,
    fourWindAbort = true, fourKanAbort = true, fiveKanAbort = false,
    fourRiichiAbort = true, nineTerminals = true,
    tripleRonAbort = false, atamahane = false,
    dealerWinRenchan = true, tenpaiRenchan = true, tenpaiEndgame = true,
    ippatsu = true, hanShibari = 1,
    doubleYakuman = true, compoundYakuman = true,
    kuikaeAllowed = false, tailRiichi = false,
    doubleWindPairFu = 4,
    kokushiChankan = true, renhou = false,
    pao = { daisangen = 1, daisuushi = 1, suukantsu = 0 },
    kazoeYakuman = true, oldYaku = false,
  },
  -- ML 规则
  ["yyfy_mj_rule_ml"] = {
    redFives = 1, kuitan = true, seiu = false, winEndgame = false, tobi = false,
    nagashiMangan = false, kiriageMangan = true,
    omoteDora = true, kanOmoteDora = true, uraDora = true, kanUraDora = true,
    kanDoraImmediate = true,
    fourWindAbort = false, fourKanAbort = false, fiveKanAbort = false,
    fourRiichiAbort = false, nineTerminals = false,
    tripleRonAbort = false, atamahane = true,
    dealerWinRenchan = true, tenpaiRenchan = true, tenpaiEndgame = false,
    ippatsu = true, hanShibari = 1,
    doubleYakuman = false, compoundYakuman = true,
    kuikaeAllowed = false, tailRiichi = true,
    doubleWindPairFu = 2,
    kokushiChankan = false, renhou = false,
    pao = { daisangen = 1, daisuushi = 1, suukantsu = 1 },
    kazoeYakuman = false, oldYaku = false,
  },
  -- A-1 规则
  ["yyfy_mj_rule_a1"] = {
    redFives = 0, kuitan = true, seiu = false, winEndgame = false, tobi = true,
    nagashiMangan = false, kiriageMangan = true,
    omoteDora = true, kanOmoteDora = false, uraDora = false, kanUraDora = false,
    kanDoraImmediate = true,
    fourWindAbort = false, fourKanAbort = false, fiveKanAbort = false,
    fourRiichiAbort = false, nineTerminals = false,
    tripleRonAbort = true, atamahane = true,
    dealerWinRenchan = true, tenpaiRenchan = true, tenpaiEndgame = false,
    ippatsu = false, hanShibari = 1,
    doubleYakuman = false, compoundYakuman = true,
    kuikaeAllowed = false, tailRiichi = true,
    doubleWindPairFu = 2,
    kokushiChankan = true, renhou = false,
    pao = { daisangen = 1, daisuushi = 1, suukantsu = 0 },
    kazoeYakuman = true, oldYaku = false,
  },
}

RULES.presets = PRESETS

-- 应用一套预设；未知（含未设置）时回退到"雀魂规则"
function RULES.applyPreset(key)
  local preset = PRESETS[key] or PRESETS["yyfy_mj_rule_jousou"]
  for k, v in pairs(preset) do
    if type(v) == "table" then
      local copied = {}
      for kk, vv in pairs(v) do copied[kk] = vv end
      RULES[k] = copied
    else
      RULES[k] = v
    end
  end
  return preset
end

return RULES

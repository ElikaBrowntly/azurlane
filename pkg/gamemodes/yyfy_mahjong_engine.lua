-- SPDX-License-Identifier: GPL-3.0-or-later
-- 夜隐浮云·麻将模式核心引擎
-- 规则概要（雀魂/立直麻将）：
--   三赤、有击飞、无古役、无番缚、有振听、有食断、有立直
--   四人游戏，初始 25000 点，半庄两圈（东场 4 局 + 南场 4 局，round>8 结束按点数判胜）
--   庄家随机东起（主公），逆时针行牌，门风随庄家旋转、场风东/南，均计入起胡役
--   牌堆 136 张：数牌 108（含红五三张）+ 字牌 28
-- 主入口：M.Run(room, players, skill_name)，同步阻塞驱动整局游戏
-- 对局状态持久化在 room:setTag("yyfy_mj_state", state)

local M = {}

--------------------------------------------------------------------------
-- 牌名 / 类型索引
-- 类型 0~33：0-8=1m~9m，9-17=1p~9p，18-26=1s~9s，
--            27=ton(東) 28=nan(南) 29=sha(西) 30=pei(北)
--            31=haku(白) 32=hatsu(發) 33=chun(中)
-- 红五：yyfy_0m/0p/0s 分别映射为类型 4/13/22（视作 5m/5p/5s）
--------------------------------------------------------------------------

local TYPE_TO_NAME = {}
for i = 1, 9 do TYPE_TO_NAME[i - 1] = ("yyfy_%dm"):format(i) end
for i = 1, 9 do TYPE_TO_NAME[i + 8] = ("yyfy_%dp"):format(i) end
for i = 1, 9 do TYPE_TO_NAME[i + 17] = ("yyfy_%ds"):format(i) end
local HONOR_ROMAJI = { "ton", "nan", "sha", "pei", "haku", "hatsu", "chun" }
for i, h in ipairs(HONOR_ROMAJI) do TYPE_TO_NAME[i + 26] = "yyfy_" .. h end

local NAME_TO_TYPE = {}
for t = 0, 33 do
  NAME_TO_TYPE[TYPE_TO_NAME[t]] = t
end
NAME_TO_TYPE["yyfy_0m"] = 4
NAME_TO_TYPE["yyfy_0p"] = 13
NAME_TO_TYPE["yyfy_0s"] = 22

-- 赤宝牌类型
local AKA_TYPES = { 4, 13, 22 }

-- 幺九牌（含字牌）
local function isYaochu(t)
  if t >= 27 then return true end
  local d = t % 9
  return d == 0 or d == 8
end

-- 宝牌指示牌对应的宝牌类型（指示牌的“下一张”）
local function nextDora(t)
  if t < 27 then
    local base = t - (t % 9)
    return base + ((t - base + 1) % 9)
  else
    return 27 + ((t - 26) % 7)
  end
end

-- 卡 id -> 类型
local function cardTypeOf(id)
  local card = Fk:getCardById(id)
  if not card then return -1 end
  return NAME_TO_TYPE[card.name] or -1
end

-- 表宝牌文字（如“3索”）：只显示已翻出的表指示牌对应的宝牌，里宝牌不在此列
local function omoteDoraTexts(state)
  local ret = {}
  for i = 1, state.dora_count do
    local ind = state.indicator[i]
    if ind then table.insert(ret, Fk:translate(TYPE_TO_NAME[nextDora(cardTypeOf(ind))])) end
  end
  return ret
end

-- 里宝牌文字：默认隐藏，仅当立直家胡牌时才揭晓
local function uraDoraTexts(state)
  local ret = {}
  for i = 5, 4 + state.dora_count do
    local ind = state.indicator[i]
    if ind then table.insert(ret, Fk:translate(TYPE_TO_NAME[nextDora(cardTypeOf(ind))])) end
  end
  return ret
end

-- 全部宝牌文字：表宝牌 + （可选）里宝牌
local function allDoraTexts(state, includeUra)
  local ret = omoteDoraTexts(state)
  if includeUra then
    for _, s in ipairs(uraDoraTexts(state)) do table.insert(ret, s) end
  end
  return ret
end

-- 玩家手牌 -> 类型数组
local function handTypes(p)
  local ret = {}
  for _, id in ipairs(p:getCardIds("h")) do
    local t = cardTypeOf(id)
    if t >= 0 then table.insert(ret, t) end
  end
  return ret
end

-- 类型数组 -> 计数表（0~33）
local function countTable(types)
  local c = {}
  for i = 0, 33 do c[i] = 0 end
  for _, t in ipairs(types) do c[t] = c[t] + 1 end
  return c
end

local function countType(types, target)
  local n = 0
  for _, t in ipairs(types) do
    if t == target then n = n + 1 end
  end
  return n
end

-- 麻将行动顺序为逆时针（庄家→下家→…）。FreeKill 座次 1→2→3→4 在 UI 上即为
-- 逆时针，因此逆时针 = 座次递增回绕（1→2→3→4），即“上家打出牌、下家响应”。
-- 从某个玩家开始按逆时针座次的玩家表（含 from 本身）
local function seatOrderFrom(state, from)
  local players = state.players
  local n = #players
  local idx = 1
  for i, p in ipairs(players) do
    if p == from then idx = i break end
  end
  local ret = {}
  for i = 1, n do
    local j = idx + (i - 1)
    if j > n then j = j - n end
    table.insert(ret, players[j])
  end
  return ret
end

-- from 的下一家（麻将“下家”）
local function nextSeat(state, from)
  local players = state.players
  local n = #players
  for i, p in ipairs(players) do
    if p == from then return players[i == n and 1 or i + 1] end
  end
  return players[1]
end

-- 玩家手牌中同类型的 n 张牌的 id
local function findHandIds(p, t, n)
  local ret = {}
  for _, id in ipairs(p:getCardIds("h")) do
    if cardTypeOf(id) == t then
      table.insert(ret, id)
      if #ret >= n then break end
    end
  end
  return ret
end

-- 从“卡名或翻译文本”反查类型
local function typeFromNameOrTrans(str)
  if NAME_TO_TYPE[str] then return NAME_TO_TYPE[str] end
  for t = 0, 33 do
    if Fk:translate(TYPE_TO_NAME[t]) == str then return t end
  end
  return nil
end

local function findMeldByType(melds, t, meldType)
  for _, m in ipairs(melds) do
    if m.tiles[1] == t and (meldType == nil or m.type == meldType) then return m end
  end
  return nil
end

-- 麻将手牌排序键：1234056789m1234056789p1234056789s东南西北白发中（红五视作 4 与 5 之间）
local function mahjongSortKey(id)
  local t = cardTypeOf(id)
  if t < 0 then return 1e9 end
  if t <= 26 then
    local suit = math.floor(t / 9)
    local digit = (t % 9) + 1
    local card = Fk:getCardById(id)
    if card and card.name:find("yyfy_0", 1, true) then digit = 4.5 end
    return suit * 10 + digit
  end
  return 30 + (t - 26)
end

-- 出牌前把手牌取走，按麻将序重排后塞回玩家手里
local function sortHandByMahjong(room, p)
  local ids = p:getCardIds("h")
  if #ids < 2 then return end
  for _, id in ipairs(ids) do
    room:moveCardTo(id, Card.Processing, nil, fk.ReasonJustMove, "yyfy_mj_sort", nil, false, p)
  end
  table.sort(ids, function(a, b)
    local ka, kb = mahjongSortKey(a), mahjongSortKey(b)
    if ka ~= kb then return ka < kb end
    return a < b
  end)
  for _, id in ipairs(ids) do
    room:moveCardTo(id, Card.PlayerHand, p, fk.ReasonJustMove, "yyfy_mj_sort", nil, false, p)
  end
end

--------------------------------------------------------------------------
-- 胡牌判定（非穷举）
--------------------------------------------------------------------------

local function canFormMelds(counts, need)
  if need <= 0 then return true end
  for t = 0, 33 do
    if counts[t] > 0 then
      -- 刻子
      if counts[t] >= 3 then
        counts[t] = counts[t] - 3
        if canFormMelds(counts, need - 1) then
          counts[t] = counts[t] + 3
          return true
        end
        counts[t] = counts[t] + 3
      end
      -- 顺子（仅数牌，数字 1~7 开头）
      if t <= 26 and (t % 9) <= 6 and counts[t + 1] > 0 and counts[t + 2] > 0 then
        counts[t] = counts[t] - 1
        counts[t + 1] = counts[t + 1] - 1
        counts[t + 2] = counts[t + 2] - 1
        if canFormMelds(counts, need - 1) then
          counts[t] = counts[t] + 1
          counts[t + 1] = counts[t + 1] + 1
          counts[t + 2] = counts[t + 2] + 1
          return true
        end
        counts[t] = counts[t] + 1
        counts[t + 1] = counts[t + 1] + 1
        counts[t + 2] = counts[t + 2] + 1
      end
      return false
    end
  end
  return true
end

local function isKokushi(tiles)
  local counts = countTable(tiles)
  if #tiles ~= 14 then return false end
  local sum, have = 0, 0
  for t = 0, 33 do
    if counts[t] > 0 then
      if not isYaochu(t) then return false end
      sum = sum + counts[t]
      have = have + 1
    end
  end
  return sum == 14 and have == 13
end

local function isSevenPairs(tiles)
  if #tiles ~= 14 then return false end
  local counts = countTable(tiles)
  local pairs = 0
  for t = 0, 33 do
    local c = counts[t]
    if c == 2 then
      pairs = pairs + 1
    elseif c ~= 0 then
      return false
    end
  end
  return pairs == 7
end

--- 判断当前手牌 + 副露是否可以和牌
---@param tiles integer[] 手牌类型数组（不含副露）
---@param melds table[] 副露列表（meld.type / meld.tiles）
---@return boolean
function M.CanWin(tiles, melds)
  local total = #tiles
  for _, m in ipairs(melds) do total = total + #m.tiles end
  if total ~= 14 then return false end
  if #melds == 0 then
    if isKokushi(tiles) then return true end
    if isSevenPairs(tiles) then return true end
  end
  local counts = countTable(tiles)
  local handMentsu = 4 - #melds
  if handMentsu < 0 then return false end
  -- 枚举雀头
  for t = 0, 33 do
    if counts[t] >= 2 then
      counts[t] = counts[t] - 2
      if canFormMelds(counts, handMentsu) then
        counts[t] = counts[t] + 2
        return true
      end
      counts[t] = counts[t] + 2
    end
  end
  return false
end

--- 计算听牌（等待牌集合）
---@return table  type -> true
function M.GetWaits(tiles, melds)
  local waits = {}
  for t = 0, 33 do
    local test = {}
    for _, tt in ipairs(tiles) do table.insert(test, tt) end
    table.insert(test, t)
    if M.CanWin(test, melds) then waits[t] = true end
  end
  return waits
end

-- 振听判定：自家牌河含有所听之牌
function M.Furiten(state, p, waits)
  local discards = state.discards[p.id] or {}
  for _, t in ipairs(discards) do
    if waits[t] then return true end
  end
  return false
end

-- 吃牌组合：返回所有包含弃牌 d 的顺子组合
---@param handTypes integer[]
---@param d integer 被切掉的牌类型
function M.GetChiCombos(handTypes_, d)
  local counts = countTable(handTypes_)
  local ret = {}
  local function tryAdd(a, b, c)
    if a < 0 or b < 0 or c < 0 then return end
    if a > 26 or b > 26 or c > 26 then return end
    if not (a == d or b == d or c == d) then return end
    -- 顺子必须同花色（万/筒/索），禁止如 8m9m 吃 1p 这类跨花色组合
    if math.floor(a / 9) ~= math.floor(b / 9) or math.floor(b / 9) ~= math.floor(c / 9) then return end
    local need = {}
    for _, t in ipairs{ a, b, c } do
      if t ~= d then need[t] = (need[t] or 0) + 1 end
    end
    for t, n in pairs(need) do
      if (counts[t] or 0) < n then return end
    end
    table.insert(ret, { a, b, c })
  end
  tryAdd(d - 2, d - 1, d)
  tryAdd(d - 1, d, d + 1)
  tryAdd(d, d + 1, d + 2)
  return ret
end

local function solveMentsu(counts, need, out)
  if need <= 0 then return true end
  for t = 0, 33 do
    if counts[t] > 0 then
      if counts[t] >= 3 then
        counts[t] = counts[t] - 3
        table.insert(out, { k = "tri", t = t, open = false })
        if solveMentsu(counts, need - 1, out) then return true end
        table.remove(out)
        counts[t] = counts[t] + 3
      end
      if t <= 26 and (t % 9) <= 6 and counts[t + 1] > 0 and counts[t + 2] > 0 then
        counts[t] = counts[t] - 1
        counts[t + 1] = counts[t + 1] - 1
        counts[t + 2] = counts[t + 2] - 1
        table.insert(out, { k = "seq", t = t, open = false })
        if solveMentsu(counts, need - 1, out) then return true end
        table.remove(out)
        counts[t] = counts[t] + 1
        counts[t + 1] = counts[t + 1] + 1
        counts[t + 2] = counts[t + 2] + 1
      end
      return false
    end
  end
  return true
end

--- 解析和牌形状，返回 { pair=雀头, mentsu=面子列表, kokushi=bool, seven=bool }
function M.GetForm(tiles, melds)
  if #melds == 0 then
    if isKokushi(tiles) then return { kokushi = true } end
    if isSevenPairs(tiles) then return { seven = true } end
  end
  local counts = countTable(tiles)
  local handMentsu = 4 - #melds
  if handMentsu < 0 then return nil end
  for t = 0, 33 do
    if counts[t] >= 2 then
      counts[t] = counts[t] - 2
      local out = {}
      if solveMentsu(counts, handMentsu, out) then
        local mentsu = {}
        for _, m in ipairs(melds) do
          if m.type == "chi" then
            table.insert(mentsu, { k = "seq", t = m.tiles[1], open = true })
          else
            local closed = (m.type == "kan_closed" or m.type == "kan_added")
            table.insert(mentsu, { k = "tri", t = m.tiles[1], open = not closed })
          end
        end
        for _, s in ipairs(out) do table.insert(mentsu, s) end
        counts[t] = counts[t] + 2
        return { pair = t, mentsu = mentsu }
      end
      counts[t] = counts[t] + 2
    end
  end
  return nil
end

--------------------------------------------------------------------------
-- 计分表
-- RON_TABLE[band][1]=子家被荣付点 [2]=庄家被荣付点（1.5 倍）
-- TSUMO_TABLE[band][1]=子付 [2]=庄付（庄自摸每人付 [2]）
--------------------------------------------------------------------------

local RON_TABLE = {
  { 1000, 1500 }, { 2000, 3000 }, { 3900, 5800 }, { 8000, 12000 },
  { 12000, 18000 }, { 16000, 24000 }, { 24000, 36000 }, { 32000, 48000 },
}
local TSUMO_TABLE = {
  { 300, 500 }, { 500, 1000 }, { 1000, 2000 }, { 2000, 4000 },
  { 3000, 6000 }, { 4000, 8000 }, { 6000, 12000 }, { 8000, 16000 },
}

local function getBand(han)
  if han <= 1 then return 1
  elseif han == 2 then return 2
  elseif han == 3 then return 3
  elseif han <= 5 then return 4
  elseif han <= 7 then return 5
  elseif han <= 10 then return 6
  elseif han <= 12 then return 7
  else return 8 end
end

--------------------------------------------------------------------------
-- 役种评估
--------------------------------------------------------------------------

local function allTypesOf(p, state)
  local ret = handTypes(p)
  for _, m in ipairs(state.melds[p.id] or {}) do
    for _, t in ipairs(m.tiles) do table.insert(ret, t) end
  end
  return ret
end

--- 评估和牌番种
---@param info table { tsumo, victim, winTile, haitei, houtei, rinshan, chankan, chiihou, tenhou }
---@param tilesOverride? integer[] 外部指定的手牌类型数组（荣时含被打出的弃牌），缺省用手牌
function M.EvalYaku(state, p, info, tilesOverride)
  local tiles = tilesOverride or handTypes(p)
  local melds = state.melds[p.id] or {}
  local form = M.GetForm(tiles, melds)
  local yaku = {}
  local han = 0

  if form and form.kokushi then
    return { yaku = { "yyfy_yk_kokushi" }, han = 13 }
  end

  local hasTri = function(t)
    for _, m in ipairs(form and form.mentsu or {}) do
      if m.k == "tri" and m.t == t then return true end
    end
    return false
  end

  -- 役满
  local yakuman = nil
  local winds = { 27, 28, 29, 30 }
  local windTri = 0
  for _, w in ipairs(winds) do if hasTri(w) then windTri = windTri + 1 end end
  if hasTri(31) and hasTri(32) and hasTri(33) then yakuman = "yyfy_yk_daisangen" end
  if windTri == 4 then yakuman = "yyfy_yk_daisuushi" end
  if windTri == 3 and table.contains(winds, form and form.pair or -1) then yakuman = "yyfy_yk_shousuushi" end
  if form and form.mentsu and #form.mentsu == 4 then
    local allClosed = true
    for _, m in ipairs(form.mentsu) do
      if m.k ~= "tri" or m.open then allClosed = false break end
    end
    if allClosed then yakuman = "yyfy_yk_suuankou" end
  end
  if info.tenhou then yakuman = "yyfy_yk_tenhou" end
  if info.chiihou then yakuman = "yyfy_yk_chiihou" end
  if yakuman then
    return { yaku = { yakuman }, han = 13 }
  end

  -- 立直 / 一发
  if state.riichi[p.id] then
    han = han + 1
    table.insert(yaku, "yyfy_yaku_riichi")
    if state.ippatsu[p.id] then
      han = han + 1
      table.insert(yaku, "yyfy_yaku_ippatsu")
    end
  end

  if form and form.seven then
    -- 七对子
    han = han + 2
    table.insert(yaku, "yyfy_yaku_chiitoi")
  elseif form then
    -- 门前清自摸
    if info.tsumo and #melds == 0 then
      han = han + 1
      table.insert(yaku, "yyfy_yaku_tsumo")
    end
    -- 平和
    if #melds == 0 then
      local pinhu = true
      for _, m in ipairs(form.mentsu) do
        if m.k ~= "seq" then pinhu = false break end
      end
      if pinhu then
        local pr = form.pair
        if pr < 27 and (pr % 9) ~= 0 and (pr % 9) ~= 8 then
          han = han + 1
          table.insert(yaku, "yyfy_yaku_pinhu")
        end
      end
    end
    -- 役牌（白发中 + 场风 + 自风）
    local yakuHaiCount = 0
    for _, t in ipairs{ 31, 32, 33 } do
      if hasTri(t) then yakuHaiCount = yakuHaiCount + 1 end
    end
    local roundWind = (state.round <= 4) and 27 or 28 -- 东场（第 1-4 局）/ 南场（第 5-8 局）
    if hasTri(roundWind) then yakuHaiCount = yakuHaiCount + 1 end -- 场风刻
    local dealerIdx = 1
    for i, q in ipairs(state.players) do
      if q == state.dealer then dealerIdx = i break end
    end
    local selfIdx = 1
    for i, q in ipairs(state.players) do
      if q == p then selfIdx = i break end
    end
    -- 自风：庄=東，逆时针依次南西北；与场风重合时只计一次
    local selfWind = 27 + (selfIdx - dealerIdx + 4) % 4
    if selfWind ~= roundWind and hasTri(selfWind) then yakuHaiCount = yakuHaiCount + 1 end
    if yakuHaiCount > 0 then
      han = han + yakuHaiCount
      table.insert(yaku, "yyfy_yaku_yakuhai")
    end
    -- 面子统计
    local seqCounts = {}
    local triCount, closedTri = 0, 0
    for _, m in ipairs(form.mentsu) do
      if m.k == "seq" then
        seqCounts[m.t] = (seqCounts[m.t] or 0) + 1
      else
        triCount = triCount + 1
        if not m.open then closedTri = closedTri + 1 end
      end
    end
    -- 三色同顺
    local sanshoku = 0
    for d = 0, 6 do
      local c0, c1, c2 = 0, 0, 0
      for _, m in ipairs(form.mentsu) do
        if m.k == "seq" and (m.t % 9) == d then
          local suit = math.floor(m.t / 9)
          if suit == 0 then c0 = c0 + 1 elseif suit == 1 then c1 = c1 + 1 else c2 = c2 + 1 end
        end
      end
      if c0 >= 1 and c1 >= 1 and c2 >= 1 then sanshoku = sanshoku + 1 end
    end
    if sanshoku > 0 then
      han = han + sanshoku * 2
      table.insert(yaku, "yyfy_yaku_sanshoku")
    end
    -- 三色同刻（万筒索相同数字的三组刻子，2 番）
    local sanshokuTri = 0
    for d = 0, 8 do
      local c0, c1, c2 = 0, 0, 0
      for _, m in ipairs(form.mentsu) do
        if m.k == "tri" and m.t <= 26 and (m.t % 9) == d then
          local suit = math.floor(m.t / 9)
          if suit == 0 then c0 = c0 + 1 elseif suit == 1 then c1 = c1 + 1 else c2 = c2 + 1 end
        end
      end
      if c0 >= 1 and c1 >= 1 and c2 >= 1 then sanshokuTri = sanshokuTri + 1 end
    end
    if sanshokuTri > 0 then
      han = han + sanshokuTri * 2
      table.insert(yaku, "yyfy_yaku_sanshoku_tri")
    end
    -- 一气通贯
    local ittsu = 0
    for suit = 0, 2 do
      local h123, h456, h789 = false, false, false
      for _, m in ipairs(form.mentsu) do
        if m.k == "seq" and math.floor(m.t / 9) == suit then
          local d = m.t % 9
          if d == 0 then h123 = true elseif d == 3 then h456 = true elseif d == 6 then h789 = true end
        end
      end
      if h123 and h456 and h789 then ittsu = ittsu + 1 end
    end
    if ittsu > 0 then
      han = han + ittsu * 2
      table.insert(yaku, "yyfy_yaku_ittsu")
    end
    -- 对对和
    if triCount == 4 then
      han = han + 2
      table.insert(yaku, "yyfy_yaku_toitoi")
    end
    -- 三暗刻
    if closedTri >= 3 then
      han = han + 2
      table.insert(yaku, "yyfy_yaku_sanankou")
    end
    -- 一盃口 / 二盃口（门前清）
    if #melds == 0 then
      local dup = 0
      for _, c in pairs(seqCounts) do
        if c == 2 then dup = dup + 1 end
        if c == 4 then dup = dup + 2 end
      end
      if dup >= 2 then
        han = han + 3
        table.insert(yaku, "yyfy_yaku_ryanpeikou")
      elseif dup == 1 then
        han = han + 1
        table.insert(yaku, "yyfy_yaku_iipeikou")
      end
    end
  end

  -- 全局牌役（荣时弃牌已并入 tiles，直接以 tiles + 副露 统计）
  local all = table.simpleClone(tiles)
  for _, m in ipairs(melds) do
    for _, t in ipairs(m.tiles) do table.insert(all, t) end
  end
  -- 断幺
  local tanyao = true
  for _, t in ipairs(all) do
    if isYaochu(t) then tanyao = false break end
  end
  if tanyao then
    han = han + 1
    table.insert(yaku, "yyfy_yaku_tanyao")
  end
  -- 混一色 / 清一色
  local suitsUsed = {}
  local hasHonor = false
  for _, t in ipairs(all) do
    if t >= 27 then hasHonor = true else suitsUsed[math.floor(t / 9)] = true end
  end
  local suitCount = 0
  for _ in pairs(suitsUsed) do suitCount = suitCount + 1 end
  if suitCount == 1 then
    if hasHonor then
      han = han + 3
      table.insert(yaku, "yyfy_yaku_honitsu")
    else
      han = han + 5
      table.insert(yaku, "yyfy_yaku_chinitsu")
    end
  end
  -- 混全带幺 / 纯全带幺
  if form and form.mentsu then
    local chanta, junchan = true, true
    for _, m in ipairs(form.mentsu) do
      if m.k == "seq" then
        local d = m.t % 9
        if d ~= 0 and d ~= 6 then chanta, junchan = false, false break end
      else
        local tt = m.t
        if tt >= 27 then
          junchan = false
        else
          local d = tt % 9
          if d ~= 0 and d ~= 8 then chanta, junchan = false, false break end
        end
      end
    end
    if chanta or junchan then
      local pr = form.pair
      if pr < 27 and (pr % 9) ~= 0 and (pr % 9) ~= 8 then
        chanta = false
        junchan = false
      elseif pr >= 27 then
        junchan = false
      end
    end
    if chanta then
      han = han + 1
      table.insert(yaku, "yyfy_yaku_chanta")
    end
    if junchan then
      han = han + 2
      table.insert(yaku, "yyfy_yaku_junchan")
    end
  end
  -- 特殊和牌方式
  if info.rinshan then
    han = han + 1
    table.insert(yaku, "yyfy_yaku_rinshan")
  end
  if info.haitei then
    han = han + 1
    table.insert(yaku, "yyfy_yaku_haitei")
  end
  if info.houtei then
    han = han + 1
    table.insert(yaku, "yyfy_yaku_houtei")
  end
  if info.chankan then
    han = han + 1
    table.insert(yaku, "yyfy_yaku_chankan")
  end
  -- 三杠子
  local kanCount = 0
  for _, m in ipairs(melds) do
    if m.type == "kan_open" or m.type == "kan_closed" or m.type == "kan_added" then kanCount = kanCount + 1 end
  end
  if kanCount >= 3 then
    han = han + 2
    table.insert(yaku, "yyfy_yaku_sankantsu")
  end

  -- 宝牌 / 里宝牌 / 赤宝牌：只加番，不算起胡役（无真役时仍为无役）
  local doraHan = 0
  for i = 1, state.dora_count do
    local ind = state.indicator[i]
    if ind then
      doraHan = doraHan + countType(all, nextDora(cardTypeOf(ind)))
    end
  end
  if doraHan > 0 then han = han + doraHan end
  if state.riichi[p.id] then
    local uraHan = 0
    for i = 5, 4 + state.dora_count do
      local ind = state.indicator[i]
      if ind then
        uraHan = uraHan + countType(all, nextDora(cardTypeOf(ind)))
      end
    end
    if uraHan > 0 then han = han + uraHan end
  end
  local akaHan = 0
  for _, t in ipairs(all) do
    if table.contains(AKA_TYPES, t) then akaHan = akaHan + 1 end
  end
  if akaHan > 0 then han = han + akaHan end

  if han <= 0 then han = 1 end -- 无番缚：0 番按 1 番
  return { yaku = yaku, han = han }
end

--- 判断玩家是否满足和牌资格：牌型成立 且 至少有一个起胡役
--- （宝牌/里宝牌/赤宝牌只加番不算役；如仅红宝牌无其他役则不能胡）
---@param info table 同 EvalYaku
---@param extraTile? integer 荣时被打出的弃牌类型（并入手牌后才有 14 张）
---@return boolean, table|nil
function M.CanSettle(state, p, info, extraTile)
  local tiles = handTypes(p)
  if extraTile then table.insert(tiles, extraTile) end
  if not M.CanWin(tiles, state.melds[p.id]) then return false end
  local ev = M.EvalYaku(state, p, info, tiles)
  if #ev.yaku == 0 then return false end
  return true, ev
end

--------------------------------------------------------------------------
-- 点数转移与结算
--------------------------------------------------------------------------

-- 转移点数并更新标记；若有玩家点数归零则击飞并结束游戏。
-- 返回 false 表示游戏已结束。
function M.Transfer(room, state, payments)
  for pid, delta in pairs(payments) do
    state.points[pid] = (state.points[pid] or 0) + delta
  end
  for _, p in ipairs(state.players) do
    room:setPlayerMark(p, "@yyfy_mj_points", state.points[p.id])
  end
  for _, p in ipairs(state.players) do
    if state.points[p.id] <= 0 then
      room:sendLog{ type = "#yyfy_mj_fly", arg = p._splayer:getScreenName(), toast = true }
      room:delay(2000)
      local winners = table.filter(room:getAlivePlayers(false), function(q) return q ~= p end)
      if #winners == 0 then winners = room:getAlivePlayers(false) end
      room:gameOver(winners)
      return false
    end
  end
  return true
end

function M.SettleWin(room, state, winner, info)
  -- 荣时弃牌尚未入手，需并入后才够 14 张，否则役判定会漏掉该面子
  local evalTiles
  if not info.tsumo and info.winTile then
    evalTiles = handTypes(winner)
    table.insert(evalTiles, info.winTile)
  end
  local ev = M.EvalYaku(state, winner, info, evalTiles)
  local band = getBand(ev.han)
  local payments = {}
  if info.tsumo then
    local y = TSUMO_TABLE[band][2]
    local x = TSUMO_TABLE[band][1]
    local gain = 0
    for _, p in ipairs(state.players) do
      if p ~= winner then
        -- 庄家自摸：每人付庄付（y）；子家自摸：庄付 y、其他子付 x
        local pay = (winner == state.dealer) and y or ((p == state.dealer) and y or x)
        payments[p.id] = -pay
        gain = gain + pay
      end
    end
    payments[winner.id] = gain
  else
    local victim = info.victim
    local pay = RON_TABLE[band][(victim == state.dealer) and 2 or 1]
    payments[victim.id] = -pay
    payments[winner.id] = pay
  end
  -- 立直棒
  for pid, _ in pairs(state.riichi_bets) do
    payments[pid] = (payments[pid] or 0) - 1000
    payments[winner.id] = payments[winner.id] + 1000
  end
  state.riichi_bets = {}
  -- 日志与展示（结算停顿数秒，让玩家看清和牌结果）
  room:sendLog{ type = "#yyfy_mj_win", arg = winner._splayer:getScreenName(), arg2 = ev.han, toast = true }
  room:delay(2000)
  local yakuText = table.concat(table.map(ev.yaku, function(k) return Fk:translate(k) end), "、")
  room:sendLog{ type = "#yyfy_mj_yaku", arg = yakuText, toast = true }
  -- 立直家胡牌：此时才揭晓里宝牌
  if state.riichi[winner.id] then
    local uraText = table.concat(uraDoraTexts(state), "、")
    room:setBanner("@yyfy_mj_dora", allDoraTexts(state, true))
    room:sendLog{ type = "#yyfy_mj_ura_log", arg = uraText, toast = true }
  end
  room:delay(3000)
  if not M.Transfer(room, state, payments) then return false end
  state.lastWinner = winner
  return true
end

--------------------------------------------------------------------------
-- 杠
--------------------------------------------------------------------------

-- 杠后处理：翻指示牌、活牌底移入王牌山、摸岭上
function M.OnKan(room, state, p)
  local skill_name = state.skill_name
  state.kan_count = state.kan_count + 1
  state.dora_count = math.min(state.dora_count + 1, 4)
  state.no_meld = false -- 杠属于副露，取消地和
  -- 活牌山底一张移入王牌山（指示堆末尾）
  if #state.live > 0 then
    table.insert(state.indicator, table.remove(state.live, #state.live))
  end
  -- 摸岭上
  if #state.rinshan > 0 then
    local id = table.remove(state.rinshan, 1)
    room:moveCardTo(id, Card.PlayerHand, p, fk.ReasonJustMove, skill_name, nil, false, p)
    state.last_drawn[p.id] = cardTypeOf(id)
    state.rinshan_pending = true
  end
  room:sendLog{ type = "#yyfy_mj_kan_log", arg = p._splayer:getScreenName(), toast = true }
  -- 更新指示牌 banner（文字显示表宝牌，如“3索”）
  room:setBanner("@yyfy_mj_dora", omoteDoraTexts(state))
  local newInd = state.indicator[state.dora_count]
  if newInd then
    room:sendLog{ type = "#yyfy_mj_dora_log", arg = Fk:translate(TYPE_TO_NAME[nextDora(cardTypeOf(newInd))]), toast = true }
  end
end

-- 抢杠检查：加杠前他家听这张牌则荣
function M.CheckChankan(room, state, kanPlayer, t)
  for _, q in ipairs(state.players) do
    if q ~= kanPlayer then
      local tiles = handTypes(q)
      table.insert(tiles, t)
      local waits = M.GetWaits(tiles, state.melds[q.id])
      if M.CanWin(tiles, state.melds[q.id]) and not M.Furiten(state, q, waits) then
        if q.id > 0 then
          if room:askToSkillInvoke(q, { skill_name = "yyfy_mj_ron", prompt = "#yyfy_mj_chankan_prompt" }) then
            return q
          end
        end
      end
    end
  end
  return nil
end

-- 副露询问：所有非弃牌真人统一烧条防暴露手牌信息，仅有权选择者弹窗询问；
-- 无权限者不弹窗、无需点任何按钮，请求在全部有权者回复后即结束并清除全场烧条。
-- 选项按其可发动的动作给出（荣/大明杠/碰/吃），随后按 荣 > 杠 > 碰 > 吃、
-- 同类按座次（弃牌者起）解析。
-- AI（p.id<0）不参与询问，直接贪心取优先级最高的可行动作。
-- 返回 "ron"（已结算）或 "ended" 或 { player=, kind=, combos= } 或 nil
function M.CheckClaims(room, state, discardingPlayer, dType)
  local order = seatOrderFrom(state, discardingPlayer)
  local nextP = nextSeat(state, discardingPlayer)
  local houtei = #state.live == 0

  -- 收集每个玩家（真人+AI）可发动的动作
  local askPlayers = {} -- 有动作的真人（需要选择）
  local focusPlayers = {} -- 所有非弃牌真人（统一烧条）
  local actions = {} -- p.id -> 可选动作列表（按优先级排序）
  local combosMap = {} -- p.id -> 吃组合
  local aiChoice = {} -- p.id -> AI 自动选择
  local anyAction = false
  for _, p in ipairs(order) do
    if p ~= discardingPlayer then
      local acts = {}
      -- 荣（须能胡、非振听、且至少有一个起胡役；弃牌并入手牌后才有 14 张）
      local tiles13 = handTypes(p)
      local waits = M.GetWaits(tiles13, state.melds[p.id])
      local tiles14 = table.simpleClone(tiles13)
      table.insert(tiles14, dType)
      if M.CanWin(tiles14, state.melds[p.id]) and not M.Furiten(state, p, waits)
        and M.CanSettle(state, p, { tsumo = false, houtei = houtei, winTile = dType }, dType) then
        table.insert(acts, "yyfy_mj_ron")
      end
      -- 大明杠
      if countType(handTypes(p), dType) >= 3 then
        table.insert(acts, "yyfy_mj_kan")
      end
      -- 碰
      if countType(handTypes(p), dType) >= 2 then
        table.insert(acts, "yyfy_mj_pon")
      end
      -- 吃（仅下家）
      if p == nextP then
        local combos = M.GetChiCombos(handTypes(p), dType)
        if #combos > 0 then
          table.insert(acts, "yyfy_mj_chi")
          combosMap[p.id] = combos
        end
      end
      if p.id > 0 then
        -- 所有真人统一烧条，避免暴露谁有权副露
        table.insert(focusPlayers, p)
        if #acts > 0 then
          table.insert(acts, "yyfy_mj_no_act") -- 有权者可主动选"不操作"放弃
          table.insert(askPlayers, p)
          actions[p.id] = acts
          anyAction = true
        end
      elseif #acts > 0 then
        -- AI：贪心取优先级最高的动作（荣 > 杠 > 碰 > 吃）
        aiChoice[p.id] = acts[1]
        anyAction = true
      end
    end
  end

  -- 无人可副露：不询问，清除残留烧条后直接过
  if not anyAction then
    room:notifyMoveFocus({}, "")
    return nil
  end

  local chosen = {}
  for pid, act in pairs(aiChoice) do chosen[pid] = act end

  -- 仅向有权选择的真人弹窗询问；无权者只烧条不弹窗、无需点任何按钮。
  -- Request 在全部有权者回复后立即结束（n=#askPlayers），随后清除全场烧条。
  if #askPlayers > 0 then
    local req = Request:new(askPlayers, "AskForChoices")
    req.focus_players = focusPlayers
    req.focus_text = "yyfy_mj_claim"
    req.receive_decode = false
    for _, p in ipairs(askPlayers) do
      local acts = actions[p.id]
      req:setData(p, {
        acts,           -- [1] 可选动作
        acts,           -- [2] 全部可选动作（UI 列表）
        { 1, 1 },       -- [3] 单选
        false,          -- [4] 不可取消
        "yyfy_mj_claim", -- [5] 技能名
        "#yyfy_mj_claim_prompt", -- [6] 提示
        false,          -- [7]
        true,           -- [8]
      })
    end
    req:ask()

    for _, p in ipairs(askPlayers) do
      local r = req:getResult(p)
      if type(r) == "table" and r[1] and r[1] ~= "" then chosen[p.id] = r[1] end
    end
  end
  -- 请求结束：清除全场烧条（含未参与请求的无权限者）
  room:notifyMoveFocus({}, "")

  -- 解析：荣 > 杠 > 碰 > 吃；同类按座次（弃牌者起，最近的优先）
  for _, p in ipairs(order) do
    if chosen[p.id] == "yyfy_mj_ron" then
      if not M.SettleWin(room, state, p, { tsumo = false, victim = discardingPlayer, houtei = houtei, winTile = dType }) then
        return "ended"
      end
      return "ron"
    end
  end
  for _, p in ipairs(order) do
    if chosen[p.id] == "yyfy_mj_kan" then return { player = p, kind = "kan" } end
  end
  for _, p in ipairs(order) do
    if chosen[p.id] == "yyfy_mj_pon" then return { player = p, kind = "pon" } end
  end
  if chosen[nextP.id] == "yyfy_mj_chi" then
    local combos = combosMap[nextP.id]
    if combos and #combos > 0 then
      return { player = nextP, kind = "chi", combos = combos }
    end
  end

  return nil
end

-- 执行副露（碰/大明杠/吃），返回副露的 meld；玩家选择"跳过"取消时返回 nil
function M.ApplyClaim(room, state, discardingPlayer, claim, dType)
  local p = claim.player
  local skill_name = state.skill_name
  local discardId = state.lastDiscard and state.lastDiscard.id
  local handIds = p:getCardIds("h")

  local function takeDiscard()
    room:moveCardTo(discardId, Card.PlayerSpecial, p, fk.ReasonJustMove, skill_name, "yyfy_mj_meld", true, p)
  end

  if claim.kind == "pon" then
    takeDiscard()
    local picked = {}
    -- 手牌含红五且张数 >= 3 时（如"两白一红"三张5），弹出选项框让玩家选哪两张碰（每组两张卡图）；否则自动取前两张
    local counts = countTable(handTypes(p))
    local hasAka = false
    for _, id in ipairs(handIds) do
      local c = Fk:getCardById(id)
      if c and cardTypeOf(id) == dType and c.name:find("yyfy_0", 1, true) then hasAka = true break end
    end
    if counts[dType] >= 3 and hasAka and p.id > 0 then
      -- 收集手牌中该类型的所有牌，生成两两一组的选择项（每组 = 碰出去的两张手牌）
      local ids = {}
      for _, id in ipairs(handIds) do
        if cardTypeOf(id) == dType then table.insert(ids, id) end
      end
      local groups = {}
      for i = 1, #ids - 1 do
        for j = i + 1, #ids do
          table.insert(groups, { ids[i], ids[j] })
        end
      end
      if #groups > 1 then
        local result = room:askToCustomDialog(p, {
          skill_name = "yyfy_mj_pon",
          component = {
            url = "packages/hidden-clouds/qml/YyfyMahjongMeldBox.qml",
            model = {
              url = "packages/hidden-clouds/qml/models/YyfyMahjongMeldModel.qml",
              prop = {
                groups = groups,
                prompt = "#yyfy_mj_pon_choose_prompt",
                kind = "pon",
                cancelable = true,
              },
            },
          },
        })
        if result and result.ids and result.ids[1] and result.ids[2] then
          picked = result.ids
        else
          -- 玩家点"跳过"反悔：取消副露，把已拿走的弃牌收回处理区
          room:moveCardTo(discardId, Card.Processing, nil, fk.ReasonJustMove, skill_name, nil, true, p)
          room:sendLog{ type = "#yyfy_mj_claim_cancel", arg = p._splayer:getScreenName(), toast = true }
          return nil
        end
      else
        picked = groups[1]
      end
    else
      for _, id in ipairs(handIds) do
        if cardTypeOf(id) == dType and #picked < 2 then
          table.insert(picked, id)
        end
      end
    end
    for _, id in ipairs(picked) do
      room:moveCardTo(id, Card.PlayerSpecial, p, fk.ReasonJustMove, skill_name, "yyfy_mj_meld", true, p)
    end
    local cards = { discardId, picked[1], picked[2] }
    table.insert(state.melds[p.id], { type = "pon", tiles = { dType, dType, dType }, cards = cards, concealed = false })
  elseif claim.kind == "kan" then
    takeDiscard()
    local picked = {}
    for _, id in ipairs(handIds) do
      if cardTypeOf(id) == dType and #picked < 3 then
        room:moveCardTo(id, Card.PlayerSpecial, p, fk.ReasonJustMove, skill_name, "yyfy_mj_meld", true, p)
        table.insert(picked, id)
      end
    end
    local cards = { discardId, picked[1], picked[2], picked[3] }
    table.insert(state.melds[p.id], { type = "kan_open", tiles = { dType, dType, dType, dType }, cards = cards, concealed = false })
    M.OnKan(room, state, p)
  elseif claim.kind == "chi" then
    -- 分组选项框：每个合法组合映射为一组（两张手牌 id），用卡图询问玩家用哪组吃牌
    local groups = {}
    for _, c in ipairs(claim.combos) do
      local need = {}
      for _, tt in ipairs(c) do
        if tt ~= dType then table.insert(need, tt) end
      end
      local ids = {}
      for _, nt in ipairs(need) do
        local fid = findHandIds(p, nt, 1)
        if fid[1] then table.insert(ids, fid[1]) end
      end
      if #ids == 2 then table.insert(groups, ids) end
    end
    local combo, picked
    if p.id > 0 and #groups > 1 then
      local result = room:askToCustomDialog(p, {
        skill_name = "yyfy_mj_chi",
        component = {
          url = "packages/hidden-clouds/qml/YyfyMahjongMeldBox.qml",
          model = {
            url = "packages/hidden-clouds/qml/models/YyfyMahjongMeldModel.qml",
            prop = {
              groups = groups,
              prompt = "#yyfy_mj_chi_choose_prompt",
              kind = "chi",
              cancelable = true,
            },
          },
        },
      })
      if result and result.ids and result.ids[1] and result.ids[2] then
        picked = result.ids
        -- 由两张手牌类型反推组合（need 乱序兼容）
        local t1, t2 = cardTypeOf(picked[1]), cardTypeOf(picked[2])
        for _, c in ipairs(claim.combos) do
          local need = {}
          for _, tt in ipairs(c) do
            if tt ~= dType then table.insert(need, tt) end
          end
          if (need[1] == t1 and need[2] == t2) or (need[1] == t2 and need[2] == t1) then
            combo = c
            break
          end
        end
      else
        -- 玩家点"跳过"反悔：弃牌仍在处理区，无需回收
        room:sendLog{ type = "#yyfy_mj_claim_cancel", arg = p._splayer:getScreenName(), toast = true }
        return nil
      end
    end
    if not combo then combo = claim.combos[1] end
    if not picked then
      -- 兜底（人机 / 单组 / 超时）：取与组合匹配的两张手牌
      picked = groups[1] or {}
      if #picked < 2 then
        picked = {}
        local needTypes = {}
        for _, tt in ipairs(combo) do
          if tt ~= dType then table.insert(needTypes, tt) end
        end
        for _, nt in ipairs(needTypes) do
          local fid = findHandIds(p, nt, 1)
          if fid[1] then table.insert(picked, fid[1]) end
        end
      end
    end
    takeDiscard()
    for _, id in ipairs(picked) do
      room:moveCardTo(id, Card.PlayerSpecial, p, fk.ReasonJustMove, skill_name, "yyfy_mj_meld", true, p)
    end
    local cards = { discardId }
    for _, id in ipairs(picked) do table.insert(cards, id) end
    table.insert(state.melds[p.id], { type = "chi", tiles = combo, cards = cards, concealed = false })
  end

  room:sendLog{ type = "#yyfy_mj_claim_log", arg = p._splayer:getScreenName(), toast = true }
  room:delay(700)
  state.no_meld = false -- 发生副露，取消地和
  return state.melds[p.id][#state.melds[p.id]]
end

--------------------------------------------------------------------------
-- 回合流程
--------------------------------------------------------------------------

-- 摸牌 + 自摸胡询问 + 四杠流局检查
-- 返回 "win" / "ended" / "no_tile" / "four_kan" / nil
local function doTurnDraw(room, state, turn, fromRinshan)
  local skill_name = state.skill_name
  local rinshan = fromRinshan
  local haitei = false
  if not fromRinshan then
    if #state.live == 0 then return "no_tile" end
    local id = table.remove(state.live, 1)
    room:moveCardTo(id, Card.PlayerHand, turn, fk.ReasonJustMove, skill_name, nil, false, turn)
    state.last_drawn[turn.id] = cardTypeOf(id)
    haitei = #state.live == 0
    rinshan = state.rinshan_pending
    state.rinshan_pending = false
    -- 已摸牌：立直后的下一巡摸牌完成，一发进入可成立状态
    if state.ippatsu[turn.id] == 1 then state.ippatsu[turn.id] = 2 end
    -- 只有第一巡摸牌才可能地和
    if state.first_draw[turn.id] then state.first_draw[turn.id] = false end
  end

  local chiihou = state.no_meld and state.first_draw[turn.id] and turn ~= state.dealer and not rinshan
  local info = { tsumo = true, haitei = haitei, rinshan = rinshan }
  if chiihou then info.chiihou = true end
  -- 和牌资格：牌型成立 + 至少一个起胡役（仅红宝牌等宝牌役不能胡）
  if M.CanSettle(state, turn, info) then
    if turn.id > 0 then
      local prompt = chiihou and "#yyfy_mj_chiihou_prompt" or "#yyfy_mj_tsumo_prompt"
      if room:askToSkillInvoke(turn, { skill_name = "yyfy_mj_tsumo", prompt = prompt }) then
        if not M.SettleWin(room, state, turn, info) then return "ended" end
        return "win"
      end
    else
      -- AI 自动自摸（同样必须有起胡役）
      if not M.SettleWin(room, state, turn, info) then return "ended" end
      return "win"
    end
  end

  if state.kan_count >= 4 then return "four_kan" end
  return nil
end

-- 打一整局，返回 "win" / "exhaustive" / nil（游戏已结束）
function M.PlayRound(room, state)
  local players = state.players
  room:sendLog{ type = "#yyfy_mj_round", arg = state.round, arg2 = state.dealer._splayer:getScreenName(), toast = true }
  room:delay(1300)

  -- 天和
  if M.CanWin(handTypes(state.dealer), state.melds[state.dealer.id]) then
    if M.SettleWin(room, state, state.dealer, { tsumo = true, tenhou = true, winTile = nil }) then
      return "win"
    end
    return nil
  end

  local turn = state.dealer
  room:setCurrent(turn)
  local needDraw = false -- 庄家起手 14 张，直接打牌

  while true do
    -- 摸牌（正常轮次）
    if needDraw then
      local r = doTurnDraw(room, state, turn, false)
      if r == "win" then return "win" end
      if r == "ended" then return nil end
      if r == "no_tile" or r == "four_kan" then
        if r == "four_kan" then
          room:sendLog{ type = "#yyfy_mj_four_kan", toast = true }
        end
        return M.DoExhaustive(room, state)
      end
    end

    -- 行动阶段（立直 / 暗杠 / 加杠）
    local actKan = false
    if turn.id > 0 and not state.riichi[turn.id] then
      -- 立直
      local waits = M.GetWaits(handTypes(turn), state.melds[turn.id])
      local canRiichi = #state.melds[turn.id] == 0 and state.points[turn.id] >= 1000 and next(waits) ~= nil
      if canRiichi then
        if room:askToSkillInvoke(turn, { skill_name = "yyfy_mj_riichi", prompt = "#yyfy_mj_riichi_prompt" }) then
          state.points[turn.id] = state.points[turn.id] - 1000
          state.riichi[turn.id] = true
          state.riichi_bets[turn.id] = true
          state.ippatsu[turn.id] = 1
          room:setPlayerMark(turn, "@yyfy_mj_points", state.points[turn.id])
          room:sendLog{ type = "#yyfy_mj_riichi_log", arg = turn._splayer:getScreenName(), toast = true }
        end
      end
      -- 杠（暗杠 / 加杠）
      if not state.riichi[turn.id] then
        local counts = countTable(handTypes(turn))
        local ankanTypes, addKanTypes = {}, {}
        for t = 0, 33 do
          if counts[t] >= 4 then table.insert(ankanTypes, t) end
        end
        for _, m in ipairs(state.melds[turn.id]) do
          if m.type == "pon" and counts[m.tiles[1]] >= 1 then
            table.insert(addKanTypes, m.tiles[1])
          end
        end
        if #ankanTypes > 0 or #addKanTypes > 0 then
          local choices = {}
          local trans = {}
          for _, t in ipairs(ankanTypes) do
            local key = "yyfy_mj_kan_act::" .. TYPE_TO_NAME[t]
            table.insert(choices, key)
            trans[key] = "暗杠 " .. Fk:translate(TYPE_TO_NAME[t])
          end
          for _, t in ipairs(addKanTypes) do
            local key = "yyfy_mj_kakan_act::" .. TYPE_TO_NAME[t]
            table.insert(choices, key)
            trans[key] = "加杠 " .. Fk:translate(TYPE_TO_NAME[t])
          end
          table.insert(choices, "yyfy_mj_no_act")
          Fk:loadTranslationTable(trans)
          local choice = room:askToChoice(turn, {
            choices = choices,
            skill_name = "yyfy_mj_kan",
            prompt = "#yyfy_mj_act_prompt",
            cancelable = false,
          })
          if choice ~= "yyfy_mj_no_act" then
            local isAdd = choice:find("yyfy_mj_kakan_act::") ~= nil
            local tName = choice:split("::")[2]
            local t = NAME_TO_TYPE[tName]
            if isAdd then
              -- 抢杠检查
              local chankanVictim = M.CheckChankan(room, state, turn, t)
              if chankanVictim then
                if M.SettleWin(room, state, chankanVictim, { tsumo = false, victim = turn, chankan = true, winTile = t }) then
                  return "win"
                end
                return nil
              end
              -- 执行加杠
              local handId = findHandIds(turn, t, 1)[1]
              room:moveCardTo(handId, Card.PlayerSpecial, turn, fk.ReasonJustMove, state.skill_name, "yyfy_mj_meld", true, turn)
              local meld = findMeldByType(state.melds[turn.id], t, "pon")
              meld.type = "kan_added"
              table.insert(meld.tiles, t)
              table.insert(meld.cards, handId)
              M.OnKan(room, state, turn)
            else
              -- 暗杠
              local ids = findHandIds(turn, t, 4)
              room:moveCardTo(ids, Card.PlayerSpecial, turn, fk.ReasonJustMove, state.skill_name, "yyfy_mj_meld", true, turn)
              table.insert(state.melds[turn.id], { type = "kan_closed", tiles = { t, t, t, t }, cards = ids, concealed = true })
              M.OnKan(room, state, turn)
            end
            actKan = true
          end
        end
      end
    end

    if actKan then
      -- 杠后摸岭上 + 岭上开花检查
      local r = doTurnDraw(room, state, turn, true)
      if r == "win" then return "win" end
      if r == "ended" then return nil end
      if r == "four_kan" then
        room:sendLog{ type = "#yyfy_mj_four_kan", toast = true }
        return M.DoExhaustive(room, state)
      end
    end

    -- 出牌前把手牌按麻将序重排（1234056789m…p…s 东南西北白发中）
    sortHandByMahjong(room, turn)

    -- 打牌：真人直接在手牌区点选一张牌，点确定打出（不弹中央选牌框，框架 AskForUseActiveSkill 手牌区选牌）
    local discardId
    if turn.id > 0 then
      local result = room:askToCards(turn, {
        max_num = 1,
        min_num = 1,
        cancelable = false,
        skill_name = "yyfy_mj_play",
        prompt = "#yyfy_mj_discard_prompt",
      })
      if type(result) == "table" and result[1] then
        discardId = result[1]
      end
    end
    if not discardId then
      -- 人机 / 超时兜底：默认模切
      local lastT = state.last_drawn[turn.id]
      local handIds = turn:getCardIds("h")
      discardId = nil
      for _, id in ipairs(handIds) do
        if lastT ~= nil and cardTypeOf(id) == lastT then discardId = id break end
      end
      if not discardId then discardId = handIds[1] end
      room:delay(500)
    end
    if not discardId then return nil end
    local dType = cardTypeOf(discardId)
    -- 上一张弃牌若仍在处理区，先移入其打出者的"已打出"牌堆（按顺序展示在角色头上）
    if state.lastDiscard then
      local prevId = state.lastDiscard.id
      if prevId and room:getCardArea(prevId) == Card.Processing then
        room:moveCardTo(prevId, Card.PlayerSpecial, state.lastDiscard.player, fk.ReasonJustMove, state.skill_name, "yyfy_mj_discard", true, state.lastDiscard.player)
      end
    end
    -- 弃牌先放入处理区，在桌面保持显示，直到下一张弃牌进入时才收走
    room:moveCardTo(discardId, Card.Processing, nil, fk.ReasonDiscard, state.skill_name, nil, true, turn)
    table.insert(state.discards[turn.id], dType)
    table.insert(state.discard_ids[turn.id], discardId)
    state.lastDiscard = { id = discardId, type = dType, player = turn }
    -- 立直者已摸过牌且本巡仍未和：一发失效
    if state.ippatsu[turn.id] == 2 then state.ippatsu[turn.id] = nil end
    room:sendLog{ type = "#yyfy_mj_discard_log", arg = turn._splayer:getScreenName(), arg2 = Fk:translate(TYPE_TO_NAME[dType]), toast = true }
    room:delay(600)

    -- 副露检查
    local claim = M.CheckClaims(room, state, turn, dType)
    if claim == "ron" then return "win" end
    if claim == "ended" then return nil end
    if claim ~= nil then
      local meld = M.ApplyClaim(room, state, turn, claim, dType)
      if meld == nil then
        -- 玩家点"跳过"取消了副露：按无人副露处理
        turn = nextSeat(state, turn)
        room:setCurrent(turn)
        needDraw = true
      else
        turn = claim.player
        room:setCurrent(turn)
        needDraw = false
        -- 大明杠：摸岭上并检查岭上开花 / 四杠散了
        if claim.kind == "kan" then
          local r = doTurnDraw(room, state, turn, true)
          if r == "win" then return "win" end
          if r == "ended" then return nil end
          if r == "four_kan" then
            room:sendLog{ type = "#yyfy_mj_four_kan", toast = true }
            return M.DoExhaustive(room, state)
          end
        end
        -- 有人副露，所有一发取消
        for pid, _ in pairs(state.ippatsu) do state.ippatsu[pid] = nil end
      end
    else
      turn = nextSeat(state, turn)
      room:setCurrent(turn)
      needDraw = true
    end
  end
end

-- 流局结算，返回 "exhaustive" 或 nil（游戏已结束）
function M.DoExhaustive(room, state)
  room:sendLog{ type = "#yyfy_mj_exhaustive", toast = true }
  room:delay(2500)
  local tenpaiList = M.SettleExhaustive(room, state)
  if tenpaiList == nil then return nil end
  state.renchan_dealer = table.contains(tenpaiList, state.dealer)
  return "exhaustive"
end

-- 流局听牌结算：1 听 / 2 听 / 3 听；并退立直棒
function M.SettleExhaustive(room, state)
  local payments = {}
  local tenpaiList = {}
  for _, p in ipairs(state.players) do
    local waits = M.GetWaits(handTypes(p), state.melds[p.id])
    if next(waits) then table.insert(tenpaiList, p) end
  end
  if #tenpaiList == 1 then
    local t = tenpaiList[1]
    for _, p in ipairs(state.players) do
      if p ~= t then
        payments[p.id] = (payments[p.id] or 0) - 1000
        payments[t.id] = (payments[t.id] or 0) + 1000
      end
    end
  elseif #tenpaiList == 2 then
    -- 两个没听者各付 1500，平分给两个听牌者（净额各 -1500 / +1500）
    for _, p in ipairs(state.players) do
      if not table.contains(tenpaiList, p) then
        for _, t in ipairs(tenpaiList) do
          payments[p.id] = (payments[p.id] or 0) - 750
          payments[t.id] = (payments[t.id] or 0) + 750
        end
      end
    end
  elseif #tenpaiList == 3 then
    for _, p in ipairs(state.players) do
      if not table.contains(tenpaiList, p) then
        for _, t in ipairs(tenpaiList) do
          payments[p.id] = (payments[p.id] or 0) - 1000
          payments[t.id] = (payments[t.id] or 0) + 1000
        end
      end
    end
  end
  -- 退立直棒
  for pid, _ in pairs(state.riichi_bets) do
    payments[pid] = (payments[pid] or 0) + 1000
  end
  state.riichi_bets = {}
  if next(payments) then
    if not M.Transfer(room, state, payments) then return nil end
  end
  return tenpaiList
end

function M.EndGameByPoints(room, state)
  -- 排出 1-4 位：点数降序；同分按东一局初始位次（東＞南＞西＞北）
  local sorted = table.simpleClone(state.players)
  table.sort(sorted, function(a, b)
    local pa, pb = state.points[a.id], state.points[b.id]
    if pa ~= pb then return pa > pb end
    return (state.wind_order[a.id] or 99) < (state.wind_order[b.id] or 99)
  end)
  room:gameOver(sorted)
end

--------------------------------------------------------------------------
-- 建牌山 / 发牌 / 开局 / 重开
--------------------------------------------------------------------------

-- 洗牌并分割活牌山与王牌山（王牌山 14 张：前 4 岭上，其后 8 张指示牌）
function M.BuildWalls(room, state)
  local all = table.simpleClone(room.draw_pile)
  room:shuffleTable(all)
  state.live = table.slice(all, 1, 123)          -- 活牌 122 张（顶在前）
  local rest = {}
  for i = 136, 123, -1 do table.insert(rest, all[i]) end -- 王牌山 14 张（岭上在前）
  state.rinshan = table.slice(rest, 1, 5)        -- 岭上 4 张
  state.indicator = table.slice(rest, 5, 13)     -- 指示牌 8 张（前 4 表指示，后 4 里指示）
  room:setBanner("@yyfy_mj_dora", omoteDoraTexts(state))
  room:sendLog{ type = "#yyfy_mj_dora_log", arg = Fk:translate(TYPE_TO_NAME[nextDora(cardTypeOf(state.indicator[1]))]), toast = true }
end

local function dealTo(state, p, n)
  local room = state.room
  for _ = 1, n do
    if #state.live == 0 then break end
    local id = table.remove(state.live, 1)
    room:moveCardTo(id, Card.PlayerHand, p, fk.ReasonJustMove, state.skill_name, nil, false, p)
  end
end

-- 发牌：每人 13 张，庄家 14 张
function M.DealInitial(room, state)
  for _ = 1, 3 do
    for _, p in ipairs(state.players) do dealTo(state, p, 4) end
  end
  for _, p in ipairs(state.players) do dealTo(state, p, 1) end
  dealTo(state, state.dealer, 1)
end

-- 更新庄家标记（UI 上明确显示当前庄家，随连庄/换庄同步）
local function updateDealerMark(room, state)
  for _, p in ipairs(state.players) do
    room:setPlayerMark(p, "@yyfy_mj_dealer", p == state.dealer and 1 or 0)
  end
end

-- 更新身份：整场游戏不结束、不会重新分发身份卡，因此在每个小局开始时手动
-- 重设身份（新庄=主公 lord，其余=反贼 rebel），让 UI 上的主公身份随换庄变化。
local function updateRoles(room, state)
  for _, p in ipairs(state.players) do
    room:setPlayerProperty(p, "role", p == state.dealer and "lord" or "rebel")
  end
end

-- 重开一局：清场、回收牌、重置状态、重新建山发牌
function M.RestartRound(room, state)
  local skill_name = state.skill_name
  for _, p in ipairs(state.players) do
    p:throwAllCards("h")
    -- 回收副露牌堆（PlayerSpecial 源区须用 moveCardTo 而非 changeCardArea）
    local pile = p:getPile("yyfy_mj_meld")
    if #pile > 0 then room:moveCardTo(pile, Card.DrawPile, nil, fk.ReasonJustMove, skill_name) end
    room:setPlayerPile(p, "yyfy_mj_meld", {})
    -- 回收"已打出"牌堆
    local dpile = p:getPile("yyfy_mj_discard")
    if #dpile > 0 then room:moveCardTo(dpile, Card.DrawPile, nil, fk.ReasonJustMove, skill_name) end
    room:setPlayerPile(p, "yyfy_mj_discard", {})
    state.discards[p.id] = {}
    state.discard_ids[p.id] = {}
    state.melds[p.id] = {}
    state.riichi[p.id] = nil
    state.ippatsu[p.id] = nil
    state.last_drawn[p.id] = nil
    state.first_draw[p.id] = true
  end
  -- 回收处理区（弃牌展示区）
  local proc = table.simpleClone(room.processing_area)
  if #proc > 0 then room:moveCardTo(proc, Card.DrawPile, nil, fk.ReasonJustMove, skill_name) end
  local discard = table.simpleClone(room.discard_pile)
  if #discard > 0 then room:changeCardArea(discard, Card.DrawPile) end
  state.lastDiscard = nil
  state.dora_count = 1
  state.kan_count = 0
  state.rinshan_pending = false
  state.no_meld = true
  M.BuildWalls(room, state)
  M.DealInitial(room, state)
  return true
end

-- 初始化整局（首局）：清场 + 检查牌堆 + 初始化状态 + 建山发牌
function M.Init(room, players, skill_name)
  for _, p in ipairs(players) do
    p:throwAllCards("hej")
  end
  local discard = table.simpleClone(room.discard_pile)
  if #discard > 0 then room:changeCardArea(discard, Card.DrawPile) end
  if #room.draw_pile < 100 then
    room:sendLog{ type = "#yyfy_mj_missing_tile", toast = true }
    room:delay(2000)
    room:gameOver("")
    return nil
  end

  -- 随机东起：庄家为主公（lord），其余为反贼
  local dealer = players[1]
  for _, p in ipairs(players) do
    if p.role == "lord" then dealer = p break end
  end

  local state = {
    room = room,
    players = players,
    skill_name = skill_name,
    dealer = dealer,
    round = 1,
    points = {},
    discards = {},
    discard_ids = {},
    melds = {},
    riichi = {},
    riichi_bets = {},
    ippatsu = {},
    last_drawn = {},
    live = {},
    rinshan = {},
    indicator = {},
    dora_count = 1,
    kan_count = 0,
    rinshan_pending = false,
    no_meld = true,
    first_draw = {},
    renchan_dealer = false,
    renchan_count = 0,
    lastWinner = nil,
    lastDiscard = nil,
    wind_order = {}, -- 东一局初始位次（東1<南2<西3<北4），用于同分排名
  }
  for i, p in ipairs(players) do
    state.points[p.id] = 25000
    state.discards[p.id] = {}
    state.discard_ids[p.id] = {}
    state.melds[p.id] = {}
    state.first_draw[p.id] = true
    state.wind_order[p.id] = i
    room:setPlayerMark(p, "@yyfy_mj_points", 25000)
  end
  room:setTag("yyfy_mj_state", state)
  updateDealerMark(room, state)
  updateRoles(room, state)
  M.BuildWalls(room, state)
  M.DealInitial(room, state)
  return state
end

--------------------------------------------------------------------------
-- 主流程
--------------------------------------------------------------------------

function M.Run(room, players, skill_name)
  local state = M.Init(room, players, skill_name)
  if not state then return end
  local guard = 0
  while true do
    guard = guard + 1
    if guard > 30 then
      M.EndGameByPoints(room, state)
      return
    end
    local result = M.PlayRound(room, state)
    if result == nil then return end -- 已结束（击飞等）

    -- 局后：连庄 / 换庄（用 id 比较，避免对象引用歧义）
    if result == "win" then
      if state.lastWinner and state.lastWinner.id == state.dealer.id then
        state.renchan_count = state.renchan_count + 1 -- 庄家和牌连庄
        room:sendLog{ type = "#yyfy_mj_renchan", arg = state.dealer._splayer:getScreenName(), toast = true }
      else
        state.renchan_count = 0
        local oldDealer = state.dealer
        state.dealer = nextSeat(state, state.dealer)
        state.round = state.round + 1
        room:sendLog{ type = "#yyfy_mj_dealer_change", arg = oldDealer._splayer:getScreenName(), arg2 = state.dealer._splayer:getScreenName(), toast = true }
      end
    else
      if state.renchan_dealer then
        state.renchan_count = state.renchan_count + 1 -- 流局且庄家听牌则连庄
        room:sendLog{ type = "#yyfy_mj_renchan", arg = state.dealer._splayer:getScreenName(), toast = true }
      else
        state.renchan_count = 0
        local oldDealer = state.dealer
        state.dealer = nextSeat(state, state.dealer)
        state.round = state.round + 1
        room:sendLog{ type = "#yyfy_mj_dealer_change", arg = oldDealer._splayer:getScreenName(), arg2 = state.dealer._splayer:getScreenName(), toast = true }
      end
    end
    state.renchan_dealer = false
    state.lastWinner = nil
    updateDealerMark(room, state)
    updateRoles(room, state)
    room:delay(1800) -- 让玩家看清连庄/换庄信息再进入下一小局

    -- 半庄两圈：东场 4 局 + 南场 4 局，共 8 局
    if state.round > 8 then
      M.EndGameByPoints(room, state)
      return
    end
    M.RestartRound(room, state)
  end
end

return M

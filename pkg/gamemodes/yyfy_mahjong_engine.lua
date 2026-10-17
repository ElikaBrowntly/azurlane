-- SPDX-License-Identifier: GPL-3.0-or-later
-- 夜隐浮云·麻将模式核心引擎
-- 规则概要（雀魂/立直麻将）：
--   三赤、有击飞、无古役、无番缚、有振听、有食断、有立直
--   四人游戏，初始 25000 点；西入开关（RULES.seiu）见文件开头规则开关表：
--     开启则半庄（南四过庄）后无人达 30000 续战西场/北场，每局结束立即判定无刷分，最多至北四；
--     关闭则东场 4 局 + 南场 4 局，round>8 按点数判胜
--   庄家随机东起（主公），逆时针行牌，门风随庄家旋转（庄家门风恒为东）、
--   场风按局数取东/南/西/北，均计入起胡役
--   牌堆 136 张：数牌 108（含红五三张）+ 字牌 28
-- 主入口：M.Run(room, players, skill_name)，同步阻塞驱动整局游戏
-- 对局状态持久化在 room:setTag("yyfy_mj_state", state)

local M = {}

--------------------------------------------------------------------------
-- 规则开关（地方规则系统）
-- 通过组合各开关状态形成不同的预设规则。
--------------------------------------------------------------------------
local RULES = {
  -- 西入：半庄（南四过庄）后若无人达到 30000 点，则由最初庄家续坐西一局
  -- （门风仍东、场风转西），此后每局结束立即检查，有人达 30000 即终局（无刷分），
  -- 最多打到北四（第 16 局）强制结束。
  seiu = true,
  -- 食断（食い断）：副露后仍可成立断幺九。关闭后，有副露时断幺九不计番（不能作为起胡役）。
  kuitan = true,
  -- 尾巡立直：是否允许在"已无下一次摸牌机会"的尾巡立直。默认不允许（置 true 为允许）。
  tailRiichi = false,
}

-- 役满权重累计（单倍=1，双倍=2，复合役满求和），用于计算倍数与结算总分
local function yakumanWeightSum(list)
  local n = 0
  for _, y in ipairs(list or {}) do n = n + (y.weight or 1) end
  return n
end

local function addYakuman(list, key, weight)
  table.insert(list, { key = key, weight = weight or 1 })
end

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
-- 注意：必须原地（hand→hand）重排，不能借道 Card.Processing（公共处理区），
-- 否则会把自家手牌短暂暴露给其他玩家，且客户端手牌区会出现"牌被扔出去"的异常表现
local function sortHandByMahjong(room, p)
  local ids = p:getCardIds("h")
  if #ids < 2 then return end
  table.sort(ids, function(a, b)
    local ka, kb = mahjongSortKey(a), mahjongSortKey(b)
    if ka ~= kb then return ka < kb end
    return a < b
  end)
  -- 一次性原地重排（hand→hand）：服务端按"依次取出后追加"的规则处理，
  -- 客户端按 move.ids 的新顺序重建手牌，最终顺序即为排序结果
  room:moveCards({
    ids = ids,
    from = p,
    to = p,
    toArea = Card.PlayerHand,
    moveReason = fk.ReasonJustMove,
    skillName = "yyfy_mj_sort",
    proposer = p,
  })
end

-- 本轮新摸的牌在手牌上的"新摸"标记（仅摸牌者本人可见）
local NEW_DRAW_MARK = "@@yyfy_newDraw-inhand"

local function markNewDraw(room, state, p)
  local id = state.new_draw_id[p.id]
  if not id then return end
  local card = Fk:getCardById(id)
  if card then room:setCardMark(card, NEW_DRAW_MARK, 1) end
end

local function clearNewDrawMark(room, state, p)
  local id = state.new_draw_id[p.id]
  state.new_draw_id[p.id] = nil
  if not id then return end
  local card = Fk:getCardById(id)
  if card then room:setCardMark(card, NEW_DRAW_MARK, 0) end
end

-- 手牌上的"宝牌"标记：仅标注表宝牌类型（里宝牌与红宝牌不标）
local DORA_MARK = "@@yyfy_dora-inhand"

-- 当前表宝牌类型集合
local function omoteDoraTypes(state)
  local set = {}
  for i = 1, state.dora_count do
    local ind = state.indicator[i]
    if ind then set[nextDora(cardTypeOf(ind))] = true end
  end
  return set
end

-- 刷新某玩家手牌上的"宝牌"标记
local function refreshDoraMarks(room, state, p)
  local set = omoteDoraTypes(state)
  for _, id in ipairs(p:getCardIds("h")) do
    local card = Fk:getCardById(id)
    if card then
      room:setCardMark(card, DORA_MARK, set[cardTypeOf(id)] and 1 or 0)
    end
  end
end

-- 刷新所有玩家手牌上的"宝牌"标记（翻新表宝牌后调用）
local function refreshAllDoraMarks(room, state)
  for _, p in ipairs(state.players) do refreshDoraMarks(room, state, p) end
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

-- 国士无双十三面：和牌前的 13 张恰为十三种幺九牌各一张（十三面听）
local function isKokushiJuusan(tiles, winTile)
  if winTile == nil then return false end
  local rest = table.simpleClone(tiles)
  local removed = false
  for i, t in ipairs(rest) do
    if t == winTile and not removed then
      table.remove(rest, i)
      removed = true
      break
    end
  end
  if #rest ~= 13 then return false end
  local counts = countTable(rest)
  for t = 0, 33 do
    if isYaochu(t) then
      if counts[t] ~= 1 then return false end
    elseif counts[t] ~= 0 then
      return false
    end
  end
  return true
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

-- 九莲宝灯：门前清、清一色，牌型为 1112345678999 + 任意一张同花色数牌
local function isChuuren(tiles)
  if #tiles ~= 14 then return false end
  if tiles[1] >= 27 then return false end
  local suit = math.floor(tiles[1] / 9)
  local counts = countTable(tiles)
  for t = 0, 33 do
    if t >= 27 or math.floor(t / 9) ~= suit then
      if counts[t] ~= 0 then return false end
    end
  end
  local base = suit * 9
  if counts[base] < 3 or counts[base + 8] < 3 then return false end
  for d = 1, 7 do
    if counts[base + d] < 1 then return false end
  end
  return true
end

-- 纯正九莲宝灯：和牌前的 13 张恰为 1112345678999（九面听）
local function isJunseiChuuren(tiles, winTile)
  if winTile == nil then return false end
  local rest = table.simpleClone(tiles)
  local removed = false
  for i, t in ipairs(rest) do
    if t == winTile and not removed then
      table.remove(rest, i)
      removed = true
      break
    end
  end
  if #rest ~= 13 then return false end
  if rest[1] >= 27 then return false end
  local suit = math.floor(rest[1] / 9)
  local counts = countTable(rest)
  for t = 0, 33 do
    if t >= 27 or math.floor(t / 9) ~= suit then
      if counts[t] ~= 0 then return false end
    end
  end
  local base = suit * 9
  if counts[base] ~= 3 or counts[base + 8] ~= 3 then return false end
  for d = 1, 7 do
    if counts[base + d] ~= 1 then return false end
  end
  return true
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

--- 立直可弃牌：门前清下，弃掉某张牌后仍能听牌的那些牌类型
---@param tiles integer[] 摸牌后的手牌（14 张）
---@param melds table[]
---@return table  type -> true
function M.RiichiDiscardables(tiles, melds)
  local ret = {}
  local counts = countTable(tiles)
  for t = 0, 33 do
    if counts[t] > 0 then
      local rest = {}
      local removed = false
      for _, tt in ipairs(tiles) do
        if tt == t and not removed then removed = true else table.insert(rest, tt) end
      end
      if next(M.GetWaits(rest, melds)) ~= nil then ret[t] = true end
    end
  end
  return ret
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

-- 场风：第 1-4 局东场(27)、5-8 局南场(28)、9-12 局西场(29)、13-16 局北场(30)
local function roundWindOf(round)
  local field = math.floor((round - 1) / 4)
  return 27 + math.min(field, 3)
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

-- 平和判定：门前清、四面子全为顺子、雀头非役牌（三元牌/场风/自风），
-- 且胡牌张必须是顺子的两面听（不能是边张/坎张/双碰/单骑）。
-- 多面听（高目/低目）按实际胡到的那张牌判定。
local function isPinfu(tiles, winTile, roundWind, selfWind)
  if winTile == nil or #tiles ~= 14 then return false end
  local forbidden = { [31] = true, [32] = true, [33] = true, [roundWind] = true, [selfWind] = true }
  local counts = countTable(tiles)

  local function solve(need, winOk)
    if need == 0 then return winOk end
    local t
    for i = 0, 33 do
      if counts[i] > 0 then t = i break end
    end
    if t == nil then return false end
    for s = t - 2, t do
      if s >= 0 and (s % 9) <= 6 and counts[s] > 0 and counts[s + 1] > 0 and counts[s + 2] > 0 then
        local ok = winOk
        if not ok then
          -- 胡牌张为该顺子的下端（余 s+1,s+2 两面听 拼 s 或 s+3）或上端（余 s,s+1 拼 s-1 或 s+2）才算两面听
          if winTile == s and (s % 9) <= 5 then
            ok = true
          elseif winTile == s + 2 and (s % 9) >= 1 then
            ok = true
          end
        end
        counts[s] = counts[s] - 1
        counts[s + 1] = counts[s + 1] - 1
        counts[s + 2] = counts[s + 2] - 1
        local r = solve(need - 1, ok)
        counts[s] = counts[s] + 1
        counts[s + 1] = counts[s + 1] + 1
        counts[s + 2] = counts[s + 2] + 1
        if r then return true end
      end
    end
    return false
  end

  for pt = 0, 33 do
    if counts[pt] >= 2 and not forbidden[pt] then
      counts[pt] = counts[pt] - 2
      local r = solve(4, false)
      counts[pt] = counts[pt] + 2
      if r then return true end
    end
  end
  return false
end

--- 评估和牌番种
---@param info table { tsumo, victim, winTile, haitei, houtei, rinshan, chankan, chiihou, tenhou }
---@param tilesOverride? integer[] 外部指定的手牌类型数组（荣时含被打出的弃牌），缺省用手牌
function M.EvalYaku(state, p, info, tilesOverride)
  local tiles = tilesOverride or handTypes(p)
  local melds = state.melds[p.id] or {}
  local form = M.GetForm(tiles, melds)
  local yaku, dora = {}, {}
  local han = 0
  -- 逐条记录役种与番数（结算界面按顺序展示）；dora 类只加番、不算起胡役
  local function addYaku(key, val)
    han = han + val
    table.insert(yaku, { key = key, han = val })
  end
  -- 副露减番：三色同顺/三色同刻/一气通贯/混一色/清一色，玩家有任何副露均 -1 番
  local openPenalty = (#melds > 0) and -1 or 0

  if form and form.kokushi then
    -- 国士无双：十三面听为双倍役满；天和/地和可与之复合
    local yaks = {}
    if isKokushiJuusan(tiles, info.winTile) then
      addYakuman(yaks, "yyfy_yk_kokushi_juusan", 2)
    else
      addYakuman(yaks, "yyfy_yk_kokushi")
    end
    if info.tenhou then addYakuman(yaks, "yyfy_yk_tenhou") end
    if info.chiihou then addYakuman(yaks, "yyfy_yk_chiihou") end
    return { yaku = {}, dora = {}, yakuman = yaks, han = 13 * yakumanWeightSum(yaks) }
  end

  local hasTri = function(t)
    for _, m in ipairs(form and form.mentsu or {}) do
      if m.k == "tri" and m.t == t then return true end
    end
    return false
  end

  -- 场风 / 自风（平和雀头判定与役牌判定都需用到）
  local roundWind = roundWindOf(state.round) -- 东场 / 南场 / 西场 / 北场
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

  -- 全牌类型（手牌 + 副露；荣时弃牌已并入 tiles），供字一色等全局判定使用
  local all = table.simpleClone(tiles)
  for _, m in ipairs(melds) do
    for _, t in ipairs(m.tiles) do table.insert(all, t) end
  end

  -- 役满：可复合，逐条收集（每条带权重，用于显示"役满/两倍役满/N倍役满"）
  local yaks = {}
  local winds = { 27, 28, 29, 30 }
  local windTri = 0
  for _, w in ipairs(winds) do if hasTri(w) then windTri = windTri + 1 end end
  if hasTri(31) and hasTri(32) and hasTri(33) then addYakuman(yaks, "yyfy_yk_daisangen") end
  if windTri == 4 then
    addYakuman(yaks, "yyfy_yk_daisuushi")
  elseif windTri == 3 and table.contains(winds, form and form.pair or -1) then
    addYakuman(yaks, "yyfy_yk_shousuushi")
  end
  if form and form.mentsu and #form.mentsu == 4 then
    local allClosed = true
    for _, m in ipairs(form.mentsu) do
      if m.k ~= "tri" or m.open then allClosed = false break end
    end
    if allClosed then
      -- 四暗刻单骑（双倍役满）：和牌张恰为雀头（单骑听）
      if info.winTile and form.pair == info.winTile then
        addYakuman(yaks, "yyfy_yk_suuankou_tanki", 2)
      else
        addYakuman(yaks, "yyfy_yk_suuankou")
      end
    end
  end
  -- 字一色：全部由字牌组成
  local allHonor = true
  for _, t in ipairs(all) do if t < 27 then allHonor = false break end end
  if allHonor then addYakuman(yaks, "yyfy_yk_tsuuiisou") end
  -- 九莲宝灯（门前清、清一色）；纯正九莲宝灯为双倍役满
  if #melds == 0 and isChuuren(all) then
    if isJunseiChuuren(all, info.winTile) then
      addYakuman(yaks, "yyfy_yk_junsei_chuuren", 2)
    else
      addYakuman(yaks, "yyfy_yk_chuuren")
    end
  end
  if info.tenhou then addYakuman(yaks, "yyfy_yk_tenhou") end
  if info.chiihou then addYakuman(yaks, "yyfy_yk_chiihou") end
  if #yaks > 0 then
    return { yaku = {}, dora = {}, yakuman = yaks, han = 13 * yakumanWeightSum(yaks) }
  end

  -- 立直 / 两立直 / 一发
  if state.riichi[p.id] then
    if state.double_riichi[p.id] then
      addYaku("yyfy_yaku_daburu_riichi", 2)
    else
      addYaku("yyfy_yaku_riichi", 1)
    end
    if state.ippatsu[p.id] then
      addYaku("yyfy_yaku_ippatsu", 1)
    end
  end

  if form and form.seven then
    -- 七对子
    addYaku("yyfy_yaku_chiitoi", 2)
  elseif form then
    -- 门前清自摸
    if info.tsumo and #melds == 0 then
      addYaku("yyfy_yaku_tsumo", 1)
    end
    -- 平和：门前清、四面子全顺子、雀头非役牌（三元牌/场风/自风）、胡牌张为两面听
    if #melds == 0 and isPinfu(tiles, info.winTile, roundWind, selfWind) then
      addYaku("yyfy_yaku_pinhu", 1)
    end
    -- 役牌（白发中 + 场风 + 自风）
    local yakuHaiCount = 0
    for _, t in ipairs{ 31, 32, 33 } do
      if hasTri(t) then yakuHaiCount = yakuHaiCount + 1 end
    end
    if hasTri(roundWind) then yakuHaiCount = yakuHaiCount + 1 end -- 场风刻
    if selfWind ~= roundWind and hasTri(selfWind) then yakuHaiCount = yakuHaiCount + 1 end
    if yakuHaiCount > 0 then
      addYaku("yyfy_yaku_yakuhai", yakuHaiCount)
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
      addYaku("yyfy_yaku_sanshoku", sanshoku * 2 + openPenalty)
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
      addYaku("yyfy_yaku_sanshoku_tri", sanshokuTri * 2 + openPenalty)
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
      addYaku("yyfy_yaku_ittsu", ittsu * 2 + openPenalty)
    end
    -- 对对和
    if triCount == 4 then
      addYaku("yyfy_yaku_toitoi", 2)
    end
    -- 三暗刻
    if closedTri >= 3 then
      addYaku("yyfy_yaku_sanankou", 2)
    end
    -- 一杯口 / 二杯口（门前清）
    if #melds == 0 then
      local dup = 0
      for _, c in pairs(seqCounts) do
        if c == 2 then dup = dup + 1 end
        if c == 4 then dup = dup + 2 end
      end
      if dup >= 2 then
        addYaku("yyfy_yaku_ryanpeikou", 3)
      elseif dup == 1 then
        addYaku("yyfy_yaku_iipeikou", 1)
      end
    end
  end

  -- 全局牌役（荣时弃牌已并入 tiles，直接以 tiles + 副露 统计；all 已在上方算出）
  -- 断幺（食断开关：关闭后，有副露时断幺九不计番、不能作为起胡役）
  local tanyao = true
  for _, t in ipairs(all) do
    if isYaochu(t) then tanyao = false break end
  end
  if tanyao and (RULES.kuitan or #melds == 0) then
    addYaku("yyfy_yaku_tanyao", 1)
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
      addYaku("yyfy_yaku_honitsu", 3 + openPenalty)
    else
      addYaku("yyfy_yaku_chinitsu", 5 + openPenalty)
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
      addYaku("yyfy_yaku_chanta", 1)
    end
    if junchan then
      addYaku("yyfy_yaku_junchan", 2)
    end
  end
  -- 特殊和牌方式
  if info.rinshan then
    addYaku("yyfy_yaku_rinshan", 1)
  end
  if info.haitei then
    addYaku("yyfy_yaku_haitei", 1)
  end
  if info.houtei then
    addYaku("yyfy_yaku_houtei", 1)
  end
  if info.chankan then
    addYaku("yyfy_yaku_chankan", 1)
  end
  -- 三杠子
  local kanCount = 0
  for _, m in ipairs(melds) do
    if m.type == "kan_open" or m.type == "kan_closed" or m.type == "kan_added" then kanCount = kanCount + 1 end
  end
  if kanCount >= 3 then
    addYaku("yyfy_yaku_sankantsu", 2)
  end

  -- 宝牌 / 里宝牌 / 赤宝牌：只加番，不算起胡役（无真役时仍为无役）
  -- 结算界面需要逐条展示，故分别记入 dora 列表
  local doraHan = 0
  for i = 1, state.dora_count do
    local ind = state.indicator[i]
    if ind then
      doraHan = doraHan + countType(all, nextDora(cardTypeOf(ind)))
    end
  end
  if doraHan > 0 then
    han = han + doraHan
    table.insert(dora, { key = "yyfy_yaku_dora", han = doraHan })
  end
  if state.riichi[p.id] then
    local uraHan = 0
    for i = 5, 4 + state.dora_count do
      local ind = state.indicator[i]
      if ind then
        uraHan = uraHan + countType(all, nextDora(cardTypeOf(ind)))
      end
    end
    if uraHan > 0 then
      han = han + uraHan
      table.insert(dora, { key = "yyfy_yaku_ura", han = uraHan })
    end
  end
  -- 赤宝牌：按牌名（yyfy_0m/p/s）识别，与普通五区分开；每张 1 番，最多累计 3 番
  local akaHan = 0
  local function countAka(id)
    local c = id and Fk:getCardById(id)
    if c and c.name:find("yyfy_0", 1, true) then akaHan = akaHan + 1 end
  end
  for _, id in ipairs(p:getCardIds("h")) do countAka(id) end
  for _, m in ipairs(melds) do
    for _, id in ipairs(m.cards or {}) do countAka(id) end
  end
  -- 荣 / 抢杠：和牌张不在手牌中，需单独计入（自摸时和牌张已在手牌内）
  if not info.tsumo then
    local winId
    if info.chankan and info.victim and info.winTile then
      winId = findHandIds(info.victim, info.winTile, 1)[1]
    elseif state.lastDiscard then
      winId = state.lastDiscard.id
    end
    countAka(winId)
  end
  if akaHan > 3 then akaHan = 3 end
  if akaHan > 0 then
    han = han + akaHan
    table.insert(dora, { key = "yyfy_yaku_aka", han = akaHan })
  end

  if han <= 0 then han = 1 end -- 无番缚：0 番按 1 番
  return { yaku = yaku, han = han, dora = dora }
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
  if #ev.yaku == 0 and #(ev.yakuman or {}) == 0 then return false end
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
      -- 击飞终局：被击飞者（点数 ≤ 0）一律判负；其余按点数取前两位获胜
      room:gameOver(M.WinnersByPoints(state))
      return false
    end
  end
  return true
end

-- 组装并广播胡牌结算界面所需的数据（客户端监听 YyfyMahjongResult 通知）
function M.BroadcastResult(room, state, winner, info, ev, score)
  -- 和牌张：自摸=本轮刚摸的牌；荣=被打出的弃牌；抢杠=被抢的那张手牌
  local winTileId
  if info.tsumo then
    winTileId = state.new_draw_id[winner.id]
  elseif info.chankan and info.victim and info.winTile then
    winTileId = findHandIds(info.victim, info.winTile, 1)[1]
  elseif state.lastDiscard then
    winTileId = state.lastDiscard.id
  end
  -- 手牌区（不含和牌张，和牌张单独展示在最后）
  local handIds = {}
  for _, id in ipairs(winner:getCardIds("h")) do
    if id ~= winTileId then table.insert(handIds, id) end
  end
  -- 副露区：扁平化为 meldCards（所有副露牌 id 依次排列）+ meldLens（每组张数）。
  -- 不向 QML 传嵌套数组：框架对 Lua 表格为浅转换，内层数组在 QML 里不可迭代。
  local meldCards, meldLens = {}, {}
  for _, m in ipairs(state.melds[winner.id] or {}) do
    local cards = m.cards or {}
    if #cards > 0 then
      table.insert(meldLens, #cards)
      for _, id in ipairs(cards) do table.insert(meldCards, id) end
    end
  end
  -- 役种在前、宝牌类在后，逐条展示（役满时不报小番，另用 yakuman 列出）
  local yakuList = {}
  for _, y in ipairs(ev.yaku) do table.insert(yakuList, { key = y.key, han = y.han }) end
  for _, y in ipairs(ev.dora or {}) do table.insert(yakuList, { key = y.key, han = y.han }) end
  -- 役满：转为名称列表 + 总权重（QML 按总权重显示"役满/两倍役满/N倍役满"）
  local yakumanNames, yakumanWeight = {}, 0
  for _, y in ipairs(ev.yakuman or {}) do
    table.insert(yakumanNames, y.key)
    yakumanWeight = yakumanWeight + (y.weight or 1)
  end
  -- 宝牌 / 里宝指示牌：各取 dora_count 张（扁平数组，QML 侧按需翻面）
  local omoteIndicators, uraIndicators = {}, {}
  for i = 1, state.dora_count do
    local ind = state.indicator[i]
    if ind then table.insert(omoteIndicators, ind) end
  end
  for i = 5, 4 + state.dora_count do
    local ind = state.indicator[i]
    if ind then table.insert(uraIndicators, ind) end
  end
  local scoreData = score or {}
  room:doBroadcastNotify("YyfyMahjongResult", {
    winnerId = winner.id,
    general = winner.general,
    screenName = winner._splayer:getScreenName(),
    tsumo = not not info.tsumo,
    handIds = handIds,
    meldCards = meldCards,
    meldLens = meldLens,
    winTileId = winTileId,
    winTileName = (not winTileId) and info.winTile and TYPE_TO_NAME[info.winTile] or nil,
    yaku = yakuList,
    han = ev.han,
    yakuman = yakumanNames,
    yakumanTotalWeight = yakumanWeight,
    baseScore = scoreData.base,
    bonusScore = scoreData.bonus,
    totalScore = scoreData.total,
    doraCount = state.dora_count,
    omoteIndicators = omoteIndicators,
    uraIndicators = uraIndicators,
    uraRevealed = state.riichi[winner.id] ~= nil,
  })
end

---@param opts? table { giveKyotaku = false 时本次不收场供（一炮多响中非第一位荣家） }
function M.SettleWin(room, state, winner, info, opts)
  -- 荣时弃牌尚未入手，需并入后才够 14 张，否则役判定会漏掉该面子
  local evalTiles
  if not info.tsumo and info.winTile then
    evalTiles = handTypes(winner)
    table.insert(evalTiles, info.winTile)
  end
  local ev = M.EvalYaku(state, winner, info, evalTiles)
  local band = getBand(ev.han)
  -- 役满倍数：单倍=1，双倍/复合役满按总权重放大点数（如两倍役满 64000/96000）
  local mult = math.max(1, yakumanWeightSum(ev.yakuman or {}))
  local payments = {}
  -- 本场加算：每多 1 本场，放铳时放铳者多付 300；自摸时每家多付 100（赢家合计多收 300）
  local honba = state.renchan_count or 0
  local honbaBonus = honba * 300
  -- 场供：本局与之前局所有人的立直棒（结算前累计的供托）
  local giveKyotaku = (opts == nil) or (opts.giveKyotaku ~= false)
  local kyotakuBonus = giveKyotaku and (state.kyotaku or 0) or 0
  local baseScore = 0
  if info.tsumo then
    local y = TSUMO_TABLE[band][2] * mult
    local x = TSUMO_TABLE[band][1] * mult
    for _, p in ipairs(state.players) do
      if p ~= winner then
        -- 庄家自摸：每人付庄付（y）；子家自摸：庄付 y、其他子付 x
        local pay = (winner == state.dealer) and y or ((p == state.dealer) and y or x)
        payments[p.id] = -(pay + honba * 100)
        baseScore = baseScore + pay
      end
    end
  else
    local victim = info.victim
    -- 荣和基础分倍率取决于"赢家是否为庄家"（庄家荣时为闲家的 1.5 倍）
    local pay = RON_TABLE[band][(winner == state.dealer) and 2 or 1] * mult
    payments[victim.id] = -(pay + honbaBonus)
    baseScore = pay
  end
  -- 赢家收取：基础分 + 本场加算 + 场供
  local bonusScore = honbaBonus + kyotakuBonus
  local totalScore = baseScore + bonusScore
  payments[winner.id] = (payments[winner.id] or 0) + totalScore
  if giveKyotaku then state.kyotaku = 0 end
  -- 日志与展示（结算停顿数秒，让玩家看清和牌结果）
  room:sendLog{ type = "#yyfy_mj_win", arg = winner._splayer:getScreenName(), arg2 = ev.han, arg3 = totalScore, toast = true }
  room:delay(2000)
  local yakuText
  if ev.yakuman and #ev.yakuman > 0 then
    yakuText = table.concat(table.map(ev.yakuman, function(y) return Fk:translate(y.key) end), "、")
  else
    yakuText = table.concat(table.map(ev.yaku, function(k) return Fk:translate(k.key) end), "、")
  end
  room:sendLog{ type = "#yyfy_mj_yaku", arg = yakuText, toast = true }
  -- 立直家胡牌：此时才揭晓里宝牌
  if state.riichi[winner.id] then
    local uraText = table.concat(uraDoraTexts(state), "、")
    room:setBanner("@yyfy_mj_dora", allDoraTexts(state, true))
    room:sendLog{ type = "#yyfy_mj_ura_log", arg = uraText, toast = true }
  end
  -- 广播结算界面数据（客户端展示役种与番数、和牌手牌、武将卡图）
  M.BroadcastResult(room, state, winner, info, ev,
    { base = baseScore, bonus = bonusScore, total = totalScore })
  room:delay(3000)
  if not M.Transfer(room, state, payments) then return false end
  state.lastWinner = winner
  return true
end

--------------------------------------------------------------------------
-- 杠
--------------------------------------------------------------------------

-- 杠后处理：翻指示牌、活牌底移入王牌山、摸岭上
-- kanKind / kanTile：杠的种类（"明杠"/"暗杠"/"加杠"）与杠的牌类型，用于播报
function M.OnKan(room, state, p, kanKind, kanTile)
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
    state.new_draw_id[p.id] = id
    state.rinshan_pending = true
  end
  room:sendLog{ type = "#yyfy_mj_kan_log",
    arg = p._splayer:getScreenName(),
    arg2 = kanKind or "杠",
    arg3 = kanTile and Fk:translate(TYPE_TO_NAME[kanTile]) or "",
    toast = true }
  -- 更新指示牌 banner（文字显示表宝牌，如“3索”）
  room:setBanner("@yyfy_mj_dora", omoteDoraTexts(state))
  local newInd = state.indicator[state.dora_count]
  if newInd then
    room:sendLog{ type = "#yyfy_mj_dora_log", arg = Fk:translate(TYPE_TO_NAME[nextDora(cardTypeOf(newInd))]), toast = true }
  end
  -- 翻出新的表宝牌指示牌后，刷新全场手牌上的"宝牌"标记
  refreshAllDoraMarks(room, state)
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
      local canMeld = not state.riichi[p.id] -- 立直后不可吃碰杠（仍可荣）
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
      if canMeld and countType(handTypes(p), dType) >= 3 then
        table.insert(acts, "yyfy_mj_kan")
      end
      -- 碰
      if canMeld and countType(handTypes(p), dType) >= 2 then
        table.insert(acts, "yyfy_mj_pon")
      end
      -- 吃（仅下家）
      if canMeld and p == nextP then
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
  -- 一炮双响：收集全部选择荣的玩家，按摸牌顺序（离放铳者由近及远）依次结算；
  -- 场供（立直棒）归离放铳者最近的第一位荣家，其余荣家只收基础分与本场加算。
  local ronPlayers = {}
  for _, p in ipairs(order) do
    if chosen[p.id] == "yyfy_mj_ron" then table.insert(ronPlayers, p) end
  end
  if #ronPlayers > 0 then
    for i, p in ipairs(ronPlayers) do
      local info = { tsumo = false, victim = discardingPlayer, houtei = houtei, winTile = dType }
      if not M.SettleWin(room, state, p, info, { giveKyotaku = (i == 1) }) then
        return "ended"
      end
    end
    -- 连庄判定：庄家为荣家之一则庄家连庄，否则以第一位荣家为最后和牌者
    local dealerWon = false
    for _, p in ipairs(ronPlayers) do
      if p == state.dealer then dealerWon = true break end
    end
    state.lastWinner = dealerWon and state.dealer or ronPlayers[1]
    return "ron"
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

  local chiCombo -- 吃牌时使用的组合（用于喰い替え禁打判定）

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
      -- 扁平存组：每相邻两个元素为一组（避免向 QML 传嵌套数组）
      local flat, groupNum = {}, 0
      for i = 1, #ids - 1 do
        for j = i + 1, #ids do
          table.insert(flat, ids[i])
          table.insert(flat, ids[j])
          groupNum = groupNum + 1
        end
      end
      if groupNum > 1 then
        local result = room:askToCustomDialog(p, {
          skill_name = "yyfy_mj_pon",
          component = {
            url = "packages/hidden-clouds/qml/YyfyMahjongMeldBox.qml",
            model = {
              url = "packages/hidden-clouds/qml/models/YyfyMahjongMeldModel.qml",
              prop = {
                ids = flat,
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
        picked = { flat[1], flat[2] }
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
    M.OnKan(room, state, p, "明杠", dType)
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
    local flat = {}
    for _, g in ipairs(groups) do
      table.insert(flat, g[1])
      table.insert(flat, g[2])
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
              ids = flat,
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
    chiCombo = combo
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

  -- 碰 / 吃 播报（杠的播报已在 M.OnKan 内按 明杠/暗杠/加杠 输出）
  if claim.kind ~= "kan" then
    local verb = (claim.kind == "pon") and "碰" or "吃"
    room:sendLog{ type = "#yyfy_mj_claim_log",
      arg = p._splayer:getScreenName(),
      arg2 = verb,
      arg3 = Fk:translate(TYPE_TO_NAME[dType]),
      toast = true }
  end
  room:delay(700)
  -- 该弃牌被副露，记录用于流局满贯判定（被鸣过的弃牌不成立流满）
  state.discard_claimed[discardingPlayer.id] = true
  state.no_meld = false -- 发生副露，取消地和
  -- 喰い替え（禁打）：本巡不可打出与所鸣牌同型之牌。
  --   碰：禁打所碰的牌型。
  --   吃：禁打所吃的牌型；若吃的是顺子低端，还禁打低端+3（等值于改吃该张）；高端则禁打高端-3。
  if claim.kind == "pon" then
    state.kuikae_forbid[p.id] = { [dType] = true }
  elseif claim.kind == "chi" and chiCombo then
    local forb = { [dType] = true }
    local lo, hi = math.huge, -math.huge
    for _, t in ipairs(chiCombo) do
      lo = math.min(lo, t)
      hi = math.max(hi, t)
    end
    local suitStart = math.floor(dType / 9) * 9
    if dType == lo then
      local s = lo + 3
      if s < suitStart + 9 then forb[s] = true end
    elseif dType == hi then
      local s = hi - 3
      if s >= suitStart then forb[s] = true end
    end
    state.kuikae_forbid[p.id] = forb
  end
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
    state.new_draw_id[turn.id] = id
    haitei = #state.live == 0
    rinshan = state.rinshan_pending
    -- 已摸牌：立直后的下一巡摸牌完成，一发进入可成立状态
    if state.ippatsu[turn.id] == 1 then state.ippatsu[turn.id] = 2 end
    -- 只有第一巡摸牌才可能地和
    if state.first_draw[turn.id] then state.first_draw[turn.id] = false end
  end
  -- 无论正常摸牌还是杠后岭上摸牌，都在此消费掉"杠后摸岭上"标记，避免泄漏到下一巡
  state.rinshan_pending = false
  -- 记录本巡摸到的是否为海底牌（最后一张牌山摸牌）：为真时禁止开杠（"只能切牌"）
  state.haitei_draw = haitei
  -- 摸牌后刷新摸牌者手牌上的"宝牌"标记（新摸到的宝牌立即提示）
  refreshDoraMarks(room, state, turn)

  local chiihou = state.no_meld and state.first_draw[turn.id] and turn ~= state.dealer and not rinshan
  local info = { tsumo = true, haitei = haitei, rinshan = rinshan, winTile = state.last_drawn[turn.id] }
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
      -- 立直：门前清、点数≥1000，且存在"弃一张后仍听牌"的牌
      -- 尾巡限制：本巡弃牌后已无下一次摸牌机会（剩余牌山 < 4，无法再轮到自己摸牌）时，
      --         默认不允许立直（RULES.tailRiichi 置 true 可解除）
      local tailTurn = #state.live < 4
      state.riichi_discardables = nil
      if #state.melds[turn.id] == 0 and state.points[turn.id] >= 1000
        and (RULES.tailRiichi or not tailTurn) then
        local discardables = M.RiichiDiscardables(handTypes(turn), state.melds[turn.id])
        if next(discardables) ~= nil then
          if room:askToSkillInvoke(turn, { skill_name = "yyfy_mj_riichi", prompt = "#yyfy_mj_riichi_prompt" }) then
            -- 二次确认：给玩家一次反悔机会，点取消则视为不立直
            if room:askToSkillInvoke(turn, { skill_name = "yyfy_mj_riichi", prompt = "#yyfy_mj_riichi_confirm_prompt" }) then
              state.points[turn.id] = state.points[turn.id] - 1000
              state.kyotaku = (state.kyotaku or 0) + 1000
              state.riichi[turn.id] = true
              state.ippatsu[turn.id] = 1
              state.riichi_discardables = discardables
              -- 两立直：第一巡、无人鸣牌且自身尚未出牌时立直
              if state.no_meld and #(state.discards[turn.id] or {}) == 0 then
                state.double_riichi[turn.id] = true
              end
              room:setPlayerMark(turn, "@yyfy_mj_points", state.points[turn.id])
              room:setPlayerMark(turn, "@yyfy_mj_riichi", "")
              room:sendLog{ type = "#yyfy_mj_riichi_log", arg = turn._splayer:getScreenName(), toast = true }
            end
          end
        end
      end
      -- 杠（暗杠 / 加杠）：摸到海底牌（本巡为最后一张牌山的摸牌）后不可再开杠，只能切牌
      if not state.riichi[turn.id] and not state.haitei_draw then
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
              M.OnKan(room, state, turn, "加杠", t)
            else
              -- 暗杠
              local ids = findHandIds(turn, t, 4)
              room:moveCardTo(ids, Card.PlayerSpecial, turn, fk.ReasonJustMove, state.skill_name, "yyfy_mj_meld", true, turn)
              table.insert(state.melds[turn.id], { type = "kan_closed", tiles = { t, t, t, t }, cards = ids, concealed = true })
              M.OnKan(room, state, turn, "暗杠", t)
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

    -- 出牌前把手牌按麻将序重排，并标记本轮新摸的牌（"新摸"仅摸牌者本人可见）
    -- 注意：moveCards 会清除手牌上的 "-inhand" 标记，故排序后需重新补打"宝牌"标记
    sortHandByMahjong(room, turn)
    if turn.id > 0 then markNewDraw(room, state, turn) end
    refreshDoraMarks(room, state, turn)

    -- 打牌：真人直接在手牌区点选一张牌，点确定打出（不弹中央选牌框，框架 AskForUseActiveSkill 手牌区选牌）
    local discardId
    if turn.id > 0 and state.riichi[turn.id] and not state.riichi_discardables then
      -- 已立直（非宣言回合）：只能摸切，自动打出刚摸的牌
      discardId = state.new_draw_id[turn.id]
    elseif turn.id > 0 then
      local askParams = {
        max_num = 1,
        min_num = 1,
        cancelable = false,
        skill_name = "yyfy_mj_play",
        prompt = "#yyfy_mj_discard_prompt",
      }
      local forbid = state.kuikae_forbid[turn.id]
      if state.riichi_discardables then
        -- 立直宣言回合：限制只能打出可保持听牌的牌
        local allowedIds = {}
        for _, id in ipairs(turn:getCardIds("h")) do
          if state.riichi_discardables[cardTypeOf(id)] then table.insert(allowedIds, id) end
        end
        askParams.prompt = "#yyfy_mj_riichi_discard_prompt"
        askParams.pattern = ".|.|.|.|.|.|" .. table.concat(allowedIds, ",")
      elseif forbid then
        -- 喰い替え：本巡不可打出与所鸣牌同型/可滑移之牌，仅列出手牌中允许打出的牌
        local allowedIds = {}
        for _, id in ipairs(turn:getCardIds("h")) do
          if not forbid[cardTypeOf(id)] then table.insert(allowedIds, id) end
        end
        if #allowedIds > 0 then
          askParams.pattern = ".|.|.|.|.|.|" .. table.concat(allowedIds, ",")
        end
      end
      local result = room:askToCards(turn, askParams)
      if type(result) == "table" and result[1] then
        discardId = result[1]
      end
    end
    if not discardId then
      -- 人机 / 超时兜底：默认摸切（打刚摸的牌），否则打第一张；喰い替え禁打时跳过被禁牌
      local nd = state.new_draw_id[turn.id]
      local handIds = turn:getCardIds("h")
      local forbid = state.kuikae_forbid[turn.id] or {}
      local pick
      if nd and table.contains(handIds, nd) and not forbid[cardTypeOf(nd)] then
        pick = nd
      else
        for _, id in ipairs(handIds) do
          if not forbid[cardTypeOf(id)] then pick = id break end
        end
      end
      discardId = pick or handIds[1]
      room:delay(500)
    end
    if not discardId then return nil end
    local dType = cardTypeOf(discardId)
    -- 喰い替え禁打状态在本巡弃牌后解除
    state.kuikae_forbid[turn.id] = nil
    -- 摸切/手切：是否打出了本轮刚摸的牌
    local tsumogiri = (state.new_draw_id[turn.id] ~= nil and discardId == state.new_draw_id[turn.id])
    -- 清除"新摸"标记（弃牌前清除，避免该牌在展示区残留标记）
    clearNewDrawMark(room, state, turn)
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
    -- 记录本局首次打出的牌（四风连打判定）
    if #state.discards[turn.id] == 1 then state.first_discard_type[turn.id] = dType end
    state.lastDiscard = { id = discardId, type = dType, player = turn }
    -- 立直者已摸过牌且本巡仍未和：一发失效
    if state.ippatsu[turn.id] == 2 then state.ippatsu[turn.id] = nil end
    room:sendLog{
      type = tsumogiri and "#yyfy_mj_discard_tsumogiri" or "#yyfy_mj_discard_tegiri",
      arg = turn._splayer:getScreenName(),
      arg2 = Fk:translate(TYPE_TO_NAME[dType]),
      toast = true }
    -- 立直宣言回合结束：记录听牌并显示"已立直"字幕（覆盖手牌区）
    if state.riichi[turn.id] and state.riichi_discardables then
      state.riichi_discardables = nil
      local waits = M.GetWaits(handTypes(turn), state.melds[turn.id])
      local names = {}
      for t in pairs(waits) do table.insert(names, Fk:translate(TYPE_TO_NAME[t])) end
      table.sort(names)
      local text = Fk:translate("yyfy_mj_riichi_caption") .. "\n"
        .. Fk:translate("yyfy_mj_riichi_waits") .. table.concat(names, "、")
      room:setPlayerProperty(turn, "handAreaOverlay", text)
    end
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
      -- 四风连打：第一巡无人副露、四家首次打出的均为同一张风牌 → 途中流局
      if state.no_meld then
        local fd = state.first_discard_type
        local base = fd[state.players[1].id]
        local fourWind = base ~= nil and base >= 27 and base <= 30
        if fourWind then
          for _, p in ipairs(state.players) do
            if fd[p.id] ~= base then fourWind = false break end
          end
        end
        if fourWind then
          room:sendLog{ type = "#yyfy_mj_four_wind", toast = true }
          room:delay(2000)
          state.renchan_dealer = true -- 途中流局：庄家续坐
          return "exhaustive"
        end
      end
      turn = nextSeat(state, turn)
      room:setCurrent(turn)
      needDraw = true
    end
  end
end

-- 流局满贯资格：本局所有弃牌均为幺九牌、且从未被其他家副露（自家暗杠不影响）
function M.GetNagashiPlayers(state)
  local ret = {}
  for _, p in ipairs(state.players) do
    local discards = state.discards[p.id] or {}
    if #discards > 0 and not state.discard_claimed[p.id] then
      local ok = true
      for _, t in ipairs(discards) do
        if not isYaochu(t) then ok = false break end
      end
      if ok then table.insert(ret, p) end
    end
  end
  return ret
end

-- 流局满贯结算：视为满贯自摸（子家 2000/4000、庄家 4000 均一，本场每家 +100/本场）。
-- 场供给离庄家按摸牌顺序最近的第一位流满者（庄家流满即给庄家）。
function M.SettleNagashi(room, state, winners)
  local payments = {}
  local honba = state.renchan_count or 0
  local order = seatOrderFrom(state, state.dealer)
  local firstWinner
  for _, p in ipairs(order) do
    if table.contains(winners, p) then firstWinner = p break end
  end
  local kyotakuBonus = state.kyotaku or 0
  state.kyotaku = 0
  for _, w in ipairs(winners) do
    local isDealer = (w == state.dealer)
    for _, q in ipairs(state.players) do
      -- 多人和了流满时彼此不付钱，只由未流满者支付
      if q ~= w and not table.contains(winners, q) then
        local pay = isDealer and 4000 or ((q == state.dealer) and 4000 or 2000)
        payments[q.id] = (payments[q.id] or 0) - (pay + honba * 100)
        payments[w.id] = (payments[w.id] or 0) + (pay + honba * 100)
      end
    end
    room:sendLog{ type = "#yyfy_mj_nagashi", arg = w._splayer:getScreenName(), toast = true }
  end
  if firstWinner then
    payments[firstWinner.id] = (payments[firstWinner.id] or 0) + kyotakuBonus
  end
  room:delay(2500)
  if not M.Transfer(room, state, payments) then return nil end
  state.renchan_dealer = table.contains(winners, state.dealer)
  return "exhaustive"
end

-- 流局结算，返回 "exhaustive" 或 nil（游戏已结束）
function M.DoExhaustive(room, state)
  -- 流局满贯优先：满足者视为满贯自摸，不再按普通流局结算
  local nagashi = M.GetNagashiPlayers(state)
  if #nagashi > 0 then
    return M.SettleNagashi(room, state, nagashi)
  end
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
  -- 立直棒不退还：作为供托留在桌上，累计到下一次有人和牌时由赢家收取
  if next(payments) then
    if not M.Transfer(room, state, payments) then return nil end
  end
  return tenpaiList
end

-- 终局胜负判定：默认点数前两位获胜、后两位失败；
-- 特别地，被击飞者（点数 ≤ 0）一律判负，且不参与胜利评定（此条优先于前两位规则）。
function M.WinnersByPoints(state)
  local able = {}
  for _, p in ipairs(state.players) do
    if (state.points[p.id] or 0) > 0 then table.insert(able, p) end
  end
  -- 点数降序；同分按东一局初始位次（東＞南＞西＞北）
  table.sort(able, function(a, b)
    local pa, pb = state.points[a.id], state.points[b.id]
    if pa ~= pb then return pa > pb end
    return (state.wind_order[a.id] or 99) < (state.wind_order[b.id] or 99)
  end)
  local ret = {}
  for i = 1, math.min(2, #able) do table.insert(ret, able[i]) end
  return ret
end

function M.EndGameByPoints(room, state)
  room:gameOver(M.WinnersByPoints(state))
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
  -- 左上角宝牌区旁额外显示当前局与本场数（如"东三局 2本场"）
  local windNames = { "东", "南", "西", "北" }
  local numNames = { "一", "二", "三", "四" }
  local wi = math.min(math.floor((state.round - 1) / 4), 3)
  local ni = (state.round - 1) % 4
  room:setBanner("@yyfy_mj_round", windNames[wi + 1] .. numNames[ni + 1] .. "局 " .. (state.renchan_count or 0) .. "本场")
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
  -- 标记数字与本场数挂钩：首局为 1，每连庄/流局连庄 +1
  local cur = (state.renchan_count or 0) + 1
  for _, p in ipairs(state.players) do
    room:setPlayerMark(p, "@yyfy_mj_dealer", p == state.dealer and cur or 0)
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
    -- 清除手牌上的"新摸"/"宝牌"卡牌标记（避免回收发牌后残留）
    for _, id in ipairs(p:getCardIds("h")) do
      local card = Fk:getCardById(id)
      if card then
        room:setCardMark(card, NEW_DRAW_MARK, 0)
        room:setCardMark(card, DORA_MARK, 0)
      end
    end
    -- 清除立直标记与手牌区字幕
    room:setPlayerMark(p, "@yyfy_mj_riichi", 0)
    room:setPlayerProperty(p, "handAreaOverlay", "")
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
    state.new_draw_id[p.id] = nil
    state.first_draw[p.id] = true
    state.double_riichi[p.id] = nil
    state.first_discard_type[p.id] = nil
    state.discard_claimed[p.id] = nil
    state.kuikae_forbid[p.id] = nil
  end
  state.riichi_discardables = nil
  state.haitei_draw = false
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
  -- 配牌后立即按麻将序整理全体玩家手牌（一次性批量塞回，日志简洁）：
  -- 闲家虽尚未轮到，也先排序以便规划
  for _, p in ipairs(state.players) do
    sortHandByMahjong(room, p)
    -- 显式把已排序的服务端手牌顺序推送给客户端，避免客户端因处理时序问题仍显示为配牌顺序
    room:doBroadcastNotify("SetPlayerHandCards", { p.id, p:getCardIds("h") })
  end
  refreshAllDoraMarks(room, state)
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
    kyotaku = 0, -- 供托：本局及之前局的立直棒（流局不退还，跨局累计，直到有人和牌）
    ippatsu = {},
    last_drawn = {},
    new_draw_id = {},
    riichi_discardables = nil,
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
    double_riichi = {}, -- 两立直标记（第一巡无人鸣牌时立直）
    first_discard_type = {}, -- 各家本局首次打出的牌类型（四风连打判定）
    discard_claimed = {}, -- 各家弃牌是否被副露（流局满贯判定）
    kuikae_forbid = {}, -- 喰い替え：鸣牌后本巡各家不可打出的牌型集合
    haitei_draw = false, -- 本巡摸到的是否为海底牌（为真时禁止开杠）
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
  -- 配牌后立即按麻将序整理全体玩家手牌（一次性批量塞回，日志简洁）：
  -- 闲家虽尚未轮到，也先排序以便规划
  for _, p in ipairs(players) do
    sortHandByMahjong(room, p)
    -- 显式把已排序的服务端手牌顺序推送给客户端，避免客户端因处理时序问题仍显示为配牌顺序
    room:doBroadcastNotify("SetPlayerHandCards", { p.id, p:getCardIds("h") })
  end
  refreshAllDoraMarks(room, state)
  return state
end

--------------------------------------------------------------------------
-- 主流程
--------------------------------------------------------------------------

function M.Run(room, players, skill_name)
  -- 麻将模式全程禁止玩家主动调整手牌顺序（只能依靠出牌前自动排序）
  -- 必须在发牌之前执行：banSortingHandcards 会把"客户端手牌顺序"同步为服务端顺序，
  -- 若放在发牌+排序之后，会把刚排好的服务端顺序覆盖回配牌顺序，导致闲家开局不按麻将序排列
  for _, p in ipairs(players) do
    room:banSortingHandcards(p, "-_yyfy_mj")
  end
  local state = M.Init(room, players, skill_name)
  if not state then
    for _, p in ipairs(players) do
      room:unbanSortingHandcards(p, "-_yyfy_mj")
    end
    return
  end
  local function unbanSortingAll()
    for _, p in ipairs(players) do
      room:unbanSortingHandcards(p, "-_yyfy_mj")
    end
  end
  local guard = 0
  while true do
    guard = guard + 1
    if guard > 100 then
      M.EndGameByPoints(room, state)
      unbanSortingAll()
      return
    end
    local result = M.PlayRound(room, state)
    if result == nil then unbanSortingAll() return end -- 已结束（击飞等）

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

    -- 终局判定：
    --   未开西入：半庄两圈（东场 4 局 + 南场 4 局），round > 8 即结束；
    --   开西入：南四过庄（round > 8）后若无人达到 30000 则续战西场；
    --           此后每局结束立即检查，有人达到 30000 即"无刷分"终局（不论是否连庄）；
    --           最多打到北四（round > 16）强制结束。
    -- 无刷分：西入后每局结束都检查是否有人达到 30000
    if RULES.seiu and state.round > 8 then
      local reached = false
      for _, p in ipairs(state.players) do
        if (state.points[p.id] or 0) >= 30000 then reached = true break end
      end
      if reached then
        M.EndGameByPoints(room, state)
        unbanSortingAll()
        return
      end
    end
    local finalRound = RULES.seiu and 16 or 8
    if state.round > finalRound then
      M.EndGameByPoints(room, state)
      unbanSortingAll()
      return
    end
    M.RestartRound(room, state)
  end
end

return M

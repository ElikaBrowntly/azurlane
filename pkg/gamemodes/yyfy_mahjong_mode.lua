-- SPDX-License-Identifier: GPL-3.0-or-later
-- 夜隐浮云·麻将模式定义
-- 规则：雀魂/立直麻将（三赤、有击飞、无古役、无番缚、有振听、有食断、有立直）
-- 四人游戏，初始每人 25000 点，半庄两圈（东场 4 局 + 南场 4 局，round>8）结束后按点数判胜。
-- 庄家随机东起（主公），逆时针行牌，门风随庄家旋转、场风东/南，均计入起胡役。
-- 占位牌由 yyfy_mahjong_tiles 提供，具体牌面由作者后续补充。

local desc_yyfy_mahjong = [[
  # 夜隐浮云·麻将

  <font color='red' >基于雀魂（立直麻将）规则的四人民间麻将。</font>

  一. 用牌

  - 万筒索数牌 1~9 各 4 张（其中红五仅 1 张，其余 3 张），字牌東南西北白發中各 4 张，共 136 张。

  二. 基本规则

  - 四人游戏，初始每人 25000 点，按点数结算（有击飞：点数归零立即结束）。
  - 庄家起手 14 张，闲家 13 张；碰、杠、吃、立直、胡均在被切牌时询问。
  - 三赤：红五作赤宝牌计 1 番。有食断：副露后仍可断幺。无古役、无番缚（0 番按 1 番结算）。
  - 有振听：牌河含有自己听牌时不荣（可自摸）。有立直（含一发）。
  - 每杠翻一张指示牌、摸岭上一张，四杠后除非岭上开花否则流局。
  - 流局听牌结算：1 人听其余各给 1000；2 人听两个没听者各给听牌者 1500；3 人听没听者给其他人各 1000。
  - 半庄共 8 局（东场 4 局 + 南场 4 局），结束后按点数排出 1-4 位；同分按东一局初始位次（東＞南＞西＞北）排序。
  - 有西入（地方规则开关）：南四过庄后若无人达到 30000 点，则由最初庄家续坐西一局（门风仍东、场风转西），此后每局结束有人达 30000 立即终局（无刷分），最多打到北四强制结束。
  - 有地方规则：两立直（第一巡无人鸣牌时立直，2 番）、四风连打（第一巡四家打出同一风牌则流局）、流局满贯（流局时弃牌全幺九且未被鸣者视为满贯自摸）、一炮双响。
  - 随机选一人东起为庄（主公），其余为反贼；逆时针行牌。庄家和牌或流局时庄家听牌则连庄，否则下家为新庄。

  三. 役与番（计分与雀魂一致）

  - 1番1000 / 2番2000 / 3番3900 / 4-5番8000 / 6-7番12000 / 8-10番16000 / 11-12番24000 / 13番32000。
  - 荣胡时庄家被荣为子家的 1.5 倍；自摸按 300/500、500/1000 等子/庄分付。
  - 天和、地和、国士无双、大三元、大四喜、小四喜、四暗刻、字一色、九莲宝灯等役满按 13 番记（32000/48000）；国士无双十三面、四暗刻单骑、纯正九莲宝灯为两倍役满（64000/96000）。
  - 立直棒 1000 点随和牌由赢家获得。
]]

local yyfy_mahjong_getLogic = function()
  local yyfy_mahjong_logic = GameLogic:subclass("yyfy_mahjong_logic")

  function yyfy_mahjong_logic:prepareGlobalSkills()
    self:addTriggerSkill(Fk.skills["game_rule"] --[[@as TriggerSkill]])
    for _, trig in ipairs(Fk.global_trigger) do
      if trig:getSkeleton().name ~= "mobile_effect" then
        self:addTriggerSkill(trig)
      end
    end
  end

  function yyfy_mahjong_logic:initialize(room)
    GameLogic.initialize(self, room)
    self.role_table = { nil, nil, nil, { "lord", "rebel", "rebel", "rebel" } }
    self.room.settings._game.luckTime = 0
  end

  function yyfy_mahjong_logic:assignRoles()
    local room = self.room
    local n = #room.players
    local roles = self.role_table[n]
    room:shuffleTable(roles)

    for i = 1, n do
      local p = room.players[i]
      p.role = roles[i]
    end
  end

  function yyfy_mahjong_logic:chooseGenerals()
    local room = self.room ---@type Room
    local players = room.players
    room:setCurrent(players[1])
    local all_generals = table.map(Fk:getAllGenerals(), function(g) return g.name end) or { "liubei" }

    for _, p in ipairs(players) do
      if p.id > 0 then
        p.general = p._splayer:getAvatar() or "liubei"
      else
        p.general = room:tableRandomPick(all_generals)
      end
      room:broadcastProperty(p, "general")
      room:broadcastProperty(p, "deputyGeneral")
      room:setPlayerProperty(p, "role_shown", true)
      room:broadcastProperty(p, "role")
    end
  end

  function yyfy_mahjong_logic:attachSkillToPlayers()
    local room = self.room
    for _, p in ipairs(room.players) do
      room:handleAddLoseSkills(p, "yyfy_mj_pon", nil, false, true)
      room:handleAddLoseSkills(p, "yyfy_mj_kan", nil, false, true)
      room:handleAddLoseSkills(p, "yyfy_mj_chi", nil, false, true)
      room:handleAddLoseSkills(p, "yyfy_mj_riichi", nil, false, true)
      room:handleAddLoseSkills(p, "yyfy_mj_ron", nil, false, true)
      room:handleAddLoseSkills(p, "yyfy_mj_tsumo", nil, false, true)
    end
  end

  return yyfy_mahjong_logic
end

local yyfy_mahjong_mode = fk.CreateGameMode {
  name = "yyfy_mahjong",
  playerNums = { 4 },
  logic = yyfy_mahjong_getLogic,
  rule = "#yyfy_mahjong_rule&",
  is_counted = function(self, room)
    return #room.players >= 4
  end,
  whitelist = function(self, pkg)
    if pkg.type ~= Package.CardPack then return true end
    return pkg.name == "yyfy_mahjong_tiles"
  end,
  surrender_func = function(self, playedTime)
    return { text = "yyfy_mahjong_surrender", passed = false }
  end,
  get_adjusted = function(self, player)
    return {}
  end,
  build_draw_pile = function(self)
    local room = Fk:currentRoom()
    local draw, void = GameMode.buildDrawPile(self)
    draw = draw or {}
    local function printNTimes(name, n, number)
      for _ = 1, n do table.insert(draw, room:printCard(name, Card.NoSuit, number or 1).id) end
    end
    -- 数牌：1~9 各 4 张，其中 5 的 1 张换作红五（0 结尾）；点数 = 牌面数字（红五=5）
    for _, s in ipairs{ "m", "p", "s" } do
      for i = 1, 9 do
        if i == 5 then
          printNTimes(("yyfy_5%s"):format(s), 3, 5)
          printNTimes(("yyfy_0%s"):format(s), 1, 5)
        else
          printNTimes(("yyfy_%d%s"):format(i, s), 4, i)
        end
      end
    end
    -- 字牌：東南西北白發中各 4 张
    for _, h in ipairs{ "ton", "nan", "sha", "pei", "haku", "hatsu", "chun" } do
      printNTimes("yyfy_" .. h, 4, 1)
    end
    return draw, void
  end,
}

Fk:loadTranslationTable {
  ["yyfy_mahjong"] = "四人麻将",
  [":yyfy_mahjong"] = desc_yyfy_mahjong,
  ["yyfy_mahjong_surrender"] = "麻将模式下不可投降",
  ["yyfy_mahjong_tiles"] = "夜隐浮云·麻将牌",
  ["#yyfy_mahjong_rule&"] = "夜隐浮云·麻将",

  ["yyfy_mj_pon"] = "碰",
  ["yyfy_mj_kan"] = "杠",
  ["yyfy_mj_kan_act"] = "杠",
  ["yyfy_mj_chi"] = "吃",
  ["yyfy_mj_riichi"] = "立直",
  ["yyfy_mj_ron"] = "荣和",
  ["yyfy_mj_tsumo"] = "自摸",

  ["yyfy_mj_no_act"] = "不操作",
  ["yyfy_mj_claim_wait"] = "不操作",
  ["yyfy_mj_claim"] = "副露",
  ["yyfy_mj_meld"] = "副露",
  ["yyfy_mj_discard"] = "已打出",
  ["yyfy_mj_play"] = "打牌",

  ["@yyfy_mj_points"] = "点数",
  ["@yyfy_mj_dora"] = "宝牌",
  ["@yyfy_mj_round"] = "",
  ["@yyfy_mj_dealer"] = "庄家",
  ["@yyfy_mj_riichi"] = "立直",
  ["@@yyfy_newDraw-inhand"] = "新摸",
  ["@@yyfy_dora-inhand"] = "宝牌",
  ["@@yyfy_dora"] = "宝牌",

  [":yyfy_mj_pon"] = "用两张相同的牌，副露任意其他家打出的同一张牌，组成一个明刻。如手里的1万1万去碰对家的1万。",
  [":yyfy_mj_kan"] = "四张相同的牌可以杠，分为①明杠：手里有暗刻（三张相同牌），别家打出第四张；②暗杠：自家摸到四张相同牌；③加杠：已通过“碰”副露到明刻，且自家摸到第四张相同牌。只有暗杠不计入副露，保持门前清状态。",
  [":yyfy_mj_chi"] = "用两张相邻或仅差1的数牌，副露上家打出的相邻数牌，使其能组成一个顺子。如手里的3饼4饼吃上家2饼或者5饼；手里6索8索吃上家7索。",
  [":yyfy_mj_riichi"] = "在门前清（未进行任何副露）状态下达到听牌状态，可以支付1000分立直，宣告听牌，此后不能改变听牌型；但奖励玩家在胡牌时多计入1番，且可以翻开里宝牌。",
  [":yyfy_mj_ron"] = "在有役且未振听情况下，别家打出自家听牌待牌，可以胡牌，结束该本场，该家向你支付分数。",
  [":yyfy_mj_tsumo"] = "在有役情况下，自己摸到自家听牌待牌，可以自摸，结束该本场，所有人向你支付分数。",

  ["#yyfy_mj_round"] = "第 %arg 局开始，庄家为 %arg2",
  ["#yyfy_mj_renchan"] = "%arg 连庄！",
  ["#yyfy_mj_dealer_change"] = "换庄：%arg → %arg2",
  ["#yyfy_mj_dora_log"] = "宝牌指示牌翻出：%arg",
  ["#yyfy_mj_ura_log"] = "里宝牌翻出：%arg",
  ["#yyfy_mj_claim_cancel"] = "%arg 取消了副露",
  ["#yyfy_mj_discard_tsumogiri"] = "%arg 摸切了 %arg2",
  ["#yyfy_mj_discard_tegiri"] = "%arg 手切了 %arg2",
  ["#yyfy_mj_riichi_log"] = "%arg 立直！",
  ["#yyfy_mj_kan_log"] = "%arg %arg2了 %arg3",
  ["#yyfy_mj_claim_log"] = "%arg %arg2了 %arg3",
  ["#yyfy_mj_win"] = "%arg 和牌！%arg2 番 %arg3 点",
  ["#yyfy_mj_yaku"] = "和牌役：%arg",
  ["#yyfy_mj_exhaustive"] = "本局流局",
  ["#yyfy_mj_fly"] = "%arg 点数归零被击飞，游戏结束！",
  ["#yyfy_mj_missing_tile"] = "缺少麻将牌卡组，无法开始游戏！",
  ["#yyfy_mj_four_kan"] = "四杠散了，本局流局",
  ["#yyfy_mj_four_wind"] = "四风连打，本局流局",
  ["#yyfy_mj_nagashi"] = "%arg 流局满贯！",

  ["#yyfy_mj_discard_prompt"] = "请选择一张牌打出",
  ["#yyfy_mj_tsumo_prompt"] = "自摸！是否和牌？",
  ["#yyfy_mj_chiihou_prompt"] = "地和！是否和牌？",
  ["#yyfy_mj_ron_prompt"] = "荣！是否和牌？",
  ["#yyfy_mj_chankan_prompt"] = "抢杠！是否和牌？",
  ["#yyfy_mj_pon_prompt"] = "是否碰？",
  ["#yyfy_mj_damingkan_prompt"] = "是否大明杠？",
  ["#yyfy_mj_chi_prompt"] = "是否吃？",
  ["#yyfy_mj_chi_choose_prompt"] = "请选择用来吃牌的两张牌",
  ["#yyfy_mj_pon_choose_prompt"] = "请选择用来碰牌的两张牌",
  ["#yyfy_mj_claim_prompt"] = "请选择要发动的副露操作",
  ["#yyfy_mj_riichi_prompt"] = "是否立直：付出代价但胡牌时获得奖励？",
  ["#yyfy_mj_riichi_confirm_prompt"] = "确定立直吗？点击取消将放弃立直",
  ["#yyfy_mj_riichi_discard_prompt"] = "立直宣言：请选择要打出的牌（之后不可改听）",
  ["#yyfy_mj_act_prompt"] = "请选择操作",

  ["yyfy_mj_dora"] = "宝牌",
  ["yyfy_mj_ura"] = "里宝牌",
  ["yyfy_mj_dora_indicator"] = "宝牌指示牌",
  ["yyfy_mj_ura_indicator"] = "里宝指示牌",
  ["yyfy_mj_yakuman"] = "役满",
  ["yyfy_mj_yakuman_multi"] = "倍役满",
  ["yyfy_mj_aka"] = "赤宝牌",
  ["yyfy_mj_riichi_caption"] = "已立直。。。",
  ["yyfy_mj_riichi_waits"] = "听牌：",
  ["yyfy_mj_han"] = "番",
  ["yyfy_mj_total_han"] = "合计 ",
  ["yyfy_mj_result_tsumo"] = "自摸",
  ["yyfy_mj_result_ron"] = "荣和",

  ["yyfy_yaku_riichi"] = "立直",
  ["yyfy_yaku_daburu_riichi"] = "两立直",
  ["yyfy_yaku_ippatsu"] = "一发",
  ["yyfy_yaku_tsumo"] = "门前清自摸和",
  ["yyfy_yaku_pinhu"] = "平和",
  ["yyfy_yaku_yakuhai"] = "役牌",
  ["yyfy_yaku_sanshoku"] = "三色同顺",
  ["yyfy_yaku_sanshoku_tri"] = "三色同刻",
  ["yyfy_yaku_ittsu"] = "一气通贯",
  ["yyfy_yaku_toitoi"] = "对对和",
  ["yyfy_yaku_sanankou"] = "三暗刻",
  ["yyfy_yaku_ryanpeikou"] = "两杯口",
  ["yyfy_yaku_iipeikou"] = "一杯口",
  ["yyfy_yaku_tanyao"] = "断幺九",
  ["yyfy_yaku_honitsu"] = "混一色",
  ["yyfy_yaku_chinitsu"] = "清一色",
  ["yyfy_yaku_chanta"] = "混全带幺九",
  ["yyfy_yaku_junchan"] = "纯全带幺九",
  ["yyfy_yaku_rinshan"] = "岭上开花",
  ["yyfy_yaku_haitei"] = "海底捞月",
  ["yyfy_yaku_houtei"] = "河底捞鱼",
  ["yyfy_yaku_chankan"] = "抢杠",
  ["yyfy_yaku_sankantsu"] = "三杠子",
  ["yyfy_yaku_chiitoi"] = "七对子",
  ["yyfy_yaku_dora"] = "宝牌",
  ["yyfy_yaku_ura"] = "里宝牌",
  ["yyfy_yaku_aka"] = "红宝牌",

  ["yyfy_yk_kokushi"] = "国士无双",
  ["yyfy_yk_daisangen"] = "大三元",
  ["yyfy_yk_daisuushi"] = "大四喜",
  ["yyfy_yk_shousuushi"] = "小四喜",
  ["yyfy_yk_suuankou"] = "四暗刻",
  ["yyfy_yk_tenhou"] = "天和",
  ["yyfy_yk_chiihou"] = "地和",
  ["yyfy_yk_tsuuiisou"] = "字一色",
  ["yyfy_yk_kokushi_juusan"] = "国士无双十三面",
  ["yyfy_yk_suuankou_tanki"] = "四暗刻单骑",
  ["yyfy_yk_chuuren"] = "九莲宝灯",
  ["yyfy_yk_junsei_chuuren"] = "纯正九莲宝灯",
}

return yyfy_mahjong_mode

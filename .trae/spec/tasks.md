# 任务清单 — 结算面板与立直字幕恢复

- [x] **T1 新建结算面板组件**
  - 文件：`packages/hidden-clouds/qml/YyfyMahjongResultBox.qml`
  - 根元素 `GraphicsBox`（`LunarLtk.Pages.Popups`），自带 `signal finished()`
  - 提供 `function loadData(d)` / `property var info` / `toList(v)` / `buildEntries(d)`
  - 逐条揭示 Timer、7s 自动关闭、点击与"确定"按钮 → `finished()`
  - 展示：胡牌者名 + 自摸/荣和、手牌与副露、宝牌指示、里宝（未揭示用背面）、役种/役满列表、"合计 N 番 X 符"、`基础点+奖励点=总点`

- [x] **T2 引擎改用 ObserverMiniGame 广播**
  - 文件：`packages/hidden-clouds/pkg/gamemodes/yyfy_mahjong_engine.lua` → `M.BroadcastResult`
  - `room:doBroadcastNotify("ObserverMiniGame", { type = "yyfy_mj_result", data = payload })`
  - payload 保持原字段，含 `fu`

- [x] **T2b 注册迷你游戏类型**
  - 文件：`packages/hidden-clouds/pkg/gamemodes/yyfy_mahjong_mode.lua`
  - `Fk:addMiniGame { name = "yyfy_mj_result", qml_path = "packages/hidden-clouds/qml/YyfyMahjongResultBox" }`
  - 原因：客户端 `RoomModel.observerMiniGame` 忽略 `component.url`，改用 `Ltk.getMiniGame(type)` 从 `Fk.mini_games` 取路径

- [x] **T3 立直字幕追加 banner 兜底**
  - 立直设置处：`room:doBroadcastNotify("SetBanner", { "@yyfy_mj_riichi", text }, { turn })`（仅本人可见，避免泄露听牌）
  - 清除处：`room:doBroadcastNotify("SetBanner", { "@yyfy_mj_riichi", 0 }, { p })`（value=0 时客户端移除该 mark）
  - 保留原 `setPlayerProperty(..., "handAreaOverlay", ...)`

- [x] **T4 静态验证**
  - `lua54.dll` 语法检查：引擎、模式文件均 `SYNTAX OK`
  - 校验脚本：`mini_game = yyfy_mj_result`、`qml_path = .../YyfyMahjongResultBox.qml`、
    `cmd = ObserverMiniGame`、`han/fu = 3/30`、`handIds/yaku/meldLens` 数组正常 → `VERIFY OK`
  - QML 括号平衡检查通过

- [x] **T5 实机验证（需用户启动客户端确认）**
  - 立直 → 左上角 banner 出现"已立直…/听牌：…" → 本局结束清除
  - 胡牌 → 结算框弹出，番数+符数+点数正确，可关闭
  - 日志无 Lua 报错；若 banner 清除后残留空标签，按 T6 调整

- [x] **T6 视觉微调（按实机结果）**
  - 结论：清除时传 `0` 走 `Ltk.setMark` 的删除分支（`rawValue === 0` → `marks.splice`），不会残留空标签，无需额外处理
  - 若实机发现字幕过长影响 banner 排版，再考虑截断听牌列表

## 本轮：指示牌区（5 槽位 + 牌背 + 印牌兜底）

- [x] **T7 引擎：指示牌改为 printCard 现场印牌**
  - 文件：`packages/hidden-clouds/pkg/gamemodes/yyfy_mahjong_engine.lua` → `M.BroadcastResult`（现 L1621-1658）
  - 新增局部函数 `printIndicatorCard(ind)`：`Fk:getCardById(ind)` 取真牌 → `room:printCard(card.name, Card.NoSuit, card.number)` → 返回副本 `id`
  - 表宝：`i = 1 .. state.dora_count`；里宝：仅 `uraRevealed` 时 `i = 5 .. 4 + state.dora_count`
  - 提取 `local uraRevealed = state.riichi[winner.id] ~= nil`，payload 用它，`doraCount` 不变
  - 原因：牌山牌客户端不可见，`getCardData` 只回 `{cid, known=false}` → 无法渲染牌面

- [x] **T8 QML：固定 5 槽位 + 牌背**
  - 文件：`packages/hidden-clouds/qml/YyfyMahjongResultBox.qml`
  - 删除 `indicatorCount`，新增 `indicatorSlotCount = 5`、`doraCount`（缺失时回退 `omoteIndicators.length`）、
    `omoteRevealedCount = clamp(doraCount, 0, 5)`、`uraRevealedCount = info.uraRevealed ? omoteRevealedCount : 0`
  - 新增 `isValidCard(id)`：`typeof id === "number" && id !== 0 && Ltk.getCardData(id).name !== undefined`
  - 两行 `Repeater { model: root.indicatorSlotCount }`；`cardId = index < revealedCount && isValidCard(…) ? id : -1`
  - `cardId >= 0` → `CardItem`；否则 → `Image { source: SkinBank.searchBuiltinPic("/image/card/", "card-back") }`（真牌背，不依赖 id）
  - 棕色 `Rectangle` 作底色保留（贴图缺失时不出现空洞）

- [x] **T9 静态验证**
  - `luasyntax.py` 引擎 → `SYNTAX OK`
  - `qmlbalance.py` QML → 括号平衡
  - 更新 `C:\Users\Lenovo\AppData\Local\Temp\mj_verify.lua`：`room.printCard` stub 返回递减负数 id；
    断言 `d.doraCount == 1`、`#d.omoteIndicators == 1`、`#d.uraIndicators == 1`、id `< 0`；
    清空 `state.riichi` 再跑，断言 `#d.uraIndicators == 0`；输出 `VERIFY OK`

- [ ] **T10 实机验证（需用户重启服务端）**
  - 立直家和牌：表宝 1 张牌面 + 4 牌背；里宝 1 张牌面 + 4 牌背
  - 非立直家和牌：表宝 1 张牌面 + 4 牌背；里宝 5 张牌背
  - 杠后 `dora_count = 2`：两行各 2 张牌面 + 3 牌背
  - 控制台无 `Unable to assign [undefined] to QUrl`
  - 结论：T7 的 printCard 方案实机仍是全牌背，改走 T11 的"牌名+点数"方案

## 本轮：指示牌改由客户端造牌 / 摸切 / 杠按钮中文化

- [x] **T11 引擎：指示牌改发"牌名+点数"扁平数组**
  - 文件：`packages/hidden-clouds/pkg/gamemodes/yyfy_mahjong_engine.lua` → `M.BroadcastResult`
  - `pushIndicator(names, numbers, ind)`：`Fk:getCardById(ind)` → `card.name` / `card.number`
  - payload：`omoteIndicatorNames/Numbers`、`uraIndicatorNames/Numbers`、`doraCount`、`uraRevealed`
  - 原因：牌 id 对客户端不可见，printCard 副本也未奏效

- [x] **T12 QML：用 createCardModelFromName 现场造牌面**
  - 文件：`packages/hidden-clouds/qml/YyfyMahjongResultBox.qml`
  - `omoteModels/uraModels` + `indicatorModel()` + `indicatorEntries()` + `buildIndicatorModels()`
  - 固定 5 槽位；模型为 null 的槽位显示牌背；兼容旧版 `omote/uraIndicators`（id / 对象 / 牌名）

- [x] **T13 出牌支持空选摸切**
  - 文件：引擎 `buildDiscardAsk()`：`min_num = riichiMode and 1 or 0`
  - 空选牌 → 既有兜底逻辑优先打 `state.new_draw_id`；`room:delay(500)` 仅保留给 AI（`turn.id <= 0`）
  - 文案：`["#yyfy_mj_discard_prompt"] = "请选择一张牌打出（不选牌直接点确定即为摸切）"`
  - 已知限制：确定按钮文案写死在核心 `Room.qml`，本仓库无法改成"摸切"

- [x] **T14 杠选项中文化**
  - 文件：`packages/hidden-clouds/pkg/gamemodes/yyfy_mahjong_mode.lua`
  - 新增 `["yyfy_mj_kakan_act"] = "杠"`（与 `yyfy_mj_kan_act` 一致）

- [x] **T15 静态验证**
  - `luasyntax.py` 引擎 + 模式 → `SYNTAX OK`
  - `qmlbalance_arg.py` → 括号平衡
  - `mj_verify.lua` 改为断言扁平数组内容 → `VERIFY OK`

- [ ] **T16 实机验证（需用户重启服务端）**
  - 立直和 / 副露和：宝牌行有真实牌面；立直和时里宝行第一张也是牌面
  - 出牌：不选牌直接点确定 = 摸切
  - 杠选项为中文"杠"

## 本轮：击飞终局崩溃 + 小三元漏判

- [x] **T17 QML：结算面板预热 GameOverModel 类型**
  - 文件：`packages/hidden-clouds/qml/YyfyMahjongResultBox.qml`
  - 新增 `property var gameOverPrewarm: null`
  - 新增 `Component.onCompleted { prewarmGameOverModel(); prewarmGameOverBox(); }`
  - `prewarmGameOverModel()`：`Qt.createComponent("LunarLtk.Models.Popups", "GameOverModel")`，
    持有引用；`Loading` 时接 `statusChanged`，`Ready` 后 `createObject()` 一次再 `destroy()`，
    `Error` 时打印 `errorString`
  - 不设 `winner`，无播音/读战绩副作用
  - 另：只编译加载 `LunarLtk.Pages.Popups` 的 `GameOverBox`（不实例化）
  - 目的：核心 `RoomModel.gameOver()` 里的同步 `createComponent + createObject` 不再拿到 null

- [x] **T18 引擎：役判定补小三元**
  - 文件：`packages/hidden-clouds/pkg/gamemodes/yyfy_mahjong_engine.lua` → `M.EvalYaku`
  - 位置：`elseif form then` 分支内、役牌计数之后（约 L1281 后）
  - `dragonTri = 三元牌(31/32/33)刻子数`；`dragonTri == 2` 且 `form.pair ∈ {31,32,33}`
  - `addYaku("yyfy_yaku_shousangen", 2 + openPenalty)`（门前 2 番 / 副露 1 番）

- [x] **T19 文案：补小三元翻译**
  - 文件：`packages/hidden-clouds/pkg/gamemodes/yyfy_mahjong_mode.lua` 静态翻译表（役牌附近）
  - `["yyfy_yaku_shousangen"] = "小三元"`

- [x] **T20 静态验证**
  - `luasyntax.py` 引擎 + 模式 → `SYNTAX OK`
  - `qmlbalance_arg.py YyfyMahjongResultBox.qml` → 括号平衡
  - 临时脚本 `mj_shousangen_verify.lua`：构造白刻 + 中刻 + 发财雀头的 `form`，
    调用 `M.EvalYaku` 断言含 `yyfy_yaku_shousangen`，门前 2 番 / 副露 1 番
  - 结论：Lua 5.4 全文件编译通过、QML 括号平衡、`VERIFY OK`

- [ ] **T21 实机验证（需用户重启服务端/客户端）**
  - 击飞对手 → 终局结算正常弹出；日志无 `RoomModel.qml:580 TypeError`
  - 碰白 + 中、发财雀头 → 结算报番含"小三元"

## 本轮：17 项地方规则开关（默认值 = 此前行为）

- [x] **T22 新建规则开关模块**
  - 文件：`packages/hidden-clouds/pkg/gamemodes/yyfy_mahjong_rules.lua`
  - 17 项 + 附加 `tailRiichi`，每项带中文注释；引擎与模式共用同一份配置
  - 默认：`fourRed=false, kuitan=true, seiu=true, renchanAtTop=false, tobi=true,
    nagashiMangan=true, kiriageMangan=false, omoteDora=true, kanOmoteDora=true,
    uraDora=true, kanUraDora=true, kanDoraImmediate=true, fourWindAbort=true,
    fourKanAbort=true, fiveKanAbort=false, fourRiichiAbort=false, nineTerminals=false`

- [x] **T23 四赤 / 食断 / 西入 / 尾亲连庄**
  - `yyfy_mahjong_mode.lua` `build_draw_pile`：`fourRed` 时筒子 2 张 0p + 2 张 5p
  - 引擎断幺判定：`RULES.kuitan or #melds == 0`
  - `M.Run` 终局：南四过庄（round 变 9）后开西入且无人 ≥30000 才续战；
    西场/北场每局结束有人 ≥30000 即终局（无刷分）；最多北四
  - 尾亲连庄：南四连庄（round 仍为 8）时，`renchanAtTop` 关闭且庄家为一位且 >30000 → 终局

- [x] **T24 击飞 / 流局满贯 / 切上满贯**
  - `M.Transfer`：`RULES.tobi` 且点数 `< 0` 才击飞（0 分不击飞）
  - 立直门槛：`RULES.tobi` 时点数须 ≥1000
  - `M.DoExhaustive`：`nagashiMangan` 关闭时不承认流局满贯
  - `basePoints`：`kiriageMangan` 时 4 番 30 符 / 3 番 60 符按满贯 2000 基础点

- [x] **T25 表/里/杠宝牌四开关**
  - `dora_count`（表）与 `ura_count`（里）拆分，互不影响
  - `omoteDora` 关闭：不计番、清空手牌"宝牌"标记、不显示宝牌 banner
  - `kanOmoteDora` 关闭：开杠不追加表指示牌 / 不计新表宝
  - `uraDora` 关闭：立直和也不揭晓、不计番；`uraRevealed = false`
  - `kanUraDora` 关闭：开杠不追加里指示牌
  - 赤宝牌上限：`fourRed` 时 4，否则 3

- [x] **T26 明杠宝牌即翻**
  - `M.OnKan(..., deferDora)`：明杠/加杠在 `kanDoraImmediate` 关闭时置 `pending_kan_dora`
  - `M.RevealKanDora`：切牌后（或被荣和前）翻出；岭上直接自摸时在和牌结算前翻出
  - 开启（默认）时明杠与暗杠一致，开杠瞬间翻

- [x] **T27 四风连打 / 四杠散了 / 五杠流局 / 四家立直**
  - 四风连打：`fourWindAbort` + 第一巡无人副露 + 四家首弃同风 → 途中流局
  - 四杠散了：第 4 杠后岭上未自摸 → 仍需打一张；被荣和按正常放铳（不算河底）、
    被副露则继续、通过则流局
  - 五杠流局：`fiveKanAbort` 开启允许第 5 杠，开杠通过后立即流局（不摸岭上）；
    关闭时第 5 杠不可宣言（暗杠/加杠/大明杠统一门槛）
  - 四家立直：`fourRiichiAbort` 时第四家立直弃牌通过后立即流局

- [x] **T28 九种九牌**
  - 摸牌后、首次打牌前询问（每局每人一次），`countKyuushu` 同种只算 1 种
  - 宣告后 `M.SettleKyuushu`：流局、庄家续坐
  - 结算面板展示宣告者手牌：服务端下发 `handNames/handNumbers`，QML 用
    `createCardModelFromName` 造牌面；`abortText` 复用结算面板并隐藏役种/点数区

- [x] **T29 小三元回归补充**
  - 副露不减番，固定 2 番（此前误用 `openPenalty`）

- [x] **T30 静态验证**
  - `lua_check.py`：规则/引擎/模式 `SYNTAX OK`；QML 括号平衡
  - `mj_rules_verify.lua`：18 个默认值、表宝牌开/关、里宝牌开/关、小三元 2 番 → `VERIFY OK`

- [ ] **T31 实机验证（需用户重启服务端/客户端）**
  - 默认配置行为不变：三赤、食断、西入、击飞（<0）、流局满贯、无切上满贯、无四家立直/九种九牌
  - 逐项切换：四赤牌山、切上满贯 7700/11600→8000/12000、表/里宝关闭不计番、
    杠表/杠里宝独立、明杠延迟翻宝、四风/四杠/五杠/四家立直流局、九种九牌按钮与手牌展示
  - 南四终局：西入 / 尾亲连庄行为符合设置

## 本轮：第 18–34 项开关（默认值 = 此前行为）

- [x] **T32 规则表扩充与第 4 项改名**
  - `winEndgame`（原 `renchanAtTop` 取反）+ 18–34 全部写入 `yyfy_mahjong_rules.lua`
  - 默认值：`tripleRonAbort=false, atamahane=false, dealerWinRenchan=true,
    tenpaiRenchan=true, tenpaiEndgame=false, ippatsu=true, hanShibari=1,
    doubleYakuman=true, compoundYakuman=true, kuikaeAllowed=false,
    doubleWindPairFu=4, kokushiChankan=false, renhou=false, pao="none",
    kazoeYakuman=true, oldYaku=false`

- [x] **T33 番缚 / 役满倍数 / 符**
  - `M.CanSettle`：役番合计 ≥ `hanShibari`（0 番缚无役可和；役满恒可和）
  - `ykW(2)`：双倍役满开关；`applyCompound`：复合役满开关
  - `basePoints`：13 番以上按 `kazoeYakuman` 取 8000 / 6000 基础点
  - `computeFu`：连风雀头按 `doubleWindPairFu`（2/4 符）
  - 一发役受 `ippatsu` 控制

- [x] **T34 和牌流程：三家和了 / 头跳 / 抢杠 / 人和**
  - `M.CheckClaims`：三响且 `tripleRonAbort` → `"abort"` → `DoAbortiveDraw`
  - `atamahane` 开启：荣家只取座次第一个
  - `M.CheckChankan` 返回抢杠列表；`M.CheckKokushiAnkan` 国士抢暗杠
  - `info.renhou`：第一巡未摸牌、无人副露时荣和记人和役满

- [x] **T35 包牌结算**
  - `findPao`：按 `pao` 判定大三元/大四喜责任者（荣和张完成刻子或副露来源）
  - `M.SettleWin`：自摸由包牌者付全部，荣和由包牌者与放铳者各付一半；
    复合役满仅对包牌役满部分负责

- [x] **T36 古役**
  - 番种：燕返、杠上炮、十二落抬、五门齐、三连刻、一色三同顺、一筒摸月、九筒捞鱼
  - 役满：大车轮、大竹林、大数邻、石上三年、大七星（双倍）
  - `M.OnKan` 置 `after_kan_pending`；弃牌记录 `last_discard_riichi` / `last_discard_after_kan`

- [x] **T37 连庄 / 终局开关**
  - `dealerWinRenchan`：庄家和牌不连庄
  - `tenpaiRenchan`：通常流局庄家听牌不连庄（途中流局仍连庄）
  - `tenpaiEndgame`：南四通常流局且尾亲一位时按听牌 + 西入/30000 判定终局
  - `winEndgame`：南四和牌连庄且尾亲一位（>30000）终局
  - `DoExhaustive` 记录 `round_draw/dealer_tenpai`；`DoAbortiveDraw`/`SettleKyuushu` 记录 `abortive_draw`

- [x] **T38 食替与翻译**
  - `kuikaeAllowed`：打牌询问与超时兜底不再套用 `kuikae_forbid`
  - 新增古役/古役满/人和/三家和了中文翻译

- [x] **T39 静态验证**
  - `lua_check.py`：规则/引擎/模式 `SYNTAX OK`；QML 括号平衡
  - `mj_rules_verify.lua`：34 个默认值、表/里宝开关、小三元 2 番 → `VERIFY OK`

- [ ] **T40 实机验证（需用户重启服务端/客户端）**
  - 一炮双响/三响/头跳、三家和了流局
  - 番缚 0/2/4、双倍/复合役满、累计役满
  - 食替、连风雀头符、国士抢暗杠、人和、包牌支付
  - 南四：胡牌连庄 / 听牌连庄 / 听牌终局 / 和了终局组合行为
  - 古役各项与宝牌/杠/海底组合


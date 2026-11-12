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


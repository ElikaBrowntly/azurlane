# 麻将结算面板 · 指示牌区 + 出牌按钮 — 规格说明（本轮）

## 1. 本轮三个需求

1. 结算界面两行宝牌指示牌全是牌背，一张都没翻开（立直和 / 副露和都一样）。
2. 出牌时"确定"按钮在未选牌时不可点；希望不选牌直接点即"摸切"，选牌后变回"确定"，取消选中再变回"摸切"。
3. 加杠按钮显示成英文键 `yyfy_mj_kakan_act`；希望明杠/暗杠/加杠都显示中文"杠"。

## 2. 根因

**需求 1**
- 牌山（`Card.DrawPile`）中的牌对客户端不可见：`ltk/client/util.lua:101 getCardData()`
  在 `Fk:getCardById(id)` 为 nil 时只回 `{ cid = id, known = false }`，没有 `name/number/suit`。
- 上一轮改用 `room:printCard()` 印副本，但副本同样受"牌 id 可见性"链路影响，实机仍然全牌背。
- 结论：**彻底不依赖牌 id**。服务端下发指示牌的"牌名 + 点数"，客户端用
  `Ltk.createCardModelFromName()` 现场造牌面（牌面贴图由 `SkinBank.getCardPicture(name)` 解析，
  `packages/hidden-clouds/image/card/yyfy_*.png` 存在）。
- 嵌套数组在框架的 Lua→QML 转换里不可靠（参见 `meldCards/meldLens` 的扁平化经验），
  因此牌名与点数分成两个**扁平数组**传递。

**需求 2**
- 客户端 `LunarLtk/Pages/Room.qml:414-419` 的确定按钮文案写死为 `Lua.tr("OK")`，
  本仓库（`packages/hidden-clouds/**`）无法改动，也无法只对本玩法改这个翻译键（客户端翻译表全局共享）。
- 可行做法：把打牌询问的 `min_num` 从 1 改成 0，未选牌即可点确定；服务端把"空选牌"当作摸切，
  打出本轮刚摸的牌（与超时/AI 兜底逻辑一致）。按钮文案仍是"确定"，因此在提示语里说明"不选牌直接点确定即为摸切"。

**需求 3**
- `ChoicesBox` 用 `Ltk.processPrompt()` 按单冒号 `split(":")` 取键名：
  `"yyfy_mj_kakan_act::yyfy_1m"` → `Lua.tr("yyfy_mj_kakan_act")`。
- `yyfy_mahjong_mode.lua` 的静态翻译表只有 `yyfy_mj_kan_act`，缺 `yyfy_mj_kakan_act`，
  客户端回退为原始键 → 英文按钮。补一条静态翻译即可（运行期 `Fk:loadTranslationTable` 的
  `"键::牌名"` 条目匹配不到单冒号拆分后的键）。

## 3. 方案

### 3.1 引擎：`yyfy_mahjong_engine.lua` → `M.BroadcastResult`

```lua
local function pushIndicator(names, numbers, ind)
  local card = ind and Fk:getCardById(ind)
  if not card then return end
  table.insert(names, card.name)
  table.insert(numbers, card.number or 1)
end
local omoteNames, omoteNumbers, uraNames, uraNumbers = {}, {}, {}, {}
for i = 1, state.dora_count do
  pushIndicator(omoteNames, omoteNumbers, state.indicator[i])
end
local uraRevealed = state.riichi[winner.id] ~= nil
if uraRevealed then
  for i = 5, 4 + state.dora_count do
    pushIndicator(uraNames, uraNumbers, state.indicator[i])
  end
end
```

payload：`doraCount`、`omoteIndicatorNames/Numbers`、`uraIndicatorNames/Numbers`、`uraRevealed`
（不再下发 `omoteIndicators/uraIndicators`）。

### 3.2 引擎：出牌询问（当前 L2358-2366 / L2439-2441）

```lua
min_num = riichiMode and 1 or 0,  -- 非立直宣言：允许空选（空选 = 摸切）
...
discardId = pick or handIds[1]
if turn.id <= 0 then room:delay(500) end  -- 仅 AI 停顿
```

空选牌时 `askToCards` 返回空表 → 走既有兜底：优先打 `state.new_draw_id`（刚摸的牌），
否则打第一张不在喰い替え禁打列表里的牌。

### 3.3 QML：`packages/hidden-clouds/qml/YyfyMahjongResultBox.qml`

- `indicatorSlotCount = 5` 不变；`omoteModels / uraModels` 为"牌面模型 + null 占位"数组。
- `indicatorModel(d)` 兼容：`{name, number}` 对象 / 数字 id（旧版，仍先 `isValidCard` 探测）/ 牌名。
- `buildIndicatorModels(d)`：优先读 `omote/uraIndicatorNames + …Numbers` 扁平数组，
  回退 `omote/uraIndicators`；按 `doraCount` 截断，补齐到 5 个槽位。
- delegate：`readonly property var cardData: root.omoteModels[index] || null`；
  `cardData !== null` → `CardItem`，否则 → 牌背 `Image`（`SkinBank.searchBuiltinPic("/image/card/", "card-back")`）。

### 3.4 文案：`yyfy_mahjong_mode.lua`

```lua
["yyfy_mj_kakan_act"] = "杠",            -- 与 yyfy_mj_kan_act 一致，明杠/暗杠/加杠都显示"杠"
["#yyfy_mj_discard_prompt"] = "请选择一张牌打出（不选牌直接点确定即为摸切）",
```

## 4. 验证

**静态（已完成）**
1. `luasyntax.py` 引擎、模式文件 → `SYNTAX OK`。
2. `qmlbalance_arg.py YyfyMahjongResultBox.qml` → 括号平衡。
3. `mj_verify.lua`：断言 `d.doraCount == 1`、`d.omoteIndicatorNames[1] == "yyfy_1m"` 且
   `omoteIndicatorNumbers[1] == 1`、立直时 `uraIndicatorNames[1] == "yyfy_3p"`、未立直时
   `#uraIndicatorNames == 0` 且 `uraRevealed == false` → `VERIFY OK`。

**实机（需用户）**
1. 立直和 / 副露和：宝牌行第一张为真实牌面，其余为牌背；立直和时里宝行第一张也是牌面。
2. 出牌：不选牌可直接点确定 → 打出刚摸的牌（摸切）；选牌后点确定 → 打出所选牌。
3. 杠：暗杠/加杠选项均为中文"杠"。
4. 控制台无 `Unable to assign [undefined] to QUrl`。

## 5. 明确不改动 / 已知限制

- `LunarLtk/**`、`packages/freekill-core/**`、根目录 `image/**`。
- 打牌"确定"按钮的**文案**写死在核心 QML，本仓库内无法改成"摸切"；行为上已支持空选即摸切。
- 引擎的役判定、符数、点数、立直 banner、报番顺序保持现状。

---

# 本轮：击飞终局崩溃 + 小三元漏判 — 规格说明

## 1. 本轮两个需求

1. **A**：把人击飞（点数 ≤ 0）后本应结束游戏并弹出结算，实际控制台报
   `QQmlComponent: Component is not ready` 与
   `RoomModel.qml:580: TypeError: Value is null and could not be converted to an object`，
   结算界面迟迟不出现。
2. **B**：碰了白板 + 红中、发财作雀头单吊，应计**小三元**，实际未计该役。

## 2. 根因

**A（击飞终局崩溃）**
- 崩溃点在核心 `packages/freekill-core/LunarLtk/Models/RoomModel.qml:577-583`：
  ```qml
  function gameOver(sender, jsonData) {
    const modelComponent = Qt.createComponent("LunarLtk.Models.Popups", "GameOverModel");
    const model = modelComponent.createObject();
    model.winner = jsonData;      // ← 第 580 行 TypeError：model 为 null
  ```
- 日志里只有 `Component is not ready`，**没有任何 QML 编译错误**，说明组件状态是 `Loading`（
  首次使用时类型尚在异步加载），而 `createObject()` 在非 `Ready` 状态直接返回 null。
- 因此后续 `popupReady(GameOver)` 与 `deActivate()` 都没执行：结算不弹、对局页面不退出。
- 已排除：`Qt.labs.qmlmodels` 模块/插件缺失、两处 `LunarLtk.Models.Popups/qmldir` 缺项、
  `LunarLtk.Pages.Popups` 缺 GameOverBox、该 API 整体不可用（ChoicesModel/PhotoModel/AGModel 均正常）。
- 核心 QML 不可改，只能在 `hidden-clouds` 内让该类型**在终局前就完成加载**。
- 时序上可行：每局胡牌都会先 `BroadcastResult`（弹出 `YyfyMahjongResultBox`）→
  `room:delay(3000)` → `M.Transfer` → 若击飞再 `room:delay(2000)` → `room:gameOver`。
  即结算面板出现**至少 5 秒**后才可能触发终局广播。

**B（小三元漏判）**
- 引擎 `M.EvalYaku` 只实现了大三元（`hasTri(31) and hasTri(32) and hasTri(33)`），
  **全仓库没有任何小三元实现**。
- 现有可用信息：`hasTri(t)` 判断某类型是否有刻子；`form.pair` 是雀头牌种；
  三元牌类型为 31=白、32=发、33=中。
- 小三元条件：三元牌中恰有两组刻子，剩下那种三元牌作雀头。
- 番数：门前 2 番、副露 1 番（食い下がり），与既有 `openPenalty` 约定一致。

## 3. 方案

### 3.1 A：结算面板内预热 `GameOverModel` 类型

文件：`packages/hidden-clouds/qml/YyfyMahjongResultBox.qml`（根 `GraphicsBox`）

```qml
  // 核心 RoomModel.gameOver() 里是同步 createComponent("LunarLtk.Models.Popups","GameOverModel")
  // 再 createObject()；该类型首次使用时可能仍是 Loading，导致 createObject() 返回 null
  // 并抛 TypeError，终局结算弹不出来。结算面板每局都先于终局出现，
  // 在这里把该类型提前加载进 QML 引擎的类型缓存。
  property var gameOverPrewarm: null

  Component.onCompleted: prewarmGameOverModel()

  function prewarmGameOverModel() {
    try {
      const comp = Qt.createComponent("LunarLtk.Models.Popups", "GameOverModel");
      if (!comp) return;
      gameOverPrewarm = comp;   // 持有引用，避免加载完成前被回收

      const warm = function () {
        if (comp.status !== Component.Ready) {
          console.warn("YyfyMahjongResultBox: GameOverModel 预热失败:",
                       comp.errorString());
          return;
        }
        // 实例化一次再销毁：让 Qt.labs.qmlmodels / TableModel 的插件与类型彻底就绪，
        // 之后核心的 createComponent + createObject 才能稳定拿到非 null 对象。
        // GameOverModel 只在 winner 变化时才播音/读战绩，这里不设 winner，无副作用。
        try {
          const obj = comp.createObject();
          if (obj) obj.destroy();
        } catch (e) {
          console.warn("YyfyMahjongResultBox: GameOverModel 预实例化失败", e);
        }
      };

      if (comp.status === Component.Loading) comp.statusChanged.connect(warm);
      else warm();
    } catch (e) {
      console.warn("YyfyMahjongResultBox: 无法预热 GameOverModel", e);
    }
  }
```

- 先加载，`Ready` 后再实例化一次并立即 `destroy()`，确保插件与类型缓存都已完成。
- 同时只编译加载 `LunarLtk.Pages.Popups` 的 `GameOverBox`（核心在 model 就绪后用它弹窗），
  不实例化以免提前显示弹窗。
- 每个对局至少会弹一次结算面板（胡牌必走 `BroadcastResult`，广播给所有客户端），
  因此各客户端都会在终局前完成预热。
- 若预热最终是 `Error`，会打印 `errorString` 便于后续定位；届时备选方案是
  在服务端 `gameOver` 前用 `Fk:addMiniGame` 弹自定义终局面板（本规格暂不实施）。

### 3.2 B：引擎补小三元

文件：`packages/hidden-clouds/pkg/gamemodes/yyfy_mahjong_engine.lua` → `M.EvalYaku`
（`elseif form then` 分支内、役牌计数之后，约 L1281 之后）

```lua
    -- 小三元：两组三元牌刻子 + 第三种三元牌作雀头（2 番，副露 -1 番）
    local dragonTri = 0
    for _, t in ipairs{ 31, 32, 33 } do
      if hasTri(t) then dragonTri = dragonTri + 1 end
    end
    if dragonTri == 2 and form.pair and form.pair >= 31 and form.pair <= 33 then
      addYaku("yyfy_yaku_shousangen", 2 + openPenalty)
    end
```

- 大三元仍走前面的役满分支提前返回，二者不会重复计。
- 与役牌可复合（两组三元牌刻子各 +1 番），符合立直麻将规则。

### 3.3 B：补翻译

文件：`packages/hidden-clouds/pkg/gamemodes/yyfy_mahjong_mode.lua` 静态翻译表（约 L259 役牌附近）

```lua
  ["yyfy_yaku_shousangen"] = "小三元",
```

## 4. 验证

**静态**
1. `luasyntax.py` 检查引擎、模式文件 → `SYNTAX OK`。
2. `qmlbalance_arg.py` 检查 `YyfyMahjongResultBox.qml` → 括号平衡。
3. 新建临时脚本 `mj_shousangen_verify.lua`（放 `C:\Users\Lenovo\AppData\Local\Temp\`）：
   stub `Fk:getCardById / Fk:translate / table.simpleClone` 等，构造
   `form = { mentsu = { 白刻, 中刻, 两个数牌顺子 }, pair = 33 }` 直接调用 `M.EvaluateYaku`，
   断言返回的 `yaku` 含 `yyfy_yaku_shousangen`；再构造副露版本断言番数为 1（门前为 2）。
4. `mj_verify.lua` 回归（上轮指示牌/摸切相关断言）仍 `VERIFY OK`。

**实机（需用户）**
1. 击飞对手 → 终局结算正常弹出，日志不再出现 `RoomModel.qml:580 TypeError`。
2. 碰白 + 中、发财作雀头 → 结算报番含"小三元"。

## 5. 明确不改动 / 已知限制

- `LunarLtk/**`、`packages/freekill-core/**`、根目录 `image/**` 一律只读。
- 不改核心 `RoomModel.qml` / `GameOverModel.qml`；A 只在自家结算面板做类型预热。
- 若预热后仍报 `Component is not ready`，需在下一轮改用自定义终局面板方案。

---

# 麻将地方规则开关（34 项）

## 1. 结构

| 文件 | 作用 |
| --- | --- |
| `pkg/gamemodes/yyfy_mahjong_rules.lua` | 唯一配置表 `RULES`，34 项 + `tailRiichi` |
| `pkg/gamemodes/yyfy_mahjong_engine.lua` | `local RULES = require "...yyfy_mahjong_rules"`，全部判定读取开关 |
| `pkg/gamemodes/yyfy_mahjong_mode.lua` | `build_draw_pile` 读 `RULES.fourRed`；新增流局/小三元文案 |
| `qml/YyfyMahjongResultBox.qml` | 支持 `abortText + handNames/handNumbers` 的流局展示 |

默认值 = 此前实现的行为，因此不改配置时玩法与此前一致。

## 2. 各开关实现位置

1. **四赤** `fourRed`：`build_draw_pile` 筒子 2 张 `yyfy_0p` + 2 张 `yyfy_5p`；赤宝牌上限 4。
2. **食断** `kuitan`：断幺判定 `RULES.kuitan or #melds == 0`。
3. **西入** `seiu`：`M.Run` 中 round 进入 9（南四过庄）时，无人 ≥30000 才续战；西/北场每局结束有人 ≥30000 即终局；最多北四（round 16）。
4. **和了终局** `winEndgame`：南四和牌连庄（round 仍为 8）时，开启则"尾亲为一位且 >30000"必须终局（原"尾亲连庄"取反）。
5. **击飞** `tobi`：`M.Transfer` 仅点数 `< 0` 击飞；立直要求点数 ≥1000。
6. **流局满贯** `nagashiMangan`：`M.DoExhaustive` 只在开启时调用 `GetNagashiPlayers`。
7. **切上满贯** `kiriageMangan`：`basePoints` 把 4 番 30 符 / 3 番 60 符按 2000 基础点。
8. **表宝牌** `omoteDora`：`EvalYaku` 表宝段、手牌宝牌标记、初始 banner 均受控。
9. **杠表宝牌** `kanOmoteDora`：`M.RevealKanDora` 内表宝段。
10. **里宝牌** `uraDora`：`EvalYaku` 里宝段、`SettleWin` 揭晓、`BroadcastResult.uraRevealed`。
11. **杠里宝牌** `kanUraDora`：`M.RevealKanDora` 内 `ura_count` 段。
12. **明杠宝牌即翻** `kanDoraImmediate`：`M.OnKan(..., deferDora)`；关闭时切牌后（或岭上自摸结算前）再翻。
13. **四风连打** `fourWindAbort`：弃牌无人响应分支，四家首弃同风且 `state.no_meld` → 流局。
14. **四杠散了** `fourKanAbort`：第 4 杠后 `kan_discard_pending`；该弃牌被荣和按正常放铳（不判河底），被副露则继续，通过则流局。
15. **五杠流局** `fiveKanAbort`：开启允许第 5 杠，开杠通过后立即流局（不摸岭上）；关闭时第 5 杠不可宣言。
16. **四家立直** `fourRiichiAbort`：第四家立直弃牌通过后流局。
17. **九种九牌** `nineTerminals`：首次打牌前询问；同种只算 1 种；`M.SettleKyuushu` 流局并展示手牌。
18. **三家和了流局** `tripleRonAbort`：`M.CheckClaims` 中三家荣和时返回 `"abort"`，`M.PlayRound` 转 `DoAbortiveDraw`；加杠抢杠同理。
19. **头跳** `atamahane`：开启时荣家列表只取座次第一个（下家优先）；关闭时保留一炮多响。
20. **胡牌连庄** `dealerWinRenchan`：`M.Run` 中庄家和牌是否连庄。
21. **听牌连庄** `tenpaiRenchan`：`M.Run` 中通常流局庄家听牌是否连庄；途中流局（`abortive_draw`）不受影响。
22. **听牌终局** `tenpaiEndgame`：南四通常流局且尾亲为一位时，听牌按西入/30000 判定，没听直接终局。
23. **一发** `ippatsu`：`EvalYaku` 中一发役受控（`state.ippatsu` 逻辑不变）。
24. **番缚** `hanShibari`：`M.CanSettle` 用"役番合计 ≥ 番缚"，0 表示无役也可和。
25. **双倍役满** `doubleYakuman`：`ykW(2)` 控制四暗刻单骑/纯正九莲/国士十三面/大四喜/大七星。
26. **复合役满** `compoundYakuman`：`applyCompound` 在关闭时只保留权重最高的役满。
27. **食替** `kuikaeAllowed`：`buildDiscardAsk` 与超时兜底跳过 `kuikae_forbid`。
28. **尾巡立直** `tailRiichi`：立直可宣条件。
29. **连风雀头** `doubleWindPairFu`：`computeFu` 双风雀头符数（2 或 4）。
30. **国士抢杠** `kokushiChankan`：暗杠前 `M.CheckKokushiAnkan` 允许国士荣和。
31. **人和** `renhou`：`M.CheckClaims` 判定 `info.renhou`，`EvalYaku` 记为役满。
32. **包牌** `pao`：`findPao` 判定责任者，`M.SettleWin` 拆分包牌点数结算。
33. **累计役满** `kazoeYakuman`：`basePoints` 中 13 番以上 8000/6000 基础点。
34. **古役** `oldYaku`：`EvalYaku` 中燕返/杠上炮/十二落抬/五门齐/三连刻/一色三同顺/一筒摸月/九筒捞鱼及古役满。

## 3. 关键状态

- `state.dora_count`（表宝牌数）/ `state.ura_count`（里宝牌数），开局均为 1，最多 4。
- `state.pending_kan_dora`：明杠延迟翻宝牌。
- `state.kan_discard_pending`：第四杠后待判定四杠散了。
- `state.kyuushu_asked`：每局每人只询问一次九种九牌。
- `state.after_kan_pending`：刚开杠未出牌的玩家（杠上炮）。
- `state.last_discard_riichi` / `last_discard_after_kan`：最近舍牌是否立直宣言 / 紧接开杠（燕返、杠上炮）。
- `state.round_draw` / `state.dealer_tenpai` / `state.abortive_draw`：流局性质与庄家听牌（听牌终局/连庄）。

## 4. 验证

**静态（已完成）**：`SYNTAX OK`（规则/引擎/模式）、QML 括号平衡、
`mj_rules_verify.lua`（34 个默认值、表/里宝开关、小三元 2 番）→ `VERIFY OK`。

**实机（需用户）**：默认配置行为不变；逐项切换验证（见 `tasks.md` T31）。

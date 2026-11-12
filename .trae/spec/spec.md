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

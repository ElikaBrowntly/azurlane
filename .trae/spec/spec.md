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

// SPDX-License-Identifier: GPL-3.0-or-later
// 夜隐浮云·麻将模式：胡牌结算界面
// 由服务端 broadcast("ObserverMiniGame") 推送到客户端，客户端以
// Qt.createComponent(Cpp.path + "/" + component.url) 加载本文件，
// 随后调用 loadData(data) 注入结算数据；关闭时发出 finished() 供框架销毁。
// 注意：本文件必须自带 loadData 与 finished（GraphicsBox 已提供 finished 信号）。
import QtQuick 2.15
import QtQuick.Controls
import Fk
import Fk.Components.Common
import LunarLtk
import LunarLtk.Pages.Popups
import LunarLtk.Components

GraphicsBox {
  id: root

  width: Math.min(Config.winWidth * 0.96, 1120)
  height: Math.min(Config.winHeight * 0.90, 820)

  // 标题稍微下移，避免贴着窗口顶边
  title.anchors.topMargin: 18

  property var info: null
  property var entries: []        // 卡片展示的扁平列表（gap=true 表示该张前留空）
  property int revealed: 0        // 已"出现"的役种条数
  property real cardScale: 0.5

  readonly property int gapWidth: 26
  // 役种/番数排版：番名列定宽（留足 6 字）、番数列定宽（右对齐）
  readonly property int yakuFontSize: 27
  readonly property int totalFontSize: 30
  readonly property int yakuRowHeight: 38
  readonly property int yakuNameWidth: 170
  readonly property int yakuHanWidth: 56
  readonly property int yakumanFontSize: 40
  readonly property int scoreFontSize: 46
  readonly property int indicatorLabelFontSize: 24
  readonly property int indicatorLabelWidth: 150
  readonly property real indicatorScale: Math.max(0.26, cardScale * 0.75)
  // 每行固定 5 个槽位：已翻开的显示牌面，其余显示牌背
  readonly property int indicatorSlotCount: 5
  // 已翻开指示牌的牌面模型。牌山里的牌客户端不可见（getCardData 只回
  // known=false，没有 name/number/suit），因此服务端改为下发"牌名+点数"，
  // 这里用 createCardModelFromName 现场造牌面，彻底绕开牌 id 是否可见的问题。
  property var omoteModels: []
  property var uraModels: []

  // 数据兼容：Lua 的"空表"传到 QML 后会变成普通对象而不是数组，
  // 直接 for...of 会抛异常，因此所有来列表都先经过这里。
  // 注意两种情况：真正的 JS 数组（含 Qt 的 QVariantList 代理，带 length 且从 0 开始）
  // 与 Lua 空表/字符串键对象（1 开始）。前者若按 1 开始遍历会丢掉第一项，
  // 表现为报番漏掉第一条（立直）或只有一张的宝牌指示牌整行消失。
  function toList(v) {
    if (!v) return [];
    if (Array.isArray(v)) return v;
    if (typeof v === "object") {
      const len = v.length;
      if (typeof len === "number" && len > 0) {
        const arr = [];
        for (let i = 0; i < len; i++) arr.push(v[i]);
        return arr;
      }
      const out = [];
      for (let i = 1; v[i] !== undefined; i++) out.push(v[i]);
      return out;
    }
    return [];
  }

  readonly property bool hasYakuman: toList(info ? info.yakuman : null).length > 0
  // 役满总权重（单倍=1、两倍=2、复合役满求和）
  readonly property int yakumanWeight: (info && info.yakumanTotalWeight !== undefined)
    ? info.yakumanTotalWeight
    : toList(info ? info.yakuman : null).length
  // 逐条"出现"的总条数：役满时按役满个数，否则按役种个数
  readonly property int revealTotal: {
    if (!info) return 0;
    if (hasYakuman) return toList(info.yakuman).length;
    return toList(info.yaku).length;
  }

  // 组装展示顺序：手牌区 + 间隔 + 副露区 + 间隔 + 和牌张
  function buildEntries(d) {
    const out = [];
    if (!d) return out;
    // 无效牌 id（undefined / null / -1）不参与展示，否则会创建出缺少 suit/number
    // 的 CardModel，进而在 PokerCard.qml 里触发 "Unable to assign [undefined] to QUrl"
    const valid = id => id !== undefined && id !== null && id !== -1;
    for (const id of toList(d.handIds)) {
      if (valid(id)) out.push({ id: id });
    }
    const lens = toList(d.meldLens);
    const mcards = toList(d.meldCards);
    let mi = 0;
    for (const len of lens) {
      for (let k = 0; k < len; k++) {
        const id = mcards[mi];
        if (valid(id)) out.push({ id: id, gap: (k === 0) });
        mi++;
      }
    }
    if (valid(d.winTileId)) out.push({ id: d.winTileId, gap: true });
    return out;
  }

  function generalName() {
    if (info && info.general) return info.general;
    return "blank_shibing";
  }

  // 单个指示牌描述 → 牌面模型。兼容三种输入：
  // 1. 对象 { name, number }（新服务端，推荐）
  // 2. 数字 id（旧服务端）：仅在客户端能取到该牌牌名时可用
  // 3. 牌名字符串
  function indicatorModel(d) {
    try {
      if (d === undefined || d === null) return null;
      if (typeof d === "number") {
        if (!isValidCard(d)) return null;
        return Ltk.createCardModel(d, { known: true, suit: "nosuit", color: "nocolor" });
      }
      if (typeof d === "string") d = { name: d };
      if (!d.name) return null;
      const number = (d.number === undefined || d.number === null) ? 1 : d.number;
      return Ltk.createCardModelFromName(d.name,
        { known: true, suit: "nosuit", color: "nocolor", number: number });
    } catch (e) {
      console.warn("YyfyMahjongResultBox: 指示牌模型创建失败", e);
      return null;
    }
  }

  // 组装两行指示牌模型：按固定槽位补齐 null（null 槽位显示牌背）。
  // 新服务端下发两个扁平数组 omoteIndicatorNames / omoteIndicatorNumbers
  // （嵌套数组在框架的 Lua→QML 转换里不可靠，故扁平化传递）；
  // 旧服务端仍可能下发 omoteIndicators（id / 对象 / 牌名）。
  function indicatorEntries(d, kind) {
    const names = toList(d[kind + "IndicatorNames"]);
    if (names.length > 0) {
      const nums = toList(d[kind + "IndicatorNumbers"]);
      const out = [];
      for (let i = 0; i < names.length; i++) {
        out.push({ name: names[i], number: nums[i] });
      }
      return out;
    }
    return toList(d[kind + "Indicators"]);
  }

  function buildIndicatorModels(d) {
    let omote = [];
    if (d) {
      const arr = indicatorEntries(d, "omote");
      let count = arr.length;
      if (d.doraCount !== undefined && d.doraCount !== null) {
        const n = Number(d.doraCount);
        if (isFinite(n) && n >= 0) count = Math.min(arr.length, n);
      }
      for (let i = 0; i < count; i++) omote.push(indicatorModel(arr[i]));
    }
    while (omote.length < indicatorSlotCount) omote.push(null);

    let ura = [];
    if (d && d.uraRevealed) {
      const arr = indicatorEntries(d, "ura");
      let count = arr.length;
      if (d.doraCount !== undefined && d.doraCount !== null) {
        const n = Number(d.doraCount);
        if (isFinite(n) && n >= 0) count = Math.min(arr.length, n);
      }
      for (let i = 0; i < count; i++) ura.push(indicatorModel(arr[i]));
    }
    while (ura.length < indicatorSlotCount) ura.push(null);

    omoteModels = omote;
    uraModels = ura;
  }

  // 统一构造牌面模型。本面板展示的全是麻将牌（NoSuit 牌），这里显式给定
  // suit/color，避免缺字段时把 undefined 传给 PokerCard 的花色贴图，
  // 触发 "Unable to assign [undefined] to QUrl" 警告。
  function cardModel(id) {
    return Ltk.createCardModel(id, { known: true, suit: "nosuit", color: "nocolor" });
  }

  // 牌 id 是否可用：客户端对牌山里未公开的牌只拿到 known=false（无 name/number/suit），
  // 直接用这类 id 造模型会渲染失败并触发 QUrl undefined 警告，因此先探测再用。
  function isValidCard(id) {
    if (typeof id !== "number" || id === 0) return false;
    const data = Ltk.getCardData(id);
    return !!(data && data.name !== undefined);
  }

  function apply(d) {
    info = null;
    entries = [];
    revealed = 0;
    omoteModels = [];
    uraModels = [];
    info = d;
    entries = buildEntries(d);
    buildIndicatorModels(d);
    // 按可用宽度自适应牌的大小（含分组间隔）
    const gaps = entries.filter(e => e.gap).length;
    const avail = Math.max(360, root.width - 190);
    const s = (avail - gaps * gapWidth) / Math.max(1, entries.length * 93);
    cardScale = Math.max(0.26, Math.min(0.62, s));
    revealTimer.restart();
    hideTimer.restart();
  }

  function loadData(d) {
    try {
      let p = d;
      if (typeof p === "string") p = JSON.parse(p);
      if (p && typeof p.payload === "string") p = JSON.parse(p.payload);
      else if (p && p.payload && typeof p.payload === "object") p = p.payload;
      apply(p || {});
    } catch (e) {
      console.warn("YyfyMahjongResultBox: 组装结算数据失败", e);
      info = {};
      entries = [];
      revealed = 0;
    }
  }

  function closePanel() {
    revealTimer.stop();
    hideTimer.stop();
    root.finished();
  }

  title.text: root.info
    ? ((root.info.screenName || "") + " " + Lua.tr(root.info.tsumo
        ? "yyfy_mj_result_tsumo" : "yyfy_mj_result_ron"))
    : ""

  // 点击任意处关闭（牌面只读，不需要其它交互）
  MouseArea {
    anchors.fill: parent
    onClicked: root.closePanel()
  }

  Item {
    id: body
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: root.title.bottom
    anchors.bottom: parent.bottom
    anchors.leftMargin: 18
    anchors.rightMargin: 18
    anchors.topMargin: 8
    anchors.bottomMargin: 10

    // 左侧：武将卡图
    GeneralCardItem {
      id: resultGeneral
      anchors.left: parent.left
      anchors.top: parent.top
      dataModel: Ltk.createGeneralCardModel(root.generalName())
    }

    // 右上：和牌手牌（手牌 + 间隔 + 副露 + 间隔 + 和牌张）
    Item {
      id: resultCards
      anchors.left: resultGeneral.right
      anchors.leftMargin: 16
      anchors.right: parent.right
      anchors.top: parent.top
      height: 130 * root.cardScale

      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        spacing: 0

        Repeater {
          model: root.entries

          delegate: Item {
            width: 93 * root.cardScale + (modelData.gap ? root.gapWidth : 0)
            height: 130 * root.cardScale

            CardItem {
              anchors.right: parent.right
              anchors.top: parent.top
              cardScale: root.cardScale
              showDetail: false
              dataModel: root.cardModel(modelData.id)
            }
          }
        }
      }
    }

    // 手牌行下方：宝牌指示牌 / 里宝指示牌
    Column {
      id: resultIndicators
      anchors.top: resultCards.bottom
      anchors.topMargin: 6
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 4

      Row {
        spacing: 8

        Text {
          width: root.indicatorLabelWidth
          horizontalAlignment: Text.AlignRight
          text: Lua.tr("yyfy_mj_dora_indicator")
          color: "#F5E6A8"
          font.family: Config.libianName
          font.pixelSize: root.indicatorLabelFontSize
          style: Text.Outline
          styleColor: "#2E200F"
        }

        Repeater {
          model: root.indicatorSlotCount

          delegate: Item {
            id: omoteSlot
            width: 93 * root.indicatorScale
            height: 130 * root.indicatorScale
            // 已翻开的显示牌面模型，其余槽位为 null（显示牌背）
            readonly property var cardData: root.omoteModels[index] || null

            Rectangle {
              anchors.fill: parent
              radius: 4
              color: "#7A4E2D"
              border.color: "#3B2612"
              border.width: 1
            }

            Image {
              visible: omoteSlot.cardData === null
              anchors.fill: parent
              smooth: true
              fillMode: Image.PreserveAspectCrop
              source: SkinBank.searchBuiltinPic("/image/card/", "card-back")
            }

            Loader {
              anchors.centerIn: parent
              active: omoteSlot.cardData !== null
              sourceComponent: Component {
                CardItem {
                  cardScale: root.indicatorScale
                  showDetail: false
                  dataModel: omoteSlot.cardData
                }
              }
            }
          }
        }
      }

      Row {
        spacing: 8

        Text {
          width: root.indicatorLabelWidth
          horizontalAlignment: Text.AlignRight
          text: Lua.tr("yyfy_mj_ura_indicator")
          color: "#F5E6A8"
          font.family: Config.libianName
          font.pixelSize: root.indicatorLabelFontSize
          style: Text.Outline
          styleColor: "#2E200F"
        }

        Repeater {
          model: root.indicatorSlotCount

          delegate: Item {
            id: uraSlot
            width: 93 * root.indicatorScale
            height: 130 * root.indicatorScale
            // 只有立直家胡牌才揭晓里宝；未揭晓的槽位为 null（显示牌背）
            readonly property var cardData: root.uraModels[index] || null

            Rectangle {
              anchors.fill: parent
              radius: 4
              color: "#7A4E2D"
              border.color: "#3B2612"
              border.width: 1
            }

            Image {
              visible: uraSlot.cardData === null
              anchors.fill: parent
              smooth: true
              fillMode: Image.PreserveAspectCrop
              source: SkinBank.searchBuiltinPic("/image/card/", "card-back")
            }

            Loader {
              anchors.centerIn: parent
              active: uraSlot.cardData !== null
              sourceComponent: Component {
                CardItem {
                  cardScale: root.indicatorScale
                  showDetail: false
                  dataModel: uraSlot.cardData
                }
              }
            }
          }
        }
      }
    }

    // 下方：役种与番数，自上而下逐条"出现"
    Column {
      id: resultYakuCol
      anchors.top: resultIndicators.bottom
      anchors.topMargin: 10
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 4

      Repeater {
        model: (root.hasYakuman && root.info) ? root.toList(root.info.yakuman) : []

        delegate: Text {
          opacity: index < root.revealed ? 1 : 0
          x: index < root.revealed ? 0 : -28
          Behavior on opacity { NumberAnimation { duration: 220 } }
          Behavior on x { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }

          text: Lua.tr(modelData)
          color: "#F5E6A8"
          font.family: Config.libianName
          font.pixelSize: root.yakumanFontSize
          font.bold: true
          style: Text.Outline
          styleColor: "#2E200F"
        }
      }

      Repeater {
        model: (root.info && !root.hasYakuman) ? root.toList(root.info.yaku) : []

        delegate: Row {
          spacing: 0
          opacity: index < root.revealed ? 1 : 0
          x: index < root.revealed ? 0 : -28
          Behavior on opacity { NumberAnimation { duration: 220 } }
          Behavior on x { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }

          Text {
            width: root.yakuNameWidth
            horizontalAlignment: Text.AlignLeft
            text: Lua.tr(modelData.key)
            color: "#F5E6A8"
            font.family: Config.libianName
            font.pixelSize: root.yakuFontSize
            style: Text.Outline
            styleColor: "#2E200F"
          }

          Text {
            width: root.yakuHanWidth
            horizontalAlignment: Text.AlignRight
            text: modelData.han
            color: "#F5E6A8"
            font.family: Config.libianName
            font.pixelSize: root.yakuFontSize
            style: Text.Outline
            styleColor: "#2E200F"
          }

          Text {
            text: Lua.tr("yyfy_mj_han")
            color: "#F5E6A8"
            font.family: Config.libianName
            font.pixelSize: root.yakuFontSize
            style: Text.Outline
            styleColor: "#2E200F"
          }
        }
      }

      // 报番与合计之间留空
      Item {
        width: root.yakuNameWidth + root.yakuHanWidth
        height: root.yakuRowHeight
        visible: root.info && root.revealed >= root.revealTotal
      }

      Text {
        visible: root.info && root.revealed >= root.revealTotal
        text: root.hasYakuman
          ? (Lua.tr("yyfy_mj_total_han") + (root.yakumanWeight === 1
              ? Lua.tr("yyfy_mj_yakuman")
              : (root.yakumanWeight === 2
                  ? "两" + Lua.tr("yyfy_mj_yakuman_multi")
                  : root.yakumanWeight + Lua.tr("yyfy_mj_yakuman_multi"))))
          : (Lua.tr("yyfy_mj_total_han") + (root.info ? root.info.han : 0) + Lua.tr("yyfy_mj_han")
              + ((root.info && root.info.fu !== undefined && root.info.fu !== null)
                  ? "  " + root.info.fu + Lua.tr("yyfy_mj_fu") : ""))
        color: "#FFD98A"
        font.family: Config.libianName
        font.pixelSize: root.totalFontSize
        font.bold: true
        style: Text.Outline
        styleColor: "#2E200F"
      }

      // 分数等式：原始分 + 本场/场供加算 = 总分
      Text {
        visible: root.info && root.revealed >= root.revealTotal
          && root.info.totalScore !== undefined
        text: (root.info ? root.info.baseScore : 0) + "+"
          + (root.info ? root.info.bonusScore : 0) + "="
          + (root.info ? root.info.totalScore : 0)
        color: "#FFE9A8"
        font.family: Config.libianName
        font.pixelSize: root.scoreFontSize
        font.bold: true
        style: Text.Outline
        styleColor: "#2E200F"
      }
    }
  }

  MetroButton {
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 6
    anchors.horizontalCenter: parent.horizontalCenter
    text: Lua.tr("OK")
    onClicked: root.closePanel()
  }

  Timer {
    id: revealTimer
    interval: 360
    repeat: true
    onTriggered: {
      const n = root.revealTotal;
      if (root.revealed < n) root.revealed++;
      else revealTimer.stop();
    }
  }

  Timer {
    id: hideTimer
    interval: 7000
    onTriggered: root.closePanel()
  }
}

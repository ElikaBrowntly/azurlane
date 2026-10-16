// SPDX-License-Identifier: GPL-3.0-or-later
// 夜隐浮云·麻将模式：吃/碰分组选项框的数据模型
// ids 为扁平数组：每相邻两个元素构成一组（每组是能用来吃/碰的两张手牌 id）。
// 注意：不传嵌套数组，避免框架对 Lua 表格浅转换后内层不是可迭代列表。
import QtQuick 2.15
import Fk
import LunarLtk

QtObject {
    id: root

    // 输入数据
    property var ids: []               // 扁平：{a1,b1, a2,b2, ...}
    property var prompt: ""
    property string kind: "chi"        // chi | pon
    property bool cancelable: true
    readonly property int groupCount: Math.floor(root.ids.length / 2)
    readonly property string promptText: Ltk.processPrompt(prompt)

    // 框架要求的输出和信号
    property var result: null
    property bool done: false
    signal accepted()
    signal rejected()

    // 第 group 组的第 offset 张牌（offset 为 0 或 1）
    function idAt(group, offset) {
        return root.ids[group * 2 + offset];
    }

    function selectGroup(index) {
        if (root.done) return;
        if (index < 0 || index >= root.groupCount) return;
        root.done = true;
        root.result = { index: index, ids: [idAt(index, 0), idAt(index, 1)] };
        root.accepted();
    }

    function reject() {
        if (root.done) return;
        root.done = true;
        root.rejected();
    }
}

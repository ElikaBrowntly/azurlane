// SPDX-License-Identifier: GPL-3.0-or-later
// 夜隐浮云·麻将模式：吃/碰分组选项框的数据模型
// groups 为二维数组，每个元素是一组能用来吃/碰的两张手牌 id（按卡图显示）
import QtQuick 2.15
import Fk
import LunarLtk

QtObject {
    id: root

    // 输入数据
    property var groups: []
    property var prompt: ""
    property string kind: "chi"       // chi | pon
    property bool cancelable: true
    readonly property string promptText: Ltk.processPrompt(prompt)

    // 框架要求的输出和信号
    property var result: null
    property bool done: false
    signal accepted()
    signal rejected()

    function selectGroup(index) {
        if (root.done) return;
        if (index < 0 || index >= root.groups.length) return;
        root.done = true;
        root.result = { index: index, ids: root.groups[index] };
        root.accepted();
    }

    function reject() {
        if (root.done) return;
        root.done = true;
        root.rejected();
    }
}

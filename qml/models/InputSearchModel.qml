// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick 2.12
import Fk
import LunarLtk

QtObject {
    id: root

    // 输入提示文本（可由 Lua 通过 prop 传入）
    property string prompt: "请宣言一个武将名（至少一个字）："
    
    // 当前输入内容（双向绑定）
    property string inputText: ""
    
    // 最终结果（框架要求）
    property var result: inputText
    
    // 框架需要的信号
    signal accepted()
    signal rejected()
    
    // 便捷属性
    readonly property bool canConfirm: inputText.trim().length > 0
    
    // 由视图调用的确认方法
    function doAccept() {
        result = inputText.trim()
        accepted()
    }
    
    // 由视图调用的取消方法
    function doReject() {
        rejected()
    }
}
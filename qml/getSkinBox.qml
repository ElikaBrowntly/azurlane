// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick 2.12
import "models"
import LunarLtk.Pages.Popups

// 纯占位视图
GraphicsBox {
    id: root

    required property getSkinModel dataModel

    // 隐藏
    width: 1
    height: 1
    visible: false

    Component.onCompleted: {
        // 调用模型处理业务逻辑
        dataModel.process()
        // 处理完成后立即关闭对话框
        // 使用 Qt.callLater 确保模型内部的 accepted 信号已经发出
        Qt.callLater(function() {
            root.close()
        })
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Fk
import LunarLtk
import LunarLtk.Components
import LunarLtk.Pages.Popups
import Fk.Components.Common
import "models"

GraphicsBox {
    id: root

    // 使用父容器尺寸，避免 Screen.height 大于实际显示区域导致纵向裁剪
    width: parent ? parent.width : Screen.width
    height: parent ? parent.height : Screen.height

    title.text: "穗织命运线"

    // 隐藏基础背景并禁用其拖拽
    background.visible: false

    // ============== 核心属性 ==============
    property int can: 0                 // 1=技能使用者可操作, 0=旁观者
    property bool isOver: false         // 游戏是否已结束
    property bool choiceLocked: false   // 当前题目是否已选择（防重复点击）
    property var selectedOptionIds: ({}) // 记录每道题已选的选项id { qid: optId }
    property real sakuraOpacity: 0.3    // 樱花色高亮透明度（0~1）

    // ============== 模型 ==============
    QianlianWanhuaModel {
        id: gameModel
    }

    // ============== 全屏背景 ==============
    Rectangle {
        anchors.fill: parent
        color: "black"
        clip: true
        z: 0

        Image {
            id: bgImage
            height: parent.height * bgScale
            width: height * aspectRatio
            anchors.centerIn: parent
            source: gameModel.getCurrentBg()
            fillMode: Image.Stretch

            property real bgScale: 1.02   // 纵向等比放大，覆盖底部小缝
            property real aspectRatio: sourceSize.width > 0 && sourceSize.height > 0
                                       ? sourceSize.width / sourceSize.height
                                       : 16 / 9
        }
    }

    // ============== 选项点击区域 ==============
    Repeater {
        id: optionRepeater
        model: gameModel.currentQuestion ? gameModel.getCurrentOptions() : []

        delegate: Item {
            // 相对坐标映射到屏幕绝对坐标
            property real relX: modelData.area.x
            property real relY: modelData.area.y
            property real relW: modelData.area.w
            property real relH: modelData.area.h

            // 基于背景图实际显示尺寸计算
            x: bgImage.x + relX * bgImage.width
            y: relY * bgImage.height
            width: relW * bgImage.width
            height: relH * bgImage.height

            // 调参时可见（改为 true），正式运行时隐藏边框但保留点击区域
            visible: modelData.visible || selectedOptionIds[gameModel.currentQuestion ? gameModel.currentQuestion.id : ""] === modelData.id

            // 选项边框（默认隐藏，调参时可改 visible 为 true）
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.color: "#00FF00"
                border.width: 2
                radius: 4
                opacity: 0
                visible: false
            }

            // 樱花色高亮层（选中后显示）
            Rectangle {
                anchors.fill: parent
                color: "#FFB7C5"
                opacity: root.sakuraOpacity
                radius: 4
                visible: selectedOptionIds[gameModel.currentQuestion ? gameModel.currentQuestion.id : ""] === modelData.id
            }

            // 交互区域
            MouseArea {
                anchors.fill: parent
                enabled: root.can > 0 && !root.choiceLocked && !root.isOver
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                onClicked: {
                    if (root.choiceLocked || root.isOver) return
                    makeChoice(modelData.id)
                }
            }
        }
    }

    // ============== 倒计时显示 ==============
    Text {
        id: countdownText
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 20
        text: ""
        font.pixelSize: 24
        font.bold: true
        color: "#FFD700"
        style: Text.Outline
        styleColor: "#000000"
        z: 10
    }

    // ============== 核心逻辑 ==============

    // 开始选择：锁定 + 显示高亮 + 延时后执行
    function makeChoice(optionId) {
        if (root.choiceLocked || root.isOver) return
        root.choiceLocked = true

        var qid = gameModel.currentQuestion ? gameModel.currentQuestion.id : ""
        selectedOptionIds[qid] = optionId

        choiceTimer.optionId = optionId
        choiceTimer.start()
    }

    // 延时后执行实际选择逻辑
    Timer {
        id: choiceTimer
        interval: 500   // 高亮显示时间（毫秒），可调整
        repeat: false
        running: false
        property string optionId: ""

        onTriggered: {
            executeChoice(optionId)
        }
    }

    // 执行选择逻辑
    function executeChoice(optionId) {
        var result = gameModel.handleChoice(optionId)

        if (!result) {
            root.choiceLocked = false
            return
        }

        if (result.finished) {
            // 游戏结束，发送最终结果
            root.isOver = true
            ClientInstance.replyToServer("", result.result)
            ClientInstance.notifyServer("PushRequest", "updatemini,gl_finish," + gameModel.serializeState())

            // 延迟关闭
            closeTimer.start()
        } else {
            // 广播状态给所有玩家
            ClientInstance.notifyServer("PushRequest", "updatemini,gl_choice," + gameModel.serializeState())

            // 解锁（下一题已切换）
            root.choiceLocked = false
        }
    }

    // 关闭窗口
    Timer {
        id: closeTimer
        interval: 1500
        repeat: false
        running: false
        onTriggered: {
            root.close()
        }
    }

    // ============== 对外接口 ==============

    // Lua 初始化调用
    function loadData(data) {
        root.can = data.can || 0
        root.isOver = false
        root.choiceLocked = false
        root.selectedOptionIds = ({})

        gameModel.startGame()
    }

    // 接收服务端推送的更新
    function updateData(data) {
        var str = String(data || "")
        var commaIdx = str.indexOf(",")
        if (commaIdx < 0) return
        var type = str.substring(0, commaIdx)
        var content = str.substring(commaIdx + 1)

        if (type === "gl_choice") {
            // 同步状态（旁观者更新到当前选择的题目）
            if (root.can === 0) {
                gameModel.deserializeState(content)

                // 从序列化状态中恢复已选选项
                try {
                    var state = JSON.parse(content)
                    if (state.qid && state.opt) {
                        selectedOptionIds[state.qid] = state.opt
                    }
                } catch (e) {}
            }
        }
        else if (type === "gl_finish") {
            // 游戏结束
            root.isOver = true
            if (root.can === 0) {
                // 旁观者同步最终状态
                gameModel.deserializeState(content)

                // 关闭
                closeTimer.start()
            }
        }
    }

    Component.onCompleted: {
        // 让全屏弹窗对齐父容器左上角，避免被 showPopup 的居中逻辑截断
        x = 0
        y = 0
    }
}

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

    width: Screen.width
    height: Screen.height

    title.text: "陌上桑 · 请选择正确的一句"
    signal returnToCenter()

    // 全屏背景
    Image {
        anchors.fill: parent
        source: "./moshangsang.jpg"
        fillMode: Image.PreserveAspectCrop
        z: 0
    }

    // 中央答题框
    Rectangle {
        id: gamePanel
        width: 600
        height: 520   // 高度增加以适应第二阶段图标的显示
        anchors.centerIn: parent
        color: "#00000088"
        radius: 12
        border.color: "#ecf0f1"
        border.width: 2
        z: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // 标题
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "《陌上桑》<br>请选出正确的下半句"
                font.pixelSize: 32
                font.bold: true
                color: "#8300FF"
                style: Text.Outline
                styleColor: "#000000"
                horizontalAlignment: Text.AlignHCenter
            }

            // 题目上半句
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: "#2c3e50"
                radius: 10
                border.color: "#ecf0f1"
                border.width: 2

                Text {
                    id: questionText
                    anchors.centerIn: parent
                    text: ""
                    font.pixelSize: 24
                    font.bold: true
                    color: "#f1c40f"
                    style: Text.Outline
                    styleColor: "#000000"
                }
            }

            // 自定义选项列表
            Column {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 12

                Repeater {
    id: optionRepeater
    model: []
    delegate: Rectangle {
        width: parent.width
        height: 60
        color: {
            if (resultPhase) {
                if (modelData === correctAnswer) return "#2ecc71"
                if (modelData === userChoice && modelData !== correctAnswer) return "#e74c3c"
            }
            return (mouseArea.pressed ? "#3498db" : "#2980b9")
        }
        radius: 8
        border.color: "#ecf0f1"
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 15
            anchors.rightMargin: 15
            spacing: 10

            Text {
                Layout.fillWidth: true
                text: modelData
                color: "white"
                font.pixelSize: 18
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
            }

            Text {
                id: iconText
                text: {
                    if (!resultPhase) return ""
                    if (modelData === correctAnswer) return "✓"
                    if (modelData === userChoice && modelData !== correctAnswer) return "✗"
                    return ""
                }
                color: {
                    if (modelData === correctAnswer) return "#00ff00"
                    if (modelData === userChoice && modelData !== correctAnswer) return "#ff0000"
                    return "transparent"
                }
                font.pixelSize: 28
                font.bold: true
                Layout.preferredWidth: 40
                horizontalAlignment: Text.AlignHCenter
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            enabled: !resultPhase && !answered
            onClicked: {
                if (resultPhase || answered) return
                submitAnswer(modelData)
            }
        }
    }
}
            }

            // 倒计时显示
            Text {
                id: countdownText
                Layout.alignment: Qt.AlignHCenter
                text: "剩余时间：" + remainingTime + " 秒"
                font.pixelSize: 16
                font.bold: true
                color: "#8300FF"
                visible: !resultPhase
            }
        }
    }

    // 模型
    MoshangsangModel {
        id: model
    }

    // 状态变量
    property int remainingTime: 5
    property bool answered: false       // 是否已经提交答案（防止重复点击）
    property bool resultPhase: false    // 是否处于展示结果阶段
    property string userChoice: ""      // 用户选择的选项文本（仅用于标错）
    property string correctAnswer: ""   // 正确答案文本

    // 答题倒计时（第一阶段）
    Timer {
        id: answerTimer
        interval: 1000
        repeat: true
        running: false
        onTriggered: {
            if (remainingTime > 0) {
                remainingTime--
            }
            if (remainingTime <= 0 && !answered && !resultPhase) {
                // 超时未选，直接进入结果展示阶段（不提交任何选项）
                answerTimer.stop()
                showResult(null)
            }
        }
    }

    // 结果展示计时器（第二阶段）
    Timer {
        id: resultTimer
        interval: 1500
        repeat: false
        running: false
        onTriggered: {
            // 关闭窗口，Lua 会收到结果（已经提前发送）
            root.close()
        }
    }

    // 提交答案（由用户点击触发）
    function submitAnswer(selected) {
        if (answered || resultPhase) return
        answered = true
        answerTimer.stop()
        userChoice = selected
        showResult(selected)
    }

    // 展示结果（正确/错误标记）
    function showResult(chosen) {
        resultPhase = true
        // 获取正确答案（从模型中）
        correctAnswer = model.currentCorrectSecond

        // 发送结果给 Lua（根据是否选对）
        var isCorrect = (chosen === correctAnswer)
        var resultStr = isCorrect ? "true" : "false"
        ClientInstance.replyToServer("", resultStr)
        ClientInstance.notifyServer("PushRequest", "updatemini,finish,")

        // 启动结果计时器，1.5秒后关闭
        resultTimer.start()
    }

    // 开始游戏（初始化）
    function startGame() {
        model.generateNewQuiz()
        questionText.text = model.currentFirstLine
        correctAnswer = model.currentCorrectSecond

        // 刷新选项列表
        optionRepeater.model = model.currentOptions

        // 重置状态
        remainingTime = 5
        answered = false
        resultPhase = false
        userChoice = ""

        answerTimer.start()
    }

    // Lua 调用的入口
    function loadData(data) {
        startGame()
    }

    Component.onCompleted: {
        startGame()
    }
}
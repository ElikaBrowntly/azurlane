// SPDX-License-Identifier: GPL-3.0-or-later
// 名称用 Yyfy0721Model 而非 0721Model：QML 类型名不能以数字开头，
// 模型文件要作为 imported 类型引用，必须以字母开头。
import QtQuick 2.12

// 纯逻辑模型（与其余 hidden-clouds 模型一致，不放置 Timer 等子对象）
QtObject {
    id: root

    // 输入数据：背景图片路径（由 lua 通过 component.model.prop 注入）
    property string imagePath: ""

    // 游戏状态
    property int clickCount: 0
    property int targetCount: 21
    property int timeLeft: 3
    property int readyCountdown: 3
    property bool readyPhase: true
    property bool gameFinished: false

    // 框架要求的输出与信号
    property var result: null
    signal accepted()
    signal rejected()
    // 视图可监听此信号，在游戏结束后做展示延迟关闭
    signal finished()

    // 开始游戏：重置状态（计时器由视图持有并启动）
    function start() {
        clickCount = 0
        timeLeft = 3
        readyCountdown = 3
        readyPhase = true
        gameFinished = false
    }

    // 点击按钮：记录得分并判定是否达成满分
    function registerClick() {
        if (gameFinished || readyPhase) return
        clickCount++
        if (clickCount >= targetCount) finishGame()
    }

    // 准备阶段每秒一响（由视图 readyTimer 调用）
    // 返回 false 表示准备结束，视图应切换到游戏计时器
    function tickReady() {
        readyCountdown--
        if (readyCountdown <= 0) {
            readyPhase = false
            return false
        }
        return true
    }

    // 游戏阶段每秒一响（由视图 gameTimer 调用）
    // 返回 false 表示游戏结束，视图应停止计时器
    function tickGame() {
        timeLeft--
        if (timeLeft <= 0) {
            finishGame()
            return false
        }
        return true
    }

    // 结束游戏（超时或已达满分）
    function finishGame() {
        if (gameFinished) return
        gameFinished = true
        // 将得分作为对话框返回值提交给 lua
        result = { count: clickCount }
        finished()
        accepted()
    }
}
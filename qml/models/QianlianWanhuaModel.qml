// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick

QtObject {
    id: model

    // ============== 问题树定义 ==============
    // 每个问题：
    //   id       - 唯一标识
    //   bg       - 背景图片路径
    //   options  - 选项数组
    //     id       - 选项标识
    //     area     - 点击区域 { x, y, w, h }（相对坐标 0-1，基于背景图尺寸对齐）
    //     visible  - 初始可见，调参对齐后设为 false
    //     nextId   - 下一题 id，null 表示最终选择
    property var questionTree: [
        {
            id: "q1",
            bg: "../image/icon/gonglue_q1.jpg",
            options: [
                { id: "q1_diaoyu",     area: { x: 0.25, y: 0.17,  w: 0.5, h: 0.08 }, visible: true, nextId: "q5" },
                { id: "q1_caiyecai",   area: { x: 0.25, y: 0.31, w: 0.5, h: 0.08 }, visible: true, nextId: "q2" },
                { id: "q1_danxing",    area: { x: 0.25, y: 0.45,  w: 0.5, h: 0.08 }, visible: true, nextId: "q2" },
            ]
        },
        // ----- Q1 选钓鱼后进入的路线分歧 -----
        {
            id: "q5",
            bg: "../image/icon/gonglue_q5.jpg",
            options: [
                { id: "q5_buxing",     area: { x: 0.25, y: 0.24,  w: 0.5, h: 0.08 }, visible: true, nextId: "q2" },
                { id: "q5_zheyang",    area: { x: 0.25, y: 0.38, w: 0.5, h: 0.08 }, visible: true, nextId: "q2" },
            ]
        },
        // ----- 共通 Q2 -----
        {
            id: "q2",
            bg: "../image/icon/gonglue_q2.jpg",
            options: [
                { id: "q2_koutou",     area: { x: 0.25, y: 0.24,  w: 0.5, h: 0.08 }, visible: true, nextId: "q3" },
                { id: "q2_momo",       area: { x: 0.25, y: 0.38, w: 0.5, h: 0.08 }, visible: true, nextId: "q3" },
            ]
        },
        // ----- 共通 Q3 -----
        {
            id: "q3",
            bg: "../image/icon/gonglue_q3.jpg",
            options: [
                { id: "q3_danxin",     area: { x: 0.25, y: 0.24,  w: 0.5, h: 0.08 }, visible: true, nextId: "q4" },
                { id: "q3_xiangxin",   area: { x: 0.25, y: 0.38, w: 0.5, h: 0.08 }, visible: true, nextId: "q4" },
            ]
        },
        // ----- 共通 Q4 -----
        {
            id: "q4",
            bg: "../image/icon/gonglue_q4.jpg",
            options: [
                { id: "q4_fangxin",    area: { x: 0.25, y: 0.24,  w: 0.5, h: 0.08 }, visible: true, nextId: null },
                { id: "q4_bieshuo",    area: { x: 0.25, y: 0.38, w: 0.5, h: 0.08 }, visible: true, nextId: null },
            ]
        },
    ]

    // 当前路线
    property string routeBase: ""

    // Q2~Q4 的选择记录（用于最终判定）
    property string q2Choice: ""
    property string q3Choice: ""
    property string q4Choice: ""

    // 当前状态
    property var currentQuestion: null
    property int currentQuestionIndex: -1
    property var selectedOptionId: ""
    property bool isFinished: false
    property string finalResult: ""

    // 根据 id 查找问题
    function findQuestionById(qid) {
        for (var i = 0; i < questionTree.length; i++) {
            if (questionTree[i].id === qid) return questionTree[i]
        }
        return null
    }

    function findQuestionIndexById(qid) {
        for (var i = 0; i < questionTree.length; i++) {
            if (questionTree[i].id === qid) return i
        }
        return -1
    }

    // 开始游戏
    function startGame() {
        routeBase = ""
        q2Choice = ""
        q3Choice = ""
        q4Choice = ""
        selectedOptionId = ""
        isFinished = false
        finalResult = ""
        currentQuestionIndex = findQuestionIndexById("q1")
        currentQuestion = currentQuestionIndex >= 0 ? questionTree[currentQuestionIndex] : null
    }

    // 处理选择
    function handleChoice(optionId) {
        if (isFinished || !currentQuestion) return null

        var opt = null
        for (var i = 0; i < currentQuestion.options.length; i++) {
            if (currentQuestion.options[i].id === optionId) {
                opt = currentQuestion.options[i]
                break
            }
        }
        if (!opt) return null

        selectedOptionId = optionId

        // 记录路线
        if (currentQuestion.id === "q1") {
            if (optionId === "q1_caiyecai") routeBase = "mako"
            else if (optionId === "q1_danxing") routeBase = "murasame"
        } else if (currentQuestion.id === "q5") {
            if (optionId === "q5_buxing") routeBase = "yoshino"
            else if (optionId === "q5_zheyang") routeBase = "lena"
        }

        // 记录 Q2~Q4 的选择
        if (currentQuestion.id === "q2") {
            q2Choice = optionId
        } else if (currentQuestion.id === "q3") {
            q3Choice = optionId
        } else if (currentQuestion.id === "q4") {
            q4Choice = optionId
        }

        // Q2~Q4 当前题选错立即结束
        if (currentQuestion.id === "q2") {
            var q2Correct = false
            if ((routeBase === "yoshino" || routeBase === "lena" || routeBase === "mako") && optionId === "q2_koutou") q2Correct = true
            else if (routeBase === "murasame" && optionId === "q2_momo") q2Correct = true
            if (!q2Correct) return finishGame("false")
        } else if (currentQuestion.id === "q3") {
            if (optionId !== "q3_danxin") return finishGame("false")
        } else if (currentQuestion.id === "q4") {
            var q4Correct = false
            if (routeBase === "yoshino" && optionId === "q4_fangxin") q4Correct = true
            else if ((routeBase === "lena" || routeBase === "mako" || routeBase === "murasame") && optionId === "q4_bieshuo") q4Correct = true
            if (!q4Correct) return finishGame("false")
        }

        // Q4 是最终判定
        if (currentQuestion.id === "q4") {
            return finishGame()
        }

        // 进入下一题
        var nextIdx = findQuestionIndexById(opt.nextId)
        if (nextIdx >= 0) {
            currentQuestionIndex = nextIdx
            currentQuestion = questionTree[nextIdx]
            selectedOptionId = ""
            return { finished: false, nextQuestion: currentQuestion.id }
        }

        // 找不到下一题，视为失败
        return finishGame("false")
    }

    // 根据 Q2~Q4 的选择 pattern 判定最终结果
    function finishGame(forcedResult) {
        isFinished = true

        if (forcedResult !== undefined) {
            finalResult = forcedResult
            return { finished: true, result: finalResult }
        }

        var pattern = ""
        pattern += (q2Choice === "q2_koutou") ? "1" : (q2Choice === "q2_momo") ? "2" : "?"
        pattern += (q3Choice === "q3_danxin") ? "1" : (q3Choice === "q3_xiangxin") ? "2" : "?"
        pattern += (q4Choice === "q4_fangxin") ? "1" : (q4Choice === "q4_bieshuo") ? "2" : "?"

        if (routeBase === "yoshino" && pattern === "111") {
            finalResult = "yyfy_TomotakeYoshino"
        } else if (routeBase === "lena" && pattern === "112") {
            finalResult = "yyfy_Lena"
        } else if (routeBase === "mako" && pattern === "112") {
            finalResult = "yyfy_HitachiMako"
        } else if (routeBase === "murasame" && pattern === "212") {
            finalResult = "yyfy_Murasame"
        } else {
            finalResult = "false"
        }

        return { finished: true, result: finalResult }
    }

    // 获取当前问题的选项列表
    function getCurrentOptions() {
        if (!currentQuestion) return []
        return currentQuestion.options
    }

    // 获取当前背景图
    function getCurrentBg() {
        if (!currentQuestion) return ""
        return currentQuestion.bg
    }

    // 从外部设置状态（同步用）
    function setState(qid, optId, route, q2, q3, q4, finished, result) {
        currentQuestionIndex = findQuestionIndexById(qid)
        currentQuestion = currentQuestionIndex >= 0 ? questionTree[currentQuestionIndex] : null
        selectedOptionId = optId || ""
        routeBase = route || ""
        q2Choice = q2 || ""
        q3Choice = q3 || ""
        q4Choice = q4 || ""
        isFinished = finished || false
        finalResult = result || ""
    }

    // 序列化当前状态（用于同步）
    function serializeState() {
        return JSON.stringify({
            qid: currentQuestion ? currentQuestion.id : "",
            opt: selectedOptionId,
            route: routeBase,
            q2: q2Choice,
            q3: q3Choice,
            q4: q4Choice,
            finished: isFinished,
            result: finalResult
        })
    }

    // 反序列化状态
    function deserializeState(jsonStr) {
        try {
            var data = JSON.parse(jsonStr)
            setState(data.qid, data.opt, data.route, data.q2, data.q3, data.q4, data.finished, data.result)
            return true
        } catch (e) {
            return false
        }
    }
}

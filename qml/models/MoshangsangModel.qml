// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick

QtObject {
    id: root

    // 题库：每项包含上半句和正确的下半句
    property var questions: [
        { first: "日出东南隅", second: "照我秦氏楼" },
        { first: "秦氏有好女", second: "自名为罗敷" },
        { first: "罗敷喜蚕桑", second: "采桑城南隅" },
        { first: "青丝为笼系", second: "桂枝为笼钩" },
        { first: "头上倭堕髻", second: "耳中明月珠" },
        { first: "缃绮为下裙", second: "紫绮为上襦" },
        { first: "行者见罗敷", second: "下担捋髭须" },
        { first: "少年见罗敷", second: "脱帽著帩头" },
        { first: "耕者忘其犁", second: "锄者忘其锄" },
        { first: "来归相怨怒", second: "但坐观罗敷" },
        { first: "使君从南来", second: "五马立踟蹰" },
        { first: "使君遣吏往", second: "问是谁家姝" },
        { first: "罗敷年几何", second: "二十尚不足" },
        { first: "二十尚不足", second: "十五颇有余" },
        { first: "使君谢罗敷", second: "宁可共载不" },
        { first: "罗敷前置辞", second: "使君一何愚" },
        { first: "使君自有妇", second: "罗敷自有夫" },
        { first: "东方千余骑", second: "夫婿居上头" },
        { first: "何用识夫婿", second: "白马从骊驹" },
        { first: "青丝系马尾", second: "黄金络马头" },
        { first: "腰中鹿卢剑", second: "可值千万余" },
        { first: "十五府小吏", second: "二十朝大夫" },
        { first: "三十侍中郎", second: "四十专城居" },
        { first: "为人洁白晳", second: "鬑鬑颇有须" },
        { first: "盈盈公府步", second: "冉冉府中趋" },
        { first: "坐中数千人", second: "皆言夫婿殊" }
    ]

    // 当前挑战数据
    property string currentFirstLine: ""
    property string currentCorrectSecond: ""
    property var currentOptions: []   // 三个选项

    // 随机选择一道题并生成三个选项（含正确 + 两个随机不同错误项）
    function generateNewQuiz() {
        // 随机选一个题目
        var qIndex = Math.floor(Math.random() * questions.length)
        var selected = questions[qIndex]
        currentFirstLine = selected.first
        currentCorrectSecond = selected.second

        // 收集所有可能的下半句（用作错误选项池）
        var allSeconds = []
        for (var i = 0; i < questions.length; i++) {
            allSeconds.push(questions[i].second)
        }

        // 随机抽取两个不同于正确答案的错误选项
        var wrongOptions = []
        while (wrongOptions.length < 2) {
            var rand = Math.floor(Math.random() * allSeconds.length)
            var candidate = allSeconds[rand]
            if (candidate !== currentCorrectSecond && wrongOptions.indexOf(candidate) === -1) {
                wrongOptions.push(candidate)
            }
        }

        // 构建选项数组：正确 + 两个错误
        currentOptions = [currentCorrectSecond].concat(wrongOptions)
        // 随机打乱顺序
        for (var j = currentOptions.length - 1; j > 0; j--) {
            var r = Math.floor(Math.random() * (j + 1));
            [currentOptions[j], currentOptions[r]] = [currentOptions[r], currentOptions[j]]
        }
        return true
    }

    // 验证用户选择的答案是否正确
    function checkAnswer(selectedText) {
        return selectedText === currentCorrectSecond
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick 2.12
import Fk
import LunarLtk

QtObject {
    id: root

    // 输入属性（由 Lua 通过 prop 传入）
    property var generals: []          // 武将内部名列表
    property bool freeAssign: true     // 是否允许自由选将
    property string prompt: "选择武将"

    // 状态
    property string searchKeyword: ""
    property string selectedGeneral: ""
    property var filteredGenerals: []   // 自由选将模式下的过滤结果
    property var limitedGenerals: []    // 随机模式下的列表（最多16个）

    // 框架要求的输出
    property var result: selectedGeneral
    signal accepted()
    signal rejected()

    // 便捷属性
    readonly property bool canConfirm: selectedGeneral !== ""

    // 初始化/更新列表
    function updateLists() {
        if (freeAssign) {
            filterGenerals()
        } else {
            randomizeLimitedGenerals()
        }
    }

    // 自由选将：根据搜索关键词过滤
    function filterGenerals() {
        if (!freeAssign) return
        let keyword = searchKeyword.trim().toLowerCase()
        if (keyword === "") {
            filteredGenerals = generals.slice()
        } else {
            let result = []
            for (let i = 0; i < generals.length; i++) {
                let name = generals[i]
                let translated = Lua.tr(name).toLowerCase()
                if (translated.indexOf(keyword) !== -1) {
                    result.push(name)
                }
            }
            filteredGenerals = result
        }
    }

    // 随机模式：随机抽取最多16个武将（Fisher-Yates 洗牌）
    function randomizeLimitedGenerals() {
        let list = generals.slice()
        if (list.length > 16) {
            // 洗牌
            for (let i = list.length - 1; i > 0; i--) {
                const j = Math.floor(Math.random() * (i + 1))
                ;[list[i], list[j]] = [list[j], list[i]]
            }
            limitedGenerals = list.slice(0, 16)
        } else {
            limitedGenerals = list
        }
        // 清除已选中但不在新列表中的武将
        if (selectedGeneral && !limitedGenerals.includes(selectedGeneral)) {
            selectedGeneral = ""
        }
    }

    // 选择武将
    function selectGeneral(name) {
        if (selectedGeneral === name) {
            selectedGeneral = ""
        } else {
            selectedGeneral = name
        }
        result = selectedGeneral
    }

    // 确认
    function doAccept() {
        result = selectedGeneral
        accepted()
    }

    // 取消
    function doReject() {
        rejected()
    }

    // 监听输入变化
    onGeneralsChanged: updateLists()
    onFreeAssignChanged: updateLists()
    onSearchKeywordChanged: filterGenerals()
}
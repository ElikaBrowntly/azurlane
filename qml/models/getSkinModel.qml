// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick 2.12
import Fk
import LunarLtk

QtObject {
    id: root

    // 输入数据：武将名列表，如 ["caocao"] 或 ["caocao", "simayi"]
    property var generals: []

    // 框架要求的输出和信号
    property var result: null
    signal accepted()
    signal rejected()

    // 辅助函数：从路径中提取皮肤名
    function pathToSkinName(path) {
        if (!path) return generals.length > 0 ? generals[0] : ""
        var normalizedPath = path.replace(/\\/g, "/")
        var pathParts = normalizedPath.split("/")
        var fileName = pathParts[pathParts.length - 1]
        var fileParts = fileName.split(".")
        return fileParts[0]
    }

    // 处理皮肤逻辑
    function process() {
        if (generals.length === 0) {
            result = ""
            accepted()
            return
        }

        var mainGeneral = generals[0]
        var deputyGeneral = generals.length > 1 ? generals[1] : ""

        // 获取已启用的皮肤配置
        var enabledSkins = Config.enabledSkins || {}

        // 处理主将皮肤
        var mainSkin = enabledSkins[mainGeneral]
        if (mainSkin !== undefined && mainSkin !== "") {
            mainGeneral = mainSkin
        }
        var mainResult = mainGeneral
        if (mainResult && (mainResult.indexOf("/") !== -1 || mainResult.indexOf("\\") !== -1)) {
            mainResult = pathToSkinName(mainResult)
        }

        // 处理副将皮肤
        var deputyResult = ""
        if (deputyGeneral !== "") {
            var deputySkin = enabledSkins[deputyGeneral]
            if (deputySkin !== undefined && deputySkin !== "") {
                deputyGeneral = deputySkin
            }
            if (deputyGeneral && (deputyGeneral.indexOf("/") !== -1 || deputyGeneral.indexOf("\\") !== -1)) {
                deputyResult = pathToSkinName(deputyGeneral)
            } else {
                deputyResult = deputyGeneral
            }
        }

        // 设置返回结果
        if (deputyResult === "") {
            result = mainResult
        } else {
            result = [mainResult, deputyResult]
        }

        accepted()
    }
}
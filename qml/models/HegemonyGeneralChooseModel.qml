// packages/hidden-clouds/qml/models/HegemonyGeneralChooseModel.qml
import QtQuick 2.12
import Fk
import LunarLtk

QtObject {
    id: root

    property var generals: []
    property string prompt: ""

    property string selectedMain: ""
    property string selectedDeputy: ""

    property var result: [selectedMain, selectedDeputy]
    signal accepted()
    signal rejected()

    readonly property bool canConfirm: selectedMain !== "" && selectedDeputy !== ""

    property var _generalMap: ({})

    onGeneralsChanged: {
        var map = {};
        for (var i = 0; i < generals.length; i++) {
            var g = generals[i];
            map[g.name] = g;
        }
        _generalMap = map;
    }

    function getGeneralInfo(name) {
        return _generalMap[name] || null;
    }

    function getKingdom(name) {
        var info = getGeneralInfo(name);
        return info ? info.kingdom : "";
    }

    function getSubKingdom(name) {
        var info = getGeneralInfo(name);
        return info ? (info.subkingdom || "") : "";
    }

    function canPair(main, deputy) {
        if (main === "" || deputy === "") return false;
        var mk = getKingdom(main);
        var msk = getSubKingdom(main);
        var dk = getKingdom(deputy);
        var dsk = getSubKingdom(deputy);
        if (mk === "god" || mk === "evil" || dk === "god" || dk === "evil") return true;
        if (mk === dk && mk !== "wild") return true;
        if (msk && msk === dk) return true;
        if (dsk && dsk === mk) return true;
        if (msk && dsk && msk === dsk) return true;
        return false;
    }

    function isDeputyValid(deputyName) {
        if (selectedMain === "") return false;
        if (deputyName === selectedMain) return false;
        return canPair(selectedMain, deputyName);
    }

    // 核心：判断某个武将当前是否可以被选择（可点击）
    function canSelectGeneral(name) {
        // 未选主将：所有武将都可选
        if (selectedMain === "" && selectedDeputy === "")
            return true;
        // 已选主将，未选副将：主将本身可选（用于重新选择），其他武将需满足副将合法性
        if (selectedMain !== "" && selectedDeputy === "") {
            if (name === selectedMain)
                return true;
            else
                return isDeputyValid(name);
        }
        // 主副将均已选：只有主将或副将本身可以再次点击（用于重新选择）
        if (name === selectedMain || name === selectedDeputy)
            return true;
        return false;
    }

    // 选择逻辑
    function selectGeneral(name) {
        if (selectedMain === "") {
            // 无主将：选为主将
            selectedMain = name;
            selectedDeputy = "";
        } else if (selectedDeputy === "") {
            // 已有主将，无副将
            if (name === selectedMain) {
                // 重复点击主将：清空全部选择
                clearSelection();
            } else {
                selectedDeputy = name;
            }
        } else {
            // 已有主副将：若点击主将则重置全部，若点击副将则清空副将
            if (name === selectedMain) {
                clearSelection();
            } else if (name === selectedDeputy) {
                selectedDeputy = "";
            }
        }
        result = [selectedMain, selectedDeputy];
    }

    function clearSelection() {
        selectedMain = "";
        selectedDeputy = "";
        result = [selectedMain, selectedDeputy];
    }

    function doAccept() {
        result = [selectedMain, selectedDeputy];
        accepted();
    }

    function doReject() {
        rejected();
    }
}
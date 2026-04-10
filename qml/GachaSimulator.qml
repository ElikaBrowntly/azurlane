import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import Fk
import Fk.Components.LunarLTK
import Fk.Widgets as W

W.PageBase {
    id: root
    visible: true

    property string basePath: "../image/icon/"
    property int currentPage: 0
    property int quartzNum: 0
    property string lastHandDate: ""
    property bool todaySigned: false
    property int signConstant: 0

    // 抽卡配置（与之前完全相同）
    property var categories: [
        { prob: 0.8, getPath: function() { return basePath + "up/servant5.jpg"; } },
        { prob: 0.2, getPath: function() { return basePath + "servant5/" + randomInt(1, 35) + ".jpg"; } },
        { prob: 2.1, getPath: function() { return basePath + "up/servant4.jpg"; } },
        { prob: 0.9, getPath: function() { return basePath + "servant4/" + randomInt(1, 56) + ".jpg"; } },
        { prob: 40,  getPath: function() { return basePath + "servant3/" + randomInt(1, 39) + ".jpg"; } },
        { prob: 2.8, getPath: function() { return basePath + "up/clothes5.jpg"; } },
        { prob: 1.2, getPath: function() { return basePath + "clothes5/" + randomInt(1, 43) + ".jpg"; } },
        { prob: 12,  getPath: function() { return basePath + "clothes4/" + randomInt(1, 50) + ".jpg"; } },
        { prob: 40,  getPath: function() { return basePath + "clothes3/" + randomInt(1, 59) + ".jpg"; } }
    ]

    function randomInt(min, max) { return Math.floor(Math.random() * (max - min + 1)) + min; }

    function drawOne() {
        var r = Math.random() * 100;
        var cumulative = 0;
        for (var i = 0; i < categories.length; i++) {
            cumulative += categories[i].prob;
            if (r < cumulative) return categories[i].getPath();
        }
        return basePath + "up/servant5.jpg";
    }

    function drawMultiple(count) {
        var result = [];
        for (var i = 0; i < count; i++) result.push(drawOne());
        return result;
    }

    // 请求圣晶石数据
    function requestSaintQuartz() {
        App.setBusy(true);
        Cpp.notifyServer("LobbyTask", ["get_player_SaintQuartz", []]);
    }

    // 切换页面
    function setPage(page) {
        currentPage = page;
        if (page === 1) requestSaintQuartz();
    }

    // 全局抽卡结果显示函数（操作抽卡页面内的组件）
    function showGachaResult(icons) {
        if (!gachaPage) return;
        if (icons.length === 1) {
            gachaPage.singleResultImage.source = icons[0];
            gachaPage.singleResultImage.visible = true;
            gachaPage.resultGrid.visible = false;
        } else {
            gachaPage.resultGrid.model = icons;
            gachaPage.resultGrid.visible = true;
            gachaPage.singleResultImage.visible = false;
        }
        gachaPage.resultPopup.visible = true;
    }

    // 背景
    Rectangle { anchors.fill: parent; color: "#87CEEB"; z: -2 }

    // 抽卡背景图片
    Image {
        width: parent.width; anchors.top: parent.top
        source: basePath + "gacha_bg.jpg"
        fillMode: Image.PreserveAspectFit
        z: -1; visible: currentPage === 0
    }

    // 底部菜单
    Rectangle {
        id: menuArea
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height * 0.22
        color: "#87CEEB"
        z: 10

        Rectangle {
            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
            height: parent.height * 0.4; color: "transparent"
            Text {
                anchors.centerIn: parent
                text: currentPage === 0 ? "抽卡模拟器\n（请将此窗口最大化）" : "圣晶石\n（您的财富）"
                font.pixelSize: 20; color: "white"; font.bold: true
                style: Text.Outline; styleColor: "black"
                horizontalAlignment: Text.AlignHCenter; width: parent.width * 0.9; wrapMode: Text.WordWrap
            }
        }

        Row {
            anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
            height: parent.height * 0.6; spacing: 2
            Rectangle {
                width: parent.width / 2 - 1; height: parent.height
                color: currentPage === 0 ? "#4CAF50" : "#3A6EA5"; radius: 8
                border.color: "white"; border.width: 1
                Text { anchors.centerIn: parent; text: "抽卡模拟器"; font.pixelSize: 18; color: "white"; font.bold: true }
                MouseArea { anchors.fill: parent; onClicked: setPage(0) }
            }
            Rectangle {
                width: parent.width / 2 - 1; height: parent.height
                color: currentPage === 1 ? "#4CAF50" : "#3A6EA5"; radius: 8
                border.color: "white"; border.width: 1
                Text { anchors.centerIn: parent; text: "圣晶石"; font.pixelSize: 18; color: "white"; font.bold: true }
                MouseArea { anchors.fill: parent; onClicked: setPage(1) }
            }
        }
    }

    // 抽卡页面（内部组件通过 property alias 暴露）
    Item {
        id: gachaPage
        anchors.top: parent.top; anchors.bottom: menuArea.top
        anchors.left: parent.left; anchors.right: parent.right
        visible: currentPage === 0

        // 暴露弹窗组件给根函数使用
        property alias resultPopup: resultPopup
        property alias singleResultImage: singleResultImage
        property alias resultGrid: resultGrid

        // 热区（调用根函数）
        MouseArea {
            x: parent.width * (363 / 1450); y: parent.height * (475 / 720)
            width: parent.width * (207 / 1450); height: parent.height * (85 / 720)
            onClicked: { var icon = drawOne(); root.showGachaResult([icon]); }
            Rectangle { anchors.fill: parent; color: "red"; opacity: 0.3; visible: true }
        }
        MouseArea {
            x: parent.width * (603 / 1450); y: parent.height * (475 / 720)
            width: parent.width * (207 / 1450); height: parent.height * (85 / 720)
            onClicked: { var icon = drawOne(); root.showGachaResult([icon]); }
            Rectangle { anchors.fill: parent; color: "red"; opacity: 0.3; visible: true }
        }
        MouseArea {
            x: parent.width * (842 / 1450); y: parent.height * (475 / 720)
            width: parent.width * (207 / 1450); height: parent.height * (85 / 720)
            onClicked: { var icons = drawMultiple(10); root.showGachaResult(icons); }
            Rectangle { anchors.fill: parent; color: "red"; opacity: 0.3; visible: true }
        }

        // 抽卡结果弹窗
        Rectangle {
            id: resultPopup
            anchors.centerIn: parent
            width: parent.width * 0.8; height: parent.height * 0.7
            color: "#CC000000"; radius: 10; visible: false; z: 10

            Image {
                id: singleResultImage
                anchors.centerIn: parent
                width: parent.width * 0.4; height: parent.height * 0.4
                fillMode: Image.PreserveAspectFit; visible: false
            }

            GridView {
                id: resultGrid
                anchors.fill: parent;// anchors.margins: 5
                cellWidth: (parent.width - 50) / 5; cellHeight: cellWidth
                model: []; visible: false
                delegate: Item {
                    width: resultGrid.cellWidth; height: resultGrid.cellHeight
                    Image {
                        anchors.centerIn: parent
                        width: parent.width * 0.8; height: parent.height * 0.6
                        source: modelData; fillMode: Image.PreserveAspectFit
                    }
                }
            }

            Button {
                id: confirmButton
                anchors.bottom: parent.bottom;
                anchors.horizontalCenter: parent.horizontalCenter
                width: 100; height: 40; text: "确认"
                onClicked: {
                    resultPopup.visible = false;
                    singleResultImage.source = "";
                    resultGrid.model = [];
                }
            }
        }
    }

    // 圣晶石页面
    Item {
        id: saintQuartzPage
        anchors.top: parent.top; anchors.bottom: menuArea.top
        anchors.left: parent.left; anchors.right: parent.right
        visible: currentPage === 1

        Rectangle { anchors.fill: parent; color: "#AA87CEEB"; radius: 10 }

        Column {
            anchors.centerIn: parent; spacing: 20; width: parent.width * 0.8
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "圣晶石"; font.pixelSize: 32; color: "#FFD700"; font.bold: true; style: Text.Outline; styleColor: "black" }
            Rectangle { width: parent.width; height: 2; color: "white"; opacity: 0.5 }
            Row { spacing: 20; anchors.horizontalCenter: parent.horizontalCenter
                Text { text: "当前数量："; font.pixelSize: 20; color: "white"; font.bold: true }
                Text { text: quartzNum.toString(); font.pixelSize: 20; color: "#3A6EA5"; font.bold: true }
            }
            Row { spacing: 20; anchors.horizontalCenter: parent.horizontalCenter
                Text { text: "连续签到："; font.pixelSize: 18; color: "white"; font.bold: true }
                Text { text: signConstant + " 天"; font.pixelSize: 18; color: "#3A6EA5"; font.bold: true }
            }
            Row { spacing: 20; anchors.horizontalCenter: parent.horizontalCenter
                Text { text: "今日签到："; font.pixelSize: 18; color: "white"; font.bold: true }
                Text { text: todaySigned ? "已完成" : "未签到"; font.pixelSize: 18; color: todaySigned ? "#4CAF50" : "#FF9800"; font.bold: true }
            }
            Row { spacing: 20; anchors.horizontalCenter: parent.horizontalCenter
                Text { text: "上次看不见的手："; font.pixelSize: 16; color: "white"; font.bold: true }
                Text { text: lastHandDate || "暂无"; font.pixelSize: 16; color: "#3A6EA5"; font.bold: true }
            }
            Button { anchors.horizontalCenter: parent.horizontalCenter; text: "刷新"; onClicked: requestSaintQuartz() }
        }
    }

    // 返回热区
    MouseArea {
        x: 0; y: 0
        width: parent.width * (204 / 1450); height: parent.height * (78 / 720)
        z: 100
        onClicked: { App.quitPage(); }
        Rectangle { anchors.fill: parent; color: "red"; opacity: 0.3; visible: false }
    }

    Component.onCompleted: {
        addCallback("get_player_SaintQuartz_callback", function(sender, data) {
            if (typeof data === "string") {
                try {
                    var obj = JSON.parse(data);
                    quartzNum = obj.quartz_num || 0;
                    lastHandDate = obj.kanbujiandeshou || "";
                    todaySigned = obj.sign_in || false;
                    signConstant = obj.sign_constant || 0;
                } catch(e) {}
            }
            App.setBusy(false);
        });
        requestSaintQuartz();
    }

    function loadData(data) {
        if (data && data.basePath) basePath = data.basePath;
    }
}
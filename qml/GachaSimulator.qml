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
    property int signTotal: 0          // 累计签到次数
    property string signDate: ""       // 上次签到日期

    // 抽卡配置（不变）
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

    // 签到请求
    function signIn() {
        if (todaySigned) {
            App.showToast("今日已经签到过了！");
            return;
        }
        App.setBusy(true);
        Cpp.notifyServer("LobbyTask", ["sign_in_SaintQuartz", []]);
    }

    // 切换页面
    function setPage(page) {
        currentPage = page;
        if (page === 1) requestSaintQuartz();
    }

    // 全局抽卡结果显示函数
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
                Text { anchors.centerIn: parent; text: "圣晶石系统"; font.pixelSize: 18; color: "white"; font.bold: true }
                MouseArea { anchors.fill: parent; onClicked: setPage(1) }
            }
        }
    }

    // 抽卡页面（不变）
    Item {
        id: gachaPage
        anchors.top: parent.top; anchors.bottom: menuArea.top
        anchors.left: parent.left; anchors.right: parent.right
        visible: currentPage === 0

        property alias resultPopup: resultPopup
        property alias singleResultImage: singleResultImage
        property alias resultGrid: resultGrid

        MouseArea {
            x: parent.width * (363 / 1450); y: parent.height * (475 / 720)
            width: parent.width * (207 / 1450); height: parent.height * (85 / 720)
            onClicked: { var icon = drawOne(); root.showGachaResult([icon]); }
            Rectangle { anchors.fill: parent; color: "red"; opacity: 0.3; visible: false }
        }
        MouseArea {
            x: parent.width * (603 / 1450); y: parent.height * (475 / 720)
            width: parent.width * (207 / 1450); height: parent.height * (85 / 720)
            onClicked: { var icon = drawOne(); root.showGachaResult([icon]); }
            Rectangle { anchors.fill: parent; color: "red"; opacity: 0.3; visible: false }
        }
        MouseArea {
            x: parent.width * (842 / 1450); y: parent.height * (475 / 720)
            width: parent.width * (207 / 1450); height: parent.height * (85 / 720)
            onClicked: { var icons = drawMultiple(10); root.showGachaResult(icons); }
            Rectangle { anchors.fill: parent; color: "red"; opacity: 0.3; visible: false }
        }

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
                anchors.fill: parent;
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

    // 圣晶石页面（增加签到按钮和累计签到显示）
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
                Text { text: "累计签到："; font.pixelSize: 18; color: "white"; font.bold: true }
                Text { text: signTotal + " 次"; font.pixelSize: 18; color: "#3A6EA5"; font.bold: true }
            }
            Row { spacing: 20; anchors.horizontalCenter: parent.horizontalCenter
                Text { text: "今日签到："; font.pixelSize: 18; color: "white"; font.bold: true }
                Text { text: todaySigned ? "已完成" : "未签到"; font.pixelSize: 18; color: todaySigned ? "#4CAF50" : "#FF9800"; font.bold: true }
            }
            Row { spacing: 20; anchors.horizontalCenter: parent.horizontalCenter
                Text { text: "上次看不见的手："; font.pixelSize: 16; color: "white"; font.bold: true }
                Text { text: lastHandDate || "暂无"; font.pixelSize: 16; color: "#3A6EA5"; font.bold: true }
            }

            // 按钮行：刷新 + 签到（并排）
            Column {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                Button {
                    text: "签到"
                    width: 100
                    height: 40
                    background: Rectangle {
                        color: "#FF9800"
                        radius: 4
                        border.color: "#E67E22"
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: signIn()
                }
                Button {
                    text: "刷新"
                    width: 100
                    height: 40
                    onClicked: requestSaintQuartz()
                }
            }
        }
    }

    // 关闭按钮（左上角）
    Image {
        id: closeButton
        anchors.left: parent.left
        anchors.top: parent.top
        width: 80
        height: 80
        source: root.basePath + "close.png"
        fillMode: Image.PreserveAspectFit
        z: 200
        MouseArea {
            anchors.fill: parent
            onClicked: App.quitPage()
        }
    }

    Component.onCompleted: {
        // 获取圣晶石数据回调
        addCallback("get_player_SaintQuartz_callback", function(sender, data) {
            if (typeof data === "string") {
                try {
                    var obj = JSON.parse(data);
                    quartzNum = obj.quartz_num || 0;
                    lastHandDate = obj.kanbujiandeshou || "";
                    todaySigned = obj.sign_in || false;
                    signConstant = obj.sign_constant || 0;
                    signTotal = obj.sign_total || 0;
                    signDate = obj.sign_date || "";
                } catch(e) {}
            }
            App.setBusy(false);
        });

        // 签到回调
        addCallback("sign_in_SaintQuartz_callback", function(sender, data) {
            if (typeof data === "string") {
                try {
                    var obj = JSON.parse(data);
                    if (obj.success) {
                        // 更新界面
                        quartzNum = obj.quartz_num;
                        signConstant = obj.sign_constant;
                        signTotal = obj.sign_total;
                        todaySigned = obj.sign_in;
                        signDate = obj.sign_date;
                        // 显示奖励信息
                        var msg = "签到成功！获得 " + obj.reward + " 圣晶石。";
                        if (obj.bonus && obj.bonus > 0) msg += "\n累计签到50天：额外获得 " + obj.bonus + " 圣晶石！";
                        App.showToast(msg);
                    } else {
                        App.showToast(obj.message || "签到失败");
                    }
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
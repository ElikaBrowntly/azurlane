import QtQuick 2.12
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Fk
import Fk.Pages.LunarLtk
import Fk.Components.LunarLtk
import Fk.Components.Common
import Fk.Widgets as W
import LunarLtk
import LunarLtk.Components
import LunarLtk.Pages.Popups

W.PageBase {
    id: root
    visible: true

    property string basePath: "../image/icon/"
    property int currentPage: 0
    property var quartzNum: 0
    property var goldNum: 0
    property string lastHandDate: ""
    property bool todaySigned: false
    property int signConstant: 0
    property int signTotal: 0
    property string signDate: ""

    // 抽卡配置
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

    // 概念礼装数据
    property var clothesList: []

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

    function requestSaintQuartz() {
        App.setBusy(true);
        Cpp.notifyServer("LobbyTask", ["get_player_SaintQuartz", []]);
    }

    function signIn() {
        if (todaySigned) {
            App.showToast("今日已经签到过了！");
            return;
        }
        App.setBusy(true);
        Cpp.notifyServer("LobbyTask", ["sign_in_SaintQuartz", []]);
    }

    function requestClothes() {
        App.setBusy(true);
        Cpp.notifyServer("LobbyTask", ["get_concept_clothes", []]);
    }

    function exchangeClothes(clothName, currentCount, pricePerOne) {
        var maxBuy = 5 - currentCount;
        if (maxBuy <= 0) {
            App.showToast("已满5星，无法再交换");
            return;
        }

        var currentValue = 1;

        var dialog = Qt.createQmlObject(`
        import QtQuick 2.15
        import QtQuick.Controls 2.15
        import QtQuick.Layouts 1.15

        Dialog {
            modal: true
            title: "交换礼装"
            width: 320
            height: 240
            standardButtons: Dialog.Ok | Dialog.Cancel

            contentItem: ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Text { text: "交换数量："; font.pixelSize: 16 }

                SpinBox {
                    Layout.fillWidth: true
                    from: 1
                    to: ${maxBuy}
                    value: 1
                    onValueChanged: console.log(value)
                }

                Text {
                    id: costLabel
                    font.pixelSize: 16
                    color: "#ff9800"
                    text: "消耗圣晶石：" + (1 * ${pricePerOne})
                }
            }
        }`, root);

        var spinBox = dialog.contentItem.children[1];
        spinBox.onValueChanged.connect(function() {
            currentValue = spinBox.value;
            var cost = spinBox.value * pricePerOne;
            dialog.contentItem.children[2].text = "消耗圣晶石：" + cost;
        });

        dialog.accepted.connect(function() {
            var totalCost = currentValue * pricePerOne;
            App.setBusy(true);
            Cpp.notifyServer("LobbyTask", ["exchange_concept_clothes", [clothName, currentValue, totalCost]]);
            dialog.destroy();
        });

        dialog.rejected.connect(function() { dialog.destroy(); });
        dialog.open();
    }

    function setPage(page) {
        currentPage = page;
        if (page === 1) requestSaintQuartz();
        else if (page === 2 && clothesList.length === 0) requestClothes();
    }

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

    // 背景色
    Rectangle { anchors.fill: parent; color: "#87CEEB"; z: -2 }

    // 底部菜单（不变）
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
                text: currentPage === 0 ? "抽卡模拟器\n（请将此窗口最大化）" :
                      (currentPage === 1 ? "圣晶石\n（您的财富）" : "概念礼装\n（购买后在所有模式生效；集齐5个可以提升礼装技能的效果）")
                font.pixelSize: 20; color: "white"; font.bold: true
                style: Text.Outline; styleColor: "black"
                horizontalAlignment: Text.AlignHCenter; width: parent.width * 0.9; wrapMode: Text.WordWrap
            }
        }

        Row {
            anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
            height: parent.height * 0.6; spacing: 2
            Rectangle {
                width: (parent.width - 4) / 3; height: parent.height
                color: currentPage === 0 ? "#4CAF50" : "#3A6EA5"; radius: 8
                border.color: "white"; border.width: 1
                Text { anchors.centerIn: parent; text: "抽卡模拟器"; font.pixelSize: 16; color: "white"; font.bold: true }
                MouseArea { anchors.fill: parent; onClicked: setPage(0) }
            }
            Rectangle {
                width: (parent.width - 4) / 3; height: parent.height
                color: currentPage === 1 ? "#4CAF50" : "#3A6EA5"; radius: 8
                border.color: "white"; border.width: 1
                Text { anchors.centerIn: parent; text: "圣晶石系统"; font.pixelSize: 16; color: "white"; font.bold: true }
                MouseArea { anchors.fill: parent; onClicked: setPage(1) }
            }
            Rectangle {
                width: (parent.width - 4) / 3; height: parent.height
                color: currentPage === 2 ? "#4CAF50" : "#3A6EA5"; radius: 8
                border.color: "white"; border.width: 1
                Text { anchors.centerIn: parent; text: "概念礼装"; font.pixelSize: 16; color: "white"; font.bold: true }
                MouseArea { anchors.fill: parent; onClicked: setPage(2) }
            }
        }
    }

    // ==================== 统一的关闭区域（覆盖三个页面，位置固定） ====================
    Item {
        id: closeAreaContainer
        // 与抽卡页面区域完全重叠（顶部到菜单栏顶部之间）
        anchors.top: parent.top
        anchors.bottom: menuArea.top
        anchors.left: parent.left
        anchors.right: parent.right
        z: 200  // 保证在最上层

        // 根据背景图原始尺寸 1604x720 计算相对比例
        // 关闭字样在原图的矩形区域：x:95~260 (宽165), y:7~80 (高73)
        readonly property real buttonWidthRatio: 165 / 1604      // 宽度比例
        readonly property real buttonHeightRatio: 73 / 1604       // 高度比例（但实际 y 坐标也基于宽度）
        // 注意：背景图在容器中宽度撑满，高度按比例缩放，因此关闭区域的绝对位置和大小与容器宽度成正比
        property real btnX: parent.width * (95 / 1604)
        property real btnY: parent.width * (7 / 1604)      // 基于宽度计算，与背景图实际显示位置一致
        property real btnW: parent.width * buttonWidthRatio
        property real btnH: parent.width * buttonHeightRatio

        // 第一页：热区（不带图片，利用背景已有的关闭字样）
        MouseArea {
            id: closeHotArea
            visible: root.currentPage === 0
            x: closeAreaContainer.btnX
            y: closeAreaContainer.btnY
            width: closeAreaContainer.btnW
            height: closeAreaContainer.btnH
            onClicked: App.quitPage()
        }

        // 第二、三页：关闭图片按钮（用户需自行替换图片为 165x73 尺寸）
        Image {
            id: closeImage
            visible: root.currentPage !== 0
            x: closeAreaContainer.btnX
            y: closeAreaContainer.btnY
            width: closeAreaContainer.btnW
            height: closeAreaContainer.btnH
            source: root.basePath + "close.png"
            fillMode: Image.Stretch   // 拉伸填充，用户替换图片后效果更佳
            MouseArea {
                anchors.fill: parent
                onClicked: App.quitPage()
            }
        }
    }

    // ==================== 抽卡页面 ====================
    Item {
        id: gachaPage
        anchors.top: parent.top; anchors.bottom: menuArea.top
        anchors.left: parent.left; anchors.right: parent.right
        visible: currentPage === 0

        property alias resultPopup: resultPopup
        property alias singleResultImage: singleResultImage
        property alias resultGrid: resultGrid

        // 抽卡背景和热区容器
        Item {
            id: gachaContainer
            anchors.fill: parent

            // 背景图片（跟随窗口自动缩放）
            Image {
                id: gachaBg
                width: parent.width
                anchors.top: parent.top
                source: basePath + "gacha_bg.jpg"
                fillMode: Image.PreserveAspectFit
                z: -1
            }

            // 抽卡热区容器（基于背景图片实际显示区域）
            Item {
                id: hotZoneContainer
                anchors.fill: gachaBg

                // 第一个单抽区域
                MouseArea {
                    x: gachaBg.width * (458 / 1604)
                    y: gachaBg.height * (505 / 720)
                    width: gachaBg.width * (206 / 1604)
                    height: gachaBg.height * (80 / 720)
                    onClicked: { var icon = drawOne(); root.showGachaResult([icon]); }
                }

                // 第二个单抽区域
                MouseArea {
                    x: gachaBg.width * (697 / 1604)
                    y: gachaBg.height * (505 / 720)
                    width: gachaBg.width * (206 / 1604)
                    height: gachaBg.height * (80 / 720)
                    onClicked: { var icon = drawOne(); root.showGachaResult([icon]); }
                }

                // 十连抽区域
                MouseArea {
                    x: gachaBg.width * (939 / 1604)
                    y: gachaBg.height * (505 / 720)
                    width: gachaBg.width * (206 / 1604)
                    height: gachaBg.height * (80 / 720)
                    onClicked: { var icons = drawMultiple(10); root.showGachaResult(icons); }
                }
            }
        }

        // 抽卡结果弹窗
        Rectangle {
            id: resultPopup
            anchors.centerIn: parent
            width: parent.width * 0.8; height: parent.height * 0.7
            color: "#CC000000"; radius: 10; visible: false; z: 20

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

    // ==================== 圣晶石页面 ====================
    Item {
        id: saintQuartzPage
        anchors.top: parent.top; anchors.bottom: menuArea.top
        anchors.left: parent.left; anchors.right: parent.right
        visible: currentPage === 1

        Rectangle { anchors.fill: parent; color: "#AA87CEEB"; radius: 10 }

        Column {
            anchors.centerIn: parent; spacing: 15; width: parent.width * 0.8

            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "圣晶石"; font.pixelSize: 32; color: "#FFD700"; font.bold: true; style: Text.Outline; styleColor: "black" }
            Rectangle { width: parent.width; height: 2; color: "white"; opacity: 0.5 }

            Row { spacing: 20; anchors.horizontalCenter: parent.horizontalCenter
                Text { text: "当前数量："; font.pixelSize: 20; color: "white"; font.bold: true }
                Text { text: quartzNum.toString(); font.pixelSize: 20; color: "#3A6EA5"; font.bold: true }
            }
            Row { spacing: 20; anchors.horizontalCenter: parent.horizontalCenter
                Text { text: "当前金币："; font.pixelSize: 18; color: "white"; font.bold: true }
                Text { text: goldNum.toString(); font.pixelSize: 18; color: "#3A6EA5"; font.bold: true }
            }
            Row { spacing: 20; anchors.horizontalCenter: parent.horizontalCenter
                Button {
                    text: "金币换圣晶石"
                    width: 120; height: 40
                    background: Rectangle { color: "#2196F3"; radius: 4 }
                    contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: {
                        if (goldNum >= 9305) {
                            App.setBusy(true);
                            Cpp.notifyServer("LobbyTask", ["exchange_gold_to_quartz", []]);
                        } else {
                            App.showToast("金币不足，需要9305金币");
                        }
                    }
                }
                Button {
                    text: "圣晶石兑金币"
                    width: 120; height: 40
                    background: Rectangle { color: "#FF9800"; radius: 4 }
                    contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: {
                        if (quartzNum >= 1) {
                            App.setBusy(true);
                            Cpp.notifyServer("LobbyTask", ["exchange_quartz_to_gold", []]);
                        } else {
                            App.showToast("圣晶石不足，需要1颗圣晶石");
                        }
                    }
                }
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "*现行汇率：金币按10:1折算元宝，再按3倍充值计算；<br>1颗圣晶石按非首充时的1单计算平均数，最终1圣晶石=9305金币"
                font.pixelSize: 12; color: "#666666"; wrapMode: Text.WordWrap
                width: parent.width; horizontalAlignment: Text.AlignHCenter
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
            Row { spacing: 20; anchors.horizontalCenter: parent.horizontalCenter
                Button {
                    text: "签到"; width: 100; height: 40
                    background: Rectangle { color: "#FF9800"; radius: 4; border.color: "#E67E22" }
                    contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: signIn()
                }
                Button {
                    text: "刷新"; width: 100; height: 40
                    onClicked: requestSaintQuartz()
                }
            }
        }
    }

    // ==================== 概念礼装页面 ====================
    Item {
        id: conceptClothesPage
        anchors.top: parent.top; anchors.bottom: menuArea.top
        anchors.left: parent.left; anchors.right: parent.right
        visible: currentPage === 2

        Rectangle { anchors.fill: parent; color: "#AA87CEEB"; radius: 10 }

        Text {
            anchors.top: parent.top; anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
            text: "概念礼装"
            font.pixelSize: 28; color: "white"; font.bold: true
            style: Text.Outline; styleColor: "black"
        }

        // 礼装详情弹窗
        Popup {
            id: clothDetailPopup
            modal: true
            focus: true
            width: 600
            height: 400
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
            anchors.centerIn: parent

            background: Rectangle {
                color: "#EEEEEE"
                radius: 12
                border.color: "#AAAAAA"
                border.width: 1
            }

            Row {
                spacing: 20
                anchors.fill: parent
                anchors.margins: 20

                Image {
                    id: bigImage
                    width: 200
                    height: 340
                    source: ""
                    fillMode: Image.PreserveAspectFit
                }

                Column {
                    width: parent.width - 220
                    spacing: 20
                    Text {
                        id: normalEffectText
                        width: parent.width
                        wrapMode: Text.WordWrap
                        font.pixelSize: 16
                        color: "#333333"
                    }
                    Text {
                        id: maxEffectText
                        width: parent.width
                        wrapMode: Text.WordWrap
                        font.pixelSize: 16
                        color: "#333333"
                    }
                    Text {
                        id: descText
                        width: parent.width
                        wrapMode: Text.WordWrap
                        font.pixelSize: 14
                        color: "#666666"
                    }
                }
            }
        }

        // 网格显示礼装
        GridView {
            id: clothesGrid
            anchors.top: parent.top; anchors.topMargin: 80
            anchors.bottom: parent.bottom; anchors.bottomMargin: 20
            anchors.left: parent.left; anchors.right: parent.right
            anchors.margins: 20
            clip: true
            cellWidth: 150; cellHeight: 220
            model: clothesList
            delegate: Item {
                width: 140; height: 210
                property int itemCount: Number(modelData.count)

                Column {
                    anchors.fill: parent; spacing: 5

                    Image {
                        width: 120; height: 120
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: modelData.image || (basePath + "clothes/" + modelData.name + ".jpg")
                        fillMode: Image.PreserveAspectFit

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var bigImgPath = basePath + "clothes/" + modelData.name + ".png"
                                bigImage.source = bigImgPath

                                var normalText = modelData.effectNormal || ""
                                var maxText = modelData.effectMax || ""
                                var description = modelData.description || ""

                                if (normalText === "" || maxText === "" || description === "") {
                                    var textMap = {
                                        "wanhuajing": {
                                            normal: "以蓄力点已达8点的状态开始战斗",
                                            max: "集齐5张时，以蓄力点已达10点的状态开始战斗",
                                            desc: "伟大的魔道元帅。\n守护多种可能性、多种未来的存在。\n其存在方式犹如万花筒。"
                                        }
                                    }
                                    var data = textMap[modelData.name]
                                    if (data) {
                                        if (normalText === "") normalText = data.normal
                                        if (maxText === "") maxText = data.max
                                        if (description === "") description = data.desc
                                    }
                                }

                                normalEffectText.text = normalText
                                maxEffectText.text = maxText
                                descText.text = description

                                clothDetailPopup.open()
                            }
                        }
                    }

                    Text {
                        width: parent.width
                        text: modelData.displayName
                        font.pixelSize: 14; color: "white"; font.bold: true
                        horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 8
                        Row {
                            spacing: 2
                            Repeater {
                                model: 5
                                Image {
                                    source: index < itemCount ? "../image/icon/star_filled.png" : "../image/icon/star_empty.png"
                                    width: 20; height: 20
                                }
                            }
                        }
                        Rectangle {
                            visible: itemCount < 5
                            width: 24; height: 24
                            radius: 4
                            color: "#4CAF50"
                            border.color: "white"
                            border.width: 1
                            Text {
                                text: "+"
                                anchors.centerIn: parent
                                color: "white"
                                font.bold: true
                                font.pixelSize: 16
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: exchangeClothes(modelData.name, itemCount, modelData.price)
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        // 圣晶石数据回调
        addCallback("get_player_SaintQuartz_callback", function(sender, data) {
            if (typeof data === "string") {
                try {
                    var obj = JSON.parse(data);
                    quartzNum = parseInt(obj.quartz_num) || 0;
                    goldNum = parseInt(obj.gold) || 0;
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
                        quartzNum = parseInt(obj.quartz_num) || 0;
                        signConstant = obj.sign_constant;
                        signTotal = obj.sign_total;
                        todaySigned = obj.sign_in;
                        signDate = obj.sign_date;
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

        // 兑换回调（金币↔圣晶石）
        addCallback("exchange_callback", function(sender, data) {
            if (typeof data === "string") {
                try {
                    var obj = JSON.parse(data);
                    if (obj.success) {
                        goldNum = parseInt(obj.gold) || 0;
                        quartzNum = parseInt(obj.quartz_num) || 0;
                        App.showToast(obj.message || "兑换成功");
                    } else {
                        App.showToast(obj.message || "兑换失败");
                    }
                } catch(e) {}
            }
            App.setBusy(false);
        });

        // 概念礼装数据回调
        addCallback("get_concept_clothes_callback", function(sender, data) {
            if (typeof data === "string") {
                try {
                    var obj = JSON.parse(data);
                    clothesList = obj.clothes || [];
                } catch(e) {}
            }
            App.setBusy(false);
        });

        // 概念礼装交换回调
        addCallback("exchange_concept_clothes_callback", function(sender, data) {
            if (typeof data === "string") {
                try {
                    var obj = JSON.parse(data);
                    if (obj.success) {
                        requestClothes();
                        App.showToast(obj.message || "交换成功");
                    } else {
                        App.showToast(obj.message || "交换失败");
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
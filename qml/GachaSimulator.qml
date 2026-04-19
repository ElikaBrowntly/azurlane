import QtQuick 2.15
import QtQuick.Layouts 1.12
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import Fk
import Fk.Components.LunarLTK
import Fk.Widgets as W

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

    // 概念礼装数据
    property var clothesList: []      // 存储礼装数据 [{ name, displayName, image, count, price }]

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

    // 请求礼装数据
    function requestClothes() {
        App.setBusy(true);
        Cpp.notifyServer("LobbyTask", ["get_concept_clothes", []]);
    }

    // 交换礼装（弹出对话框）
    function exchangeClothes(clothName, currentCount, pricePerOne) {
        var maxBuy = 5 - currentCount;
        if (maxBuy <= 0) {
            App.showToast("已满5星，无法再交换");
            return;
        }

        var currentValue = 1; // 用外部变量存值，不靠id

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

        // 关键：不用id，直接获取contentItem的孩子！
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

    // 背景
    Rectangle { anchors.fill: parent; color: "#87CEEB"; z: -2 }

    // 抽卡背景图片
    Image {
        width: parent.width; anchors.top: parent.top
        source: basePath + "gacha_bg.jpg"
        fillMode: Image.PreserveAspectFit
        z: -1; visible: currentPage === 0
    }

    // 底部菜单（三个等宽按钮）
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
            // 三个按钮等宽
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

    // ==================== 抽卡页面 ====================
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

        // 标题
        Text {
            anchors.top: parent.top; anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
            text: "概念礼装"
            font.pixelSize: 28; color: "white"; font.bold: true
            style: Text.Outline; styleColor: "black"
        }

        // 礼装详情弹窗（复用同一个）
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

                // 左侧大图
                Image {
                    id: bigImage
                    width: 200
                    height: 340
                    source: ""
                    fillMode: Image.PreserveAspectFit
                }

                // 右侧文本区域
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
                property int itemCount: Number(modelData.count)   // 确保为数字

                Column {
                    anchors.fill: parent; spacing: 5

                    // 可点击的图片
                    Image {
                        width: 120; height: 120
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: modelData.image || (basePath + "clothes/" + modelData.name + ".jpg")
                        fillMode: Image.PreserveAspectFit

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                // 获取大图路径（.png 格式）
                                var bigImgPath = basePath + "clothes/" + modelData.name + ".png"
                                bigImage.source = bigImgPath

                                // 获取文本内容（优先从 modelData 读取，否则从映射表获取）
                                var normalText = modelData.effectNormal || ""
                                var maxText = modelData.effectMax || ""
                                var description = modelData.description || ""

                                if (normalText === "" || maxText === "" || description === "") {
                                    // 内置映射表（可根据需要扩展）
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

                    // 礼装名称
                    Text {
                        width: parent.width
                        text: modelData.displayName
                        font.pixelSize: 14; color: "white"; font.bold: true
                        horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap
                    }

                    // 星星和加号放在同一行
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

    // 关闭按钮
    Image {
        id: closeButton
        anchors.left: parent.left; anchors.top: parent.top
        width: 80; height: 80
        source: root.basePath + "close.png"
        fillMode: Image.PreserveAspectFit
        z: 200
        MouseArea { anchors.fill: parent; onClicked: App.quitPage() }
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
                        requestClothes();   // 刷新礼装列表
                        App.showToast(obj.message || "交换成功");
                    } else {
                        App.showToast(obj.message || "交换失败");
                    }
                } catch(e) {}
            }
            App.setBusy(false);
        });

        requestSaintQuartz();  // 初始加载圣晶石页面数据
    }

    function loadData(data) {
        if (data && data.basePath) basePath = data.basePath;
    }
}
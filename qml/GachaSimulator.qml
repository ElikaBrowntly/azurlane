import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import Fk
import Fk.Components.LunarLTK

Item {
    id: root
    width: parent ? parent.width : 800
    height: parent ? parent.height : 600

    function canHandleCommand(command) { return false }

    property string basePath: "../image/icon/"

    // 抽卡配置（概率总和100%）
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

    // 底部浅天蓝色背景
    Rectangle {
        anchors.fill: parent
        color: "#87CEEB"
        z: -2

        Text {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.8   // 给一个合适的宽度，确保有居中空间
            text: "抽卡模拟器\n（请将此窗口最大化）"
            font.pixelSize: 24
            color: "white"
            font.bold: true
            style: Text.Outline
            styleColor: "black"
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap   // 可选，防止溢出
        }
    }

    // 背景图片（顶部对齐，宽度填满）
    Image {
        id: bgImage
        width: parent.width
        anchors.top: parent.top
        source: basePath + "gacha_bg.jpg"
        fillMode: Image.PreserveAspectFit
        z: -1
    }

    // ========== 三个热区（基于背景图比例定位）==========
    MouseArea {
        x: parent.width * (363 / 1450)
        y: parent.height * (435 / 720)
        width: parent.width * (207 / 1450)
        height: parent.height * (78 / 720)
        onClicked: { var icon = drawOne(); showResult([icon]); }
        Rectangle {
            anchors.fill: parent
            color: "red"
            opacity: 0.3
            border.color: "white"
            border.width: 1
            visible: false
        }
    }

    MouseArea {
        x: parent.width * (603 / 1450)
        y: parent.height * (435 / 720)
        width: parent.width * (204 / 1450)
        height: parent.height * (78 / 720)
        onClicked: { var icon = drawOne(); showResult([icon]); }
        Rectangle {
            anchors.fill: parent
            color: "red"
            opacity: 0.3
            border.color: "white"
            border.width: 1
            visible: false
        }
    }

    MouseArea {
        x: parent.width * (842 / 1450)
        y: parent.height * (435 / 720)
        width: parent.width * (204 / 1450)
        height: parent.height * (78 / 720)
        onClicked: { var icons = drawMultiple(10); showResult(icons); }
        Rectangle {
            anchors.fill: parent
            color: "red"
            opacity: 0.3
            border.color: "white"
            border.width: 1
            visible: false
        }
    }

    // 抽卡结果弹窗（根据数量切换居中单图或网格多图）
    Rectangle {
        id: resultPopup
        anchors.centerIn: parent
        width: parent.width * 0.8
        height: parent.height * 0.6
        color: "#CC000000"
        radius: 10
        visible: false
        z: 10

        // 单抽时居中显示的大图
        Image {
            id: singleResultImage
            anchors.centerIn: parent
            width: parent.width * 0.4
            height: parent.height * 0.4
            fillMode: Image.PreserveAspectFit
            visible: false
        }

        // 十连时显示的网格
        GridView {
            id: resultGrid
            anchors.fill: parent
            anchors.margins: 10
            cellWidth: (parent.width - 20) / 5
            cellHeight: cellWidth
            model: []
            visible: false
            delegate: Item {
                width: resultGrid.cellWidth
                height: resultGrid.cellHeight
                Image {
                    anchors.centerIn: parent
                    width: parent.width * 0.8
                    height: parent.height * 0.8
                    source: modelData
                    fillMode: Image.PreserveAspectFit
                }
            }
        }

        // 确认按钮
        Button {
            id: confirmButton
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter
            width: 100
            height: 40
            text: "确认"
            onClicked: {
                resultPopup.visible = false;
                singleResultImage.source = "";
                resultGrid.model = [];
            }
        }
    }

    function showResult(icons) {
        if (icons.length === 1) {
            // 单抽：显示居中大图
            singleResultImage.source = icons[0];
            singleResultImage.visible = true;
            resultGrid.visible = false;
        } else {
            // 十连：显示网格
            resultGrid.model = icons;
            resultGrid.visible = true;
            singleResultImage.visible = false;
        }
        resultPopup.visible = true;
    }

    function loadData(data) {
        if (data && data.basePath) basePath = data.basePath;
    }
}
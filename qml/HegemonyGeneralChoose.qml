import QtQuick 2.12
import QtQuick.Layouts
import QtQuick.Controls
import Fk
import Fk.Components.LunarLTK
import Fk.Pages.LunarLTK

GraphicsBox {
    id: root

    property var generals: []               // [{name, kingdom, subkingdom}]
    property string selectedMain: ""
    property string selectedDeputy: ""
    property string prompt: ""

    width: 800
    height: 600

    // 辅助函数（与之前相同）
    function getGeneralInfo(name) {
        for (var i = 0; i < generals.length; i++) {
            if (generals[i].name === name)
                return generals[i];
        }
        return null;
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
        var mk = getKingdom(main);
        var msk = getSubKingdom(main);
        var dk = getKingdom(deputy);
        var dsk = getSubKingdom(deputy);

        if (mk === "god" || mk === "evil" || dk === "god" || dk === "evil")
            return true;
        if (mk === dk && mk !== "wild")
            return true;
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

    function clearSelection() {
        selectedMain = "";
        selectedDeputy = "";
        stepText.text = prompt || "请选择主将";
    }

    function loadData(data) {
        generals = data.generals;
        prompt = data.prompt;
        clearSelection();
    }

    // 界面布局
    Rectangle {
        anchors.fill: parent
        color: "#CC000000"

        ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: 10
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            anchors.bottomMargin: 20
            spacing: 10

            Text {
                id: stepText
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                color: "#E4D5A0"
                font.pixelSize: 22
                text: prompt || "请选择主将"
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#88EEEEEE"
                radius: 8

                GridView {
                    id: gridView
                    anchors.fill: parent
                    anchors.margins: 10
                    cellWidth: 110
                    cellHeight: 140
                    model: generals
                    delegate: Item {
                        width: 100
                        height: 130

                        GeneralCardItem {
                            id: card
                            anchors.fill: parent
                            name: modelData.name
                            selectable: {
                                if (selectedMain === "" && selectedDeputy === "")
                                    return true;  // 未选任何将，都可选为主将
                                if (selectedMain !== "" && selectedDeputy === "") {
                                    // 已选主将未选副将：如果是当前主将自己，允许点击（取消选择）
                                    if (modelData.name === selectedMain)
                                        return true;
                                    else
                                        return isDeputyValid(modelData.name);
                                }
                                return false; // 已选完，禁止再选
                            }
                            selected: (selectedMain === modelData.name) || (selectedDeputy === modelData.name)
                            onSelectedChanged: {
                                if (!selected) return;
                                if (selectedMain === "") {
                                    // 选主将
                                    selectedMain = modelData.name;
                                    selectedDeputy = "";
                                    stepText.text = "请选择副将";
                                } else if (selectedDeputy === "") {
                                    // 已选主将，点击副将或点击主将自己取消
                                    if (modelData.name === selectedMain) {
                                        // 点击已选主将：取消选中
                                        clearSelection();
                                    } else {
                                        // 点击有效副将
                                        selectedDeputy = modelData.name;
                                        var resultArray = [selectedMain, selectedDeputy];
                                        ClientInstance.replyToServer("", resultArray);
                                        root.close(resultArray);
                                    }
                                }
                            }
                            onRightClicked: {
                                roomScene.startCheat("GeneralDetail", { generals: [modelData.name] });
                            }
                        }

                        // 绿色对钩标记（仅当是主将时显示）
                        Rectangle {
                            visible: selectedMain === modelData.name
                            width: 24
                            height: 24
                            radius: 12
                            color: "#4CAF50"
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 4
                            z: 1  // 确保显示在武将图上方

                            Text {
                                text: "✓"
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: 16
                                font.bold: true
                            }
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                color: "#E4D5A0"
                font.pixelSize: 12
                text: selectedMain !== "" ? "点击已选主将可重新选择" : ""
                visible: selectedMain !== ""
            }

            Button {
                text: "重置选择"
                visible: selectedMain !== ""
                onClicked: clearSelection()
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
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

    // 辅助函数
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
                                    return true;
                                if (selectedMain !== "" && selectedDeputy === "") {
                                    if (modelData.name === selectedMain)
                                        return true;
                                    else
                                        return isDeputyValid(modelData.name);
                                }
                                return false;
                            }
                            selected: (selectedMain === modelData.name) || (selectedDeputy === modelData.name)
                            onSelectedChanged: {
                                if (!selected) return;
                                if (selectedMain === "") {
                                    selectedMain = modelData.name;
                                    selectedDeputy = "";
                                    stepText.text = "请选择副将";
                                } else if (selectedDeputy === "") {
                                    if (modelData.name === selectedMain) {
                                        clearSelection();
                                    } else {
                                        selectedDeputy = modelData.name;
                                        stepText.text = "已选择副将，点击“确定”完成选将";
                                    }
                                }
                            }
                            onRightClicked: {
                                roomScene.startCheat("GeneralDetail", { generals: [modelData.name] });
                            }
                        }

                        // 主将标记
                        Rectangle {
                            visible: selectedMain === modelData.name
                            width: 24
                            height: 24
                            radius: 12
                            color: "#4CAF50"
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 4
                            z: 1

                            Text {
                                text: "主"
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: 14
                                font.bold: true
                            }
                        }

                        // 副将标记
                        Rectangle {
                            visible: selectedDeputy === modelData.name
                            width: 24
                            height: 24
                            radius: 12
                            color: "#9C27B0"
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 4
                            z: 1

                            Text {
                                text: "副"
                                anchors.centerIn: parent
                                color: "white"
                                font.pixelSize: 14
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

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 20

                Button {
                    text: "重置选择"
                    visible: selectedMain !== "" || selectedDeputy !== ""
                    onClicked: clearSelection()
                }

                Button {
                    text: "确定"
                    enabled: selectedMain !== "" && selectedDeputy !== ""
                    onClicked: {
                        var resultArray = [selectedMain, selectedDeputy];
                        ClientInstance.replyToServer("", resultArray);
                        root.close(resultArray);
                    }
                }
            }
        }
    }
}
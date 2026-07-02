// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick 2.12
import QtQuick.Layouts
import QtQuick.Controls
import LunarLtk
import LunarLtk.Pages.Popups
import LunarLtk.Components
import Fk.Components.Common
import "models"

GraphicsBox {
    id: root

    required property HualongModel dataModel

    title.text: "化龙"
    width: 720
    height: 480

    function loadData(data) {
        if (data && data.length > 0 && dataModel) {
            dataModel.generals = data[0];
        }
    }

    ColumnLayout {
        anchors.top: root.title.bottom
        anchors.left: root.left
        anchors.right: root.right
        anchors.bottom: root.bottom
        anchors.margins: 10
        spacing: 10

        Grid {
            id: grid
            Layout.fillWidth: true
            Layout.preferredHeight: 2 * (150 + 10)
            columns: 5
            rows: 2
            spacing: 10
            horizontalItemAlignment: Grid.AlignHCenter
            verticalItemAlignment: Grid.AlignVCenter

            Repeater {
                id: repeater
                model: dataModel.generals

                delegate: Item {
                    width: 120
                    height: 150

                    property string generalName: modelData
                    property bool toolTipActive: false
                    property var cardModel: Ltk.createGeneralCardModel(generalName, {
                        selectable: true,
                        selected: dataModel.selectedGeneral === generalName
                    })

                    // === 金色边框 ===
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -2
                        color: "transparent"
                        border.width: 3
                        border.color: dataModel.selectedGeneral === generalName ? "#FFD700" : "transparent"
                        radius: 4
                        z: 1  // 确保边框在卡片上方
                    }

                    GeneralCardItem {
                        id: cardItem
                        anchors.fill: parent
                        anchors.margins: 2
                        dataModel: cardModel

                        ToolTip.visible: toolTipActive
                        ToolTip.text: root.dataModel.getSkillDesc(generalName)
                        ToolTip.delay: 0
                        ToolTip.timeout: 3000

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                dataModel.selectGeneral(generalName);
                                cardModel.selected = (dataModel.selectedGeneral === generalName);
                                toolTipActive = true;
                                timer.restart();
                            }
                        }

                        Timer {
                            id: timer
                            interval: 3000
                            onTriggered: toolTipActive = false
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 8

            MetroButton {
                text: "确定"
                enabled: dataModel.selectedGeneral !== ""

                onClicked: {
                    dataModel.doAccept();
                    root.close();
                }
            }
        }
    }
}
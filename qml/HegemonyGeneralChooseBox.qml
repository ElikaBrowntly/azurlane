// packages/hidden-clouds/qml/HegemonyGeneralChooseBox.qml
import QtQuick 2.15
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Fk
import Fk.Widgets
import Fk.Components.Common
import LunarLtk
import LunarLtk.Components
import LunarLtk.Pages.Popups
import "models"

GraphicsBox {
    id: root

    z: 99999

    required property HegemonyGeneralChooseModel dataModel

    width: parent ? Math.min(parent.width, 820) : 800
    height: parent ? Math.min(parent.height, 620) : 600

    Rectangle {
        anchors.fill: parent
        color: "#CC000000"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Text {
                id: stepText
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                color: "#E4D5A0"
                font.pixelSize: 22
                text: dataModel.prompt || "请选择主将"
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
                    cellWidth: 100
                    cellHeight: 140
                    model: dataModel.generals
                    delegate: Item {
                        id: delegateItem
                        width: 93
                        height: 130

                        // 为每个武将创建一个 GeneralCardModel
                        property var cardModel: Ltk.createGeneralCardModel(modelData.name, {
                            kingdom: modelData.kingdom,
                            subkingdom: modelData.subkingdom,
                            hp: 3,
                            maxHp: 3,
                            shieldNum: 0,
                            detailed: true,
                            known: true,
                            selectable: dataModel.canSelectGeneral(modelData.name),
                            selected: (dataModel.selectedMain === modelData.name) ||
                                      (dataModel.selectedDeputy === modelData.name)
                        })

                        // 监听业务模型的变化，动态更新卡片的 selectable 和 selected
                        Connections {
                            target: dataModel
                            function onSelectedMainChanged() {
                                if (cardModel) {
                                    cardModel.selectable = dataModel.canSelectGeneral(modelData.name)
                                    cardModel.selected = (dataModel.selectedMain === modelData.name) ||
                                                         (dataModel.selectedDeputy === modelData.name)
                                }
                            }
                            function onSelectedDeputyChanged() {
                                if (cardModel) {
                                    cardModel.selectable = dataModel.canSelectGeneral(modelData.name)
                                    cardModel.selected = (dataModel.selectedMain === modelData.name) ||
                                                         (dataModel.selectedDeputy === modelData.name)
                                }
                            }
                        }

                        // 武将卡片组件
                        GeneralCardItem {
                            id: card
                            anchors.fill: parent
                            dataModel: cardModel
                        }

                        // 遮罩：仅在不可选且不是已选主/副将时显示，使剩余未选武将变暗
                        Rectangle {
                            anchors.fill: parent
                            color: "#AA000000"
                            visible: {
                                if (!cardModel) return false
                                // 如果当前武将不可选，并且既不是主将也不是副将，则显示遮罩
                                return !cardModel.selectable &&
                                       !(dataModel.selectedMain === modelData.name ||
                                         dataModel.selectedDeputy === modelData.name)
                            }
                            z: 2
                        }

                        // 点击区域（仅可选时有效）
                        MouseArea {
                            anchors.fill: parent
                            enabled: cardModel.selectable
                            onClicked: {
                                dataModel.selectGeneral(modelData.name)
                            }
                        }

                        // 主将标记
                        Rectangle {
                            visible: dataModel.selectedMain === modelData.name
                            width: 24; height: 24; radius: 12
                            color: "#4CAF50"
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 4
                            z: 3
                            Text { text: "主"; anchors.centerIn: parent; color: "white"; font.pixelSize: 14; font.bold: true }
                        }

                        // 副将标记
                        Rectangle {
                            visible: dataModel.selectedDeputy === modelData.name
                            width: 24; height: 24; radius: 12
                            color: "#9C27B0"
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 4
                            z: 3
                            Text { text: "副"; anchors.centerIn: parent; color: "white"; font.pixelSize: 14; font.bold: true }
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                color: "#E4D5A0"
                font.pixelSize: 12
                text: dataModel.selectedMain !== "" ? "点击已选主将可重新选择" : ""
                visible: dataModel.selectedMain !== ""
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 20

                Button {
                    text: "重置选择"
                    visible: dataModel.selectedMain !== "" || dataModel.selectedDeputy !== ""
                    onClicked: dataModel.clearSelection()
                }

                Button {
                    text: "确定"
                    enabled: dataModel.canConfirm
                    onClicked: dataModel.doAccept()
                }
            }
        }
    }
}

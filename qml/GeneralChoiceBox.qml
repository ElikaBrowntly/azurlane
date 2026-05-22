// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Fk
import Fk.Widgets
import Fk.Pages.LunarLTK
import Fk.Components.Common
import LunarLtk
import LunarLtk.Components
import "models"

GraphicsBox {
    id: root

    required property GeneralChoiceModel dataModel

    title.text: dataModel.prompt
    width: 600
    height: 500

    // 搜索框（仅自由选将模式可见）
    Rectangle {
        id: searchBox
        width: parent.width - 40
        height: 35
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20
        color: "#4D3F2E"
        border.color: "#A6967A"
        radius: 5
        visible: dataModel.freeAssign

        TextInput {
            id: searchInput
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            verticalAlignment: Text.AlignVCenter
            color: "#E4D5A0"
            font.pixelSize: 16
            selectByMouse: true
            text: dataModel.searchKeyword
            onTextChanged: dataModel.searchKeyword = text

            Text {
                anchors.fill: parent
                visible: !searchInput.text
                color: "#A6967A"
                font.pixelSize: 16
                verticalAlignment: Text.AlignVCenter
                text: "输入武将名称搜索..."
            }
        }
    }

    // 武将网格
    GridView {
        id: gridView
        anchors.top: searchBox.visible ? searchBox.bottom : parent.top
        anchors.topMargin: 20
        anchors.bottom: buttonRow.top
        anchors.bottomMargin: 20
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        clip: true
        cellWidth: 110
        cellHeight: 140
        model: dataModel.freeAssign ? dataModel.filteredGenerals : dataModel.limitedGenerals

        delegate: Item {
            width: 93
            height: 130

            // 为每个武将创建 GeneralCardModel
            property var cardModel: Ltk.createGeneralCardModel(modelData, {
                selectable: true,
                selected: dataModel.selectedGeneral === modelData
            })

            GeneralCardItem {
                anchors.fill: parent
                dataModel: cardModel

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        dataModel.selectGeneral(modelData)
                        cardModel.selected = (dataModel.selectedGeneral === modelData)
                    }
                }
            }

            // 可选：显示选中标记（如果想更明显可以保留）
            Rectangle {
                visible: dataModel.selectedGeneral === modelData
                width: 24; height: 24; radius: 12
                color: "#4CAF50"
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 4
                z: 1
                Text { text: "✓"; anchors.centerIn: parent; color: "white"; font.pixelSize: 16; font.bold: true }
            }
        }
    }

    // 按钮行
    RowLayout {
        id: buttonRow
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 30

        MetroButton {
            text: "取消"
            width: 100
            height: 35
            onClicked: {
                dataModel.doReject()
                root.close()
            }
        }

        MetroButton {
            text: "确定"
            width: 100
            height: 35
            enabled: dataModel.canConfirm
            onClicked: {
                dataModel.doAccept()
                root.close()
            }
        }
    }
}
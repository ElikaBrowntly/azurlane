// SPDX-License-Identifier: GPL-3.0-or-later
// 夜隐浮云·麻将模式：吃/碰分组选项框
// 每组显示两张卡图（93x130），点击某组即选用该两张牌吃/碰；可取消
// 渲染方式：外层用数量模型 + 组内两张牌显式写出，避免嵌套 Repeater
import QtQuick 2.15
import QtQuick.Controls
import Fk
import Fk.Components.Common
import LunarLtk
import LunarLtk.Pages.Popups
import LunarLtk.Components
import "models"

GraphicsBox {
    id: root

    required property YyfyMahjongMeldModel dataModel

    title.text: root.dataModel.promptText
    width: 40 + Math.min(4, root.dataModel.groupCount) * 214
    height: 270

    Rectangle {
        id: contentBox
        anchors.top: root.title.bottom
        anchors.left: root.left
        anchors.right: root.right
        anchors.bottom: buttonArea.top
        anchors.topMargin: 8
        anchors.leftMargin: 15
        anchors.rightMargin: 15
        anchors.bottomMargin: 6
        color: "#1D1E19"
        radius: 10

        Flickable {
            id: flick
            anchors.fill: parent
            clip: true
            flickableDirection: Flickable.HorizontalFlick
            ScrollBar.horizontal: ScrollBar {}

            contentWidth: groupsRow.width
            contentHeight: groupsRow.height

            Row {
                id: groupsRow
                anchors.top: parent.top
                anchors.topMargin: 12
                spacing: 10

                Repeater {
                    model: root.dataModel.groupCount
                    delegate: groupDelegate
                }
            }
        }
    }

    Component {
        id: groupDelegate

        Item {
            width: 200
            height: 146

            Rectangle {
                anchors.fill: parent
                color: mouse.containsMouse ? "#3A3B34" : "#2A2B24"
                radius: 6
                border.color: "#A6967A"
                border.width: 1
            }

            Row {
                anchors.centerIn: parent
                spacing: 8

                CardItem {
                    width: 93
                    height: 130
                    dataModel: Ltk.createCardModel(root.dataModel.idAt(index, 0))
                }

                CardItem {
                    width: 93
                    height: 130
                    dataModel: Ltk.createCardModel(root.dataModel.idAt(index, 1))
                }
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.dataModel.selectGroup(index)
            }
        }
    }

    Item {
        id: buttonArea
        anchors.left: root.left
        anchors.right: root.right
        anchors.bottom: root.bottom
        anchors.bottomMargin: 8
        height: 36
        visible: root.dataModel.cancelable

        Row {
            anchors.horizontalCenter: parent.horizontalCenter

            MetroButton {
                text: Lua.tr("Cancel")
                onClicked: root.dataModel.reject()
            }
        }
    }
}

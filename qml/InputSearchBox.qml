// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Fk
import Fk.Components.LunarLTK
import Fk.Pages.LunarLTK
import Fk.Components.Common
import Qt5Compat.GraphicalEffects
import "models"

GraphicsBox {
    id: root
    
    required property InputSearchModel dataModel
    
    title.text: "输入搜索词"
    width: 400
    height: 200
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20
        
        Text {
            text: dataModel.prompt
            color: "#E4D5A0"
            font.pixelSize: 16
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
        
        Rectangle {
            Layout.fillWidth: true
            height: 35
            color: "#4D3F2E"
            border.color: "#A6967A"
            radius: 5
            
            TextInput {
                id: inputField
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                verticalAlignment: Text.AlignVCenter
                color: "#E4D5A0"
                font.pixelSize: 16
                selectByMouse: true
                focus: true
                text: dataModel.inputText
                onTextChanged: dataModel.inputText = text
                onAccepted: confirmButton.clicked()
            }
        }
        
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 30
            
            MetroButton {
                text: "取消"
                width: 100
                height: 35
                onClicked: {
                    dataModel.doReject()
                    root.close()   // 关闭对话框
                }
            }
            
            MetroButton {
                id: confirmButton
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
    
    // 可选的 loadData 方法，用于向后兼容（如果 Lua 使用 path+data 方式）
    function loadData(data) {
        if (data && data.prompt !== undefined)
            dataModel.prompt = data.prompt
    }
}
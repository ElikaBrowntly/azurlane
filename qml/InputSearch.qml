// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Layouts
import Fk
import Fk.Components.LunarLTK
import Fk.Pages.LunarLTK
import Fk.Components.Common
import Qt5Compat.GraphicalEffects

GraphicsBox {
  id: root
  title.text: "输入搜索词"
  width: 400
  height: 200

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 20
    spacing: 20

    Text {
      text: "打草惹蛇：请宣言一个武将名（至少一个字）："
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
          close();
          roomScene.state = "notactive";
          ClientInstance.replyToServer("", ""); // 返回空
        }
      }

      MetroButton {
        id: confirmButton
        text: "确定"
        width: 100
        height: 35
        enabled: inputField.text.trim().length > 0
        onClicked: {
          close();
          roomScene.state = "notactive";
          ClientInstance.replyToServer("", inputField.text.trim());
        }
      }
    }
  }

  function loadData(data) {
    // 无需处理
  }
}
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
  width: 700
  height: 600
  title.text: "0721"

  required property Yyfy0721Model dataModel

  // 游戏结束后延迟 2 秒展示结果，再关闭对话框
  Timer {
    id: closeDelayTimer
    interval: 2000
    repeat: false
    onTriggered: {
      root.close()
    }
  }

  // 准备阶段倒计时（3 -> 0 后进入游戏阶段）
  Timer {
    id: readyTimer
    interval: 1000
    repeat: true
    onTriggered: {
      if (!dataModel.tickReady()) {
        readyTimer.stop()
        gameTimer.start()
      }
    }
  }

  // 游戏阶段倒计时（3 秒内点击）
  Timer {
    id: gameTimer
    interval: 1000
    repeat: true
    onTriggered: {
      if (!dataModel.tickGame()) {
        gameTimer.stop()
      }
    }
  }

  Connections {
    target: dataModel
    function onFinished() {
      closeDelayTimer.start()
    }
  }

  Component.onCompleted: {
    dataModel.start()
    readyTimer.start()
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 20
    spacing: 20

    RowLayout {
      Layout.alignment: Qt.AlignHCenter
      spacing: 40
      Text {
        text: "剩余时间: " + dataModel.timeLeft + "秒"
        color: "white"
        font.pixelSize: 24
        font.bold: true
      }
      Text {
        text: "点击次数: " + dataModel.clickCount + "/" + dataModel.targetCount
        color: "white"
        font.pixelSize: 24
        font.bold: true
        Text {
          anchors.left: parent.right
          anchors.leftMargin: 10
          anchors.verticalCenter: parent.verticalCenter
          text: dataModel.gameFinished ? "✓" : ""
          color: "green"
          font.pixelSize: 24
          font.bold: true
        }
      }
    }

    Item {
      Layout.preferredWidth: 300
      Layout.preferredHeight: 300
      Layout.alignment: Qt.AlignHCenter

      Image {
        anchors.fill: parent
        source: dataModel.imagePath ? Qt.resolvedUrl(dataModel.imagePath) : ""
        fillMode: Image.PreserveAspectFit
        visible: source !== ""
      }
      Rectangle {
        anchors.fill: parent
        color: "gray"
        visible: !dataModel.imagePath || dataModel.imagePath === ""
        Text {
          anchors.centerIn: parent
          text: "0721"
          color: "white"
          font.pixelSize: 30
        }
      }
    }

    RoundButton {
      id: clickButton
      Layout.preferredWidth: 200
      Layout.preferredHeight: 200
      Layout.alignment: Qt.AlignHCenter
      // 按钮文字：准备阶段显示数字，游戏阶段显示“点我”或“完成”
      text: {
        if (dataModel.gameFinished) return "完成"
        if (dataModel.readyPhase) return dataModel.readyCountdown.toString()
        return "点我"
      }
      font.pixelSize: 40
      font.bold: true
      radius: width / 2
      enabled: !dataModel.readyPhase && !dataModel.gameFinished
      background: Rectangle {
        radius: parent.radius
        color: {
          if (dataModel.gameFinished) return "#CCCCCC"
          if (dataModel.readyPhase) return "#66CCFF"
          return "#D8B4E2"
        }
        border.color: "white"
        border.width: 4
      }
      contentItem: Text {
        text: parent.text
        color: "white"
        font: parent.font
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }
      onClicked: {
        dataModel.registerClick()
      }
    }

    Text {
      Layout.alignment: Qt.AlignHCenter
      text: "在3秒内尽可能点击按钮！达到21次自动结束。"
      color: "white"
      font.pixelSize: 18
    }
  }
}
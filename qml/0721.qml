// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Fk 1.0
import Fk.Pages.LunarLTK 1.0
import Fk.Components.LunarLTK 1.0
import Fk.Components.Common 1.0

GraphicsBox {
  id: root
  width: 700
  height: 600
  title.text: "0721"

  property string imagePath: ""
  property int clickCount: 0
  property int targetCount: 21
  property int timeLeft: 5
  property bool gameFinished: false

  function loadData(data) {
    if (data && data.imagePath) {
      imagePath = data.imagePath
    }
  }

  Timer {
    id: timer
    interval: 1000
    repeat: true
    running: !gameFinished
    onTriggered: {
      timeLeft -= 1
      if (timeLeft <= 0 && !gameFinished) {
        finishGame()
      }
    }
  }

  Timer {
    id: closeDelayTimer
    interval: 2000
    onTriggered: {
      closeAndReturn()
    }
  }

  onClickCountChanged: {
    if (clickCount >= targetCount && !gameFinished) {
      finishGame()
    }
  }

  function finishGame() {
    if (gameFinished) return
    gameFinished = true
    timer.stop()
    closeDelayTimer.start()
  }

  function closeAndReturn() {
    if (closeDelayTimer.running) closeDelayTimer.stop()
    timer.stop()
    roomScene.state = "notactive"
    ClientInstance.replyToServer("", { count: clickCount })
    // 使用 Qt.callLater 延迟调用 close，确保上下文正确
    Qt.callLater(function() {
      root.close()
    })
  }

  Component.onCompleted: {
    x = (roomScene.width - width) / 2
    y = (roomScene.height - height) / 3
    timer.start()
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 20
    spacing: 20

    RowLayout {
      Layout.alignment: Qt.AlignHCenter
      spacing: 40
      Text {
        text: "剩余时间: " + timeLeft + "秒"
        color: "white"
        font.pixelSize: 24
        font.bold: true
      }
      Text {
        text: "点击次数: " + clickCount + "/" + targetCount
        color: "white"
        font.pixelSize: 24
        font.bold: true
        Text {
          anchors.left: parent.right
          anchors.leftMargin: 10
          anchors.verticalCenter: parent.verticalCenter
          text: gameFinished ? "✓" : ""
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
        source: imagePath ? Qt.resolvedUrl(imagePath) : ""
        fillMode: Image.PreserveAspectFit
        visible: source !== ""
      }
      Rectangle {
        anchors.fill: parent
        color: "gray"
        visible: !imagePath || imagePath === ""
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
      text: gameFinished ? "完成" : "点我"
      font.pixelSize: 40
      font.bold: true
      radius: width / 2
      enabled: !gameFinished
      background: Rectangle {
        radius: parent.radius
        color: gameFinished ? "#CCCCCC" : "#D8B4E2"
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
        if (!gameFinished) {
          clickCount++
        }
      }
    }

    Text {
      Layout.alignment: Qt.AlignHCenter
      text: "在5秒内尽可能点击按钮！达到21次自动结束。"
      color: "white"
      font.pixelSize: 18
    }
  }
}
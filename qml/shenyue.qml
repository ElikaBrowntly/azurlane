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
  width: 800
  height: 600
  title.text: "神乐"

  property var dressImages: []
  property var musicCovers: []
  property var musicNames: []
  property int selectedDress: -1   // -1 表示未选
  property int selectedMusic: -1

  function loadData(data) {
    if (data) {
      dressImages = data.dressImages || []
      musicCovers = data.musicCovers || []
      musicNames = data.musicNames || []
    }
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 20
    spacing: 30

    // ----- 第一行：服饰 -----
    RowLayout {
      Layout.fillWidth: true
      spacing: 20

      Rectangle {
        Layout.preferredWidth: 30
        Layout.fillHeight: true
        color: "#6B5D42"
        radius: 5
        Text {
          anchors.centerIn: parent
          text: "更换服饰"
          color: "white"
          font.family: Config.libianName
          font.pixelSize: 18
          rotation: 270
        }
      }

      RowLayout {
        Layout.fillWidth: true
        spacing: 15
        Repeater {
          model: dressImages
          delegate: Item {
            width: 120
            height: 180  // 图片140 + 空白40
            Rectangle {
              anchors.fill: parent
              color: "transparent"
              border.color: (selectedDress === index) ? "gold" : "transparent"
              border.width: 3
              radius: 5
              Column {
                anchors.fill: parent
                Image {
                  width: 120
                  height: 140
                  source: Qt.resolvedUrl(modelData)
                  fillMode: Image.PreserveAspectCrop
                  asynchronous: true
                }
                Item { width: 120; height: 40 } // 空白区域
              }
              MouseArea {
                anchors.fill: parent
                onClicked: {
                  selectedDress = (selectedDress === index) ? -1 : index
                }
              }
            }
          }
        }
      }
    }

    // ----- 第二行：背景音乐 -----
    RowLayout {
      Layout.fillWidth: true
      spacing: 20

      Rectangle {
        Layout.preferredWidth: 30
        Layout.fillHeight: true
        color: "#6B5D42"
        radius: 5
        Text {
          anchors.centerIn: parent
          text: "背景音乐"
          color: "white"
          font.family: Config.libianName
          font.pixelSize: 18
          rotation: 270
        }
      }

      RowLayout {
        Layout.fillWidth: true
        spacing: 15
        Repeater {
          model: musicCovers
          delegate: Item {
            width: 120
            height: 170  // 图片140 + 文字30
            Rectangle {
              anchors.fill: parent
              color: "transparent"
              border.color: (selectedMusic === index) ? "gold" : "transparent"
              border.width: 3
              radius: 5
              Column {
                anchors.fill: parent
                Image {
                  width: 120
                  height: 140
                  source: Qt.resolvedUrl(modelData)
                  fillMode: Image.PreserveAspectCrop
                  asynchronous: true
                }
                Text {
                  width: 120
                  height: 30
                  text: musicNames[index] || ("歌曲" + (index+1))
                  color: "white"
                  font.pixelSize: 14
                  horizontalAlignment: Text.AlignHCenter
                  wrapMode: Text.WordWrap
                }
              }
              MouseArea {
                anchors.fill: parent
                onClicked: {
                  selectedMusic = (selectedMusic === index) ? -1 : index
                }
              }
            }
          }
        }
      }
    }

    RowLayout {
      Layout.alignment: Qt.AlignHCenter
      spacing: 20

      MetroButton {
        text: "确定"
        onClicked: {
          var reply = {}
          if (selectedDress !== -1) reply.dress = selectedDress
          if (selectedMusic !== -1) reply.bgm = selectedMusic
          root.close()
          roomScene.state = "notactive"
          ClientInstance.replyToServer("", reply)
        }
      }

      MetroButton {
        text: "取消"
        onClicked: {
          root.close()
          roomScene.state = "notactive"
          ClientInstance.replyToServer("", {})
        }
      }
    }
  }

  Component.onCompleted: {
    x = (roomScene.width - width) / 2
    y = (roomScene.height - height) / 3
  }
}
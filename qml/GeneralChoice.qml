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
  property var generals: []          // 传入的武将列表（内部名）
  property bool freeAssign: true      // 是否允许自由选将
  property string selectedGeneral: "" // 当前选中的武将名
  property var filteredGenerals: []   // 过滤后的武将列表（用于自由选将）
  property var limitedGenerals: []    // 用于非自由选将时的随机列表

  title.text: "选择武将"
  width: 600
  height: 500

  // 搜索框（仅当 freeAssign 为 true 时显示）
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
    visible: root.freeAssign

    TextInput {
      id: searchInput
      anchors.fill: parent
      anchors.leftMargin: 10
      anchors.rightMargin: 10
      verticalAlignment: Text.AlignVCenter
      color: "#E4D5A0"
      font.pixelSize: 16
      selectByMouse: true
      onTextChanged: filterGenerals()
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
    model: root.freeAssign ? filteredGenerals : limitedGenerals
    delegate: GeneralCardItem {
      width: 100
      height: 130
      name: modelData
      selectable: true
      selected: root.selectedGeneral === modelData
      onClicked: {
        if (selectable) {
          root.selectedGeneral = (root.selectedGeneral === modelData) ? "" : modelData;
        }
      }
    }
  }

  // 按钮行（使用 MetroButton）
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
        close();
        roomScene.state = "notactive";
        // 返回空表示取消
        ClientInstance.replyToServer("", "");
      }
    }

    MetroButton {
      text: "确定"
      width: 100
      height: 35
      enabled: root.selectedGeneral !== ""
      onClicked: {
        close();
        roomScene.state = "notactive";
        // 返回选中的武将名（字符串）
        ClientInstance.replyToServer("", root.selectedGeneral);
      }
    }
  }

  // 初始化
  function loadData(data) {
    generals = data.generals || [];
    freeAssign = data.freeAssign !== false; // 默认 true
    // 根据 freeAssign 初始化相应的列表
    if (freeAssign) {
      filterGenerals(); // 搜索过滤初始化
    } else {
      randomizeLimitedGenerals();
    }
  }

  // 过滤函数（用于自由选将）
  function filterGenerals() {
    if (!root.freeAssign) return;
    let keyword = searchInput.text.trim().toLowerCase();
    if (keyword === "") {
      filteredGenerals = generals;
    } else {
      filteredGenerals = generals.filter(function(gen) {
        let translated = Backend.translate(gen).toLowerCase();
        return translated.indexOf(keyword) !== -1;
      });
    }
  }

  // 随机抽取最多16个武将（用于非自由选将）
  function randomizeLimitedGenerals() {
    let list = generals;
    if (list.length > 16) {
      // 随机抽取16个（Fisher-Yates 洗牌取前16）
      let shuffled = list.slice();
      for (let i = shuffled.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
      }
      limitedGenerals = shuffled.slice(0, 16);
    } else {
      limitedGenerals = list;
    }
    // 如果之前选中的武将不在新列表中，清除选中
    if (selectedGeneral && !limitedGenerals.includes(selectedGeneral)) {
      selectedGeneral = "";
    }
  }

  // 当 generals 变化时重新处理
  onGeneralsChanged: {
    if (freeAssign) {
      filterGenerals();
    } else {
      randomizeLimitedGenerals();
    }
  }

  // 当 freeAssign 变化时重新处理
  onFreeAssignChanged: {
    if (freeAssign) {
      filterGenerals();
    } else {
      randomizeLimitedGenerals();
    }
  }
}
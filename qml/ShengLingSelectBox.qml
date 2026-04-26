// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Fk
import Fk.Components.LunarLTK
import Fk.Pages.LunarLTK
import Fk.Components.Common

GraphicsBox {
  id: root

  property var selectedItem: []
  property var generals: []      // 将由 loadData 赋值

  title.text: Lua.tr("圣灵封印")

  width: 640
  height: 480

  // 接收从 Lua 传来的 extra_data
  function loadData(data) {
    generals = data[0];  // data[0] 为武将名称数组
  }

  // 根据武将 ID 返回对应的技能名称
  function getSkillDesc(generalId) {
    switch(generalId) {
      case "yyfy_shenglingpuni1": return "虚无：你受到伤害后，终止一切结算并立即结束此回合。你出场时，继承所有技能、终止一切结算并立即行动。";
      case "yyfy_shenglingpuni2": return "元素：当你即将造成属性伤害时，令目标获得“元素”标记，拥有此标记的角色发动技能时取消之，直到伤害结算。";
      case "yyfy_shenglingpuni3": return "能量：你使用牌无次数和距离限制，你造成的伤害等同于你的技能数量；当你受到其他角色的伤害时，你对其造成一点伤害。";
      case "yyfy_shenglingpuni4": return "生命：你的体力上限不会减少。有角色回复体力时，你回复等量体力，若体力值满，增加一点体力上限。";
      case "yyfy_shenglingpuni5": return "轮回：你死亡时，若你的体力上限大于轮次+X，且武将牌已全部出场，你复活并增加一点体力上限。";
      case "yyfy_shenglingpuni6": return "永恒：你的手牌数始终不少于体力上限。当你的体力上限增加时，你令一名角色失去等量体力上限。";
      case "yyfy_shenglingpuni7": return "圣洁：你的技能无法失去或失效。你无法被翻面/横置/操控/替换武将牌。你的阶段不能被跳过。有技能发动时清除你的标记。";
      default: return "";
    }
  }

  ColumnLayout {
    anchors.top: root.title.bottom
    anchors.left: root.left
    anchors.right: root.right
    anchors.bottom: root.bottom
    anchors.margins: 10
    spacing: 10

    // 武将网格
    GridView {
      id: grid
      Layout.fillWidth: true
      Layout.fillHeight: true
      cellWidth: 140
      cellHeight: 170
      model: generals

      delegate: GeneralCardItem {
        id: cardItem
        width: 120
        height: 150
        name: modelData
        selectable: true
        chosenInBox: root.selectedItem.includes(modelData)

        // 使用标准 ToolTip（附加属性）
        ToolTip.visible: cardItem.showToolTip
        ToolTip.text: getSkillDesc(modelData)
        ToolTip.delay: 0
        ToolTip.timeout: 3000

        // 自定义标志，控制 ToolTip 显示
        property bool showToolTip: false

        MouseArea {
          anchors.fill: parent
          onClicked: {
            root.selectedItem = [modelData];
            cardItem.showToolTip = true;
            toolTipTimer.restart();
          }
        }

        Timer {
          id: toolTipTimer
          interval: 3000
          onTriggered: cardItem.showToolTip = false
        }
      }
    }

    // 确认按钮
    RowLayout {
      Layout.alignment: Qt.AlignHCenter
      spacing: 8

      MetroButton {
        text: "确定"
        enabled: root.selectedItem.length > 0

        onClicked: {
          close();
          roomScene.state = "notactive";
          const reply = { general: root.selectedItem[0] };
          ClientInstance.replyToServer("", reply);
        }
      }
    }
  }
}
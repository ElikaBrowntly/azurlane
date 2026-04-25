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

  title.text: "化龙"            // 修改为“化龙”

  width: 720
  height: 480

  // 接收从 Lua 传来的 extra_data
  function loadData(data) {
    generals = data[0];  // data[0] 为武将名称数组（10个）
  }

  // 根据武将 ID 返回对应的技能名称
  function getSkillDesc(generalId) {
    switch(generalId) {
      case "yyfy_longchen1": return "起源：持恒技，出牌阶段限一次，你可以执行一次“游戏开始时”的时机（仅你自己执行）。<br>灵魂：持恒技，你不能被操控，替换武将牌。当此化身登场时，其他角色随机变更主将并移除副将。";
      case "yyfy_longchen2": return "元始：持恒技，出牌阶段，你可以失去1点体力，然后重置一名角色的技能使用次数。<br>造化：持恒技，每轮限一次，当你即将死亡时，你可以将体力值回复至1并立即结束当前回合，然后你执行一个额外回合。";
      case "yyfy_longchen3": return "永恒：持恒技，在你受到负面效果前，你可将此负面效果改为你指定的另一种负面效果，然后将你所有标记以及标记的值调整至你发动〖永恒〗前。";
      case "yyfy_longchen4": return "命运：持恒技，回合开始时，你可以展示牌堆顶的一张牌。然后直到你的下回合开始前，你使用该类型牌时，摸一张牌。你使用的牌的基础数值随机+0∽X（X为展示牌的点数）。";
      case "yyfy_longchen5": return "因果：持恒技，出牌阶段，你可以变更一名角色的的势力或身份牌。当游戏即将结束时，将你的身份牌变更为胜利方身份。";
      case "yyfy_longchen6": return "生命：持恒技，当你的体力值减少后，你获得等量个“生命”标记。出牌阶段，你可以消耗3个“生命”标记复活一名角色。当你死亡时，你可消耗5个“生命”标记复活。";
      case "yyfy_longchen7": return "天灾：持恒技，当你获得此技能时和游戏开始时，你可令一名角色获得“灾”标记，拥有“灾”标记的角色发动技能前取消之。";
      case "yyfy_longchen8": return "血噬：持恒技，当你对一名角色造成伤害后，你可以增加1点体力上限并回复1点体力，然后令其减少1点体力上限。";
      case "yyfy_longchen9": return "天幽：持恒技，游戏开始时和每轮开始时，你可以重新分配所有角色的座次。";
      case "yyfy_longchen10": return "吞噬：持恒技，当你获得此技能时，可以吞噬一名角色（吞噬：获得被吞噬者的所有技能，且当其获得技能时，你也获得之。），当你对一名角色造成伤害后，你可以获得其任意个技能。若游戏结束时，你获得胜利，则你永久拥有本局游戏获得的技能。出牌阶段，你可以调整你的技能。";
      default: return "";
    }
  }

  // 全局 ToolTip 文本（供动态显示）
  property string currentTipText: ""

  ColumnLayout {
    anchors.top: root.title.bottom
    anchors.left: root.left
    anchors.right: root.right
    anchors.bottom: root.bottom
    anchors.margins: 10
    spacing: 10

    Grid {
      id: grid
      Layout.fillWidth: true
      Layout.preferredHeight: 2 * (150 + 10)
      columns: 5
      rows: 2
      spacing: 10
      horizontalItemAlignment: Grid.AlignHCenter
      verticalItemAlignment: Grid.AlignVCenter

      Repeater {
        id: repeater
        model: generals

        delegate: Item {
          width: 120
          height: 150

          GeneralCardItem {
            id: cardItem
            anchors.fill: parent
            anchors.margins: 2
            name: modelData
            selectable: true
            chosenInBox: root.selectedItem.includes(modelData)

            // 绑定 ToolTip（QtQuick.Controls 标准用法）
            ToolTip.visible: cardItem.toolTipActive
            ToolTip.text: getSkillDesc(modelData)
            ToolTip.delay: 0
            ToolTip.timeout: 3000

            property bool toolTipActive: false

            MouseArea {
              anchors.fill: parent
              onClicked: {
                root.selectedItem = [modelData];
                // 激活 ToolTip 显示
                cardItem.toolTipActive = true;
                toolTipTimer.restart();
              }
            }

            Timer {
              id: toolTipTimer
              interval: 3000
              onTriggered: cardItem.toolTipActive = false
            }
          }
        }
      }
    }

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
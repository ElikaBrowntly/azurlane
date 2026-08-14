// packages/hidden-clouds/qml/models/HualongModel.qml
import QtQuick 2.12
import Fk

QtObject {
    id: root

    property var generals: []
    property string selectedGeneral: ""
    property var result: null
    signal accepted()
    signal rejected()

    function getSkillDesc(generalId) {
        switch(generalId) {
            case "yyfy_longchen1": return "起源：持恒技，出牌阶段限一次，你可以执行一次“游戏开始时”的时机。<br>灵魂：持恒技，你不能被操控、替换武将牌。当此化身登场时，其他角色随机变更主将并移除副将。";
            case "yyfy_longchen2": return "元始：持恒技，出牌阶段，你可以失去1点体力，然后令一名角色的技能视为未发动过。<br>造化：持恒技，每轮限一次，当你即将死亡时，你可以将体力值回复至1，终止一切结算并结束当前回合，然后你立即行动。";
            case "yyfy_longchen3": return "永恒：持恒技，在你受到负面效果前，你可将此负面效果改为另一种负面效果，然后将你所有标记及其值调整至发动〖永恒〗前。";
            case "yyfy_longchen4": return "命运：持恒技，回合开始时，你可以展示牌堆顶的一张牌。然后直到你的下回合开始前，你使用该类型牌时，摸一张牌。你使用的基本牌数值随机+0~X（X为展示牌的点数）。";
            case "yyfy_longchen5": return "因果：持恒技，出牌阶段，你可以变更一名角色的的势力或身份牌。当游戏即将结束时，你加入胜利方。";
            case "yyfy_longchen6": return "生命：持恒技，当你的体力值减少后，你获得等量个“生命”标记。出牌阶段，你可以消耗3个“生命”标记复活一名角色。当你死亡时，你可消耗5个“生命”复活。";
            case "yyfy_longchen7": return "天灾：持恒技，当你获得此技能时和游戏开始时，你可令一名角色获得“灾”标记，拥有“灾”标记的角色发动技能前取消之。";
            case "yyfy_longchen8": return "血噬：持恒技，当你对一名角色造成伤害后，你可以增加1点体力上限并回复1点体力，然后令其减少1点体力上限。";
            case "yyfy_longchen9": return "天幽：持恒技，游戏开始时和每轮开始时，你可以重新分配所有角色的座次。";
            case "yyfy_longchen10": return "吞噬：持恒技，当你获得此技能时，可以吞噬一名角色。当你造成伤害后，你可以获得对方任意个技能。游戏结束时，若你获得胜利，则你永久拥有本局游戏获得的技能。出牌阶段，你可以调整你的技能。";
            default: return "";
        }
    }

    function selectGeneral(name) {
        selectedGeneral = name;
    }

    function doAccept() {
        result = selectedGeneral;
        accepted();
    }

    function doReject() {
        rejected();
    }
}
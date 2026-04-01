import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Fk
import Fk.Components.LunarLTK
import Fk.Pages.LunarLTK
import Fk.Components.Common

GraphicsBox {
    id: root
    width: 932
    height: 810
    scale: 0.7
    // 居中显示
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    // 固定十个化身，顺序为逆时针排列（强风在108°起始，逆时针依次）
    property var allSkills: [
        "yyfy_zhanshi",    // 战士
        "yyfy_shanyang",   // 山羊
        "yyfy_muyang",     // 牡羊
        "yyfy_fenghuang",  // 凤凰
        "yyfy_shaonian",   // 少年
        "yyfy_shanzhu",    // 山猪
        "yyfy_luotuo",     // 骆驼
        "yyfy_baima",      // 白马
        "yyfy_gongniu",    // 公牛
        "yyfy_qiangfeng"   // 强风
    ]
    property var skillNames: ["战士", "山羊", "牡羊", "凤凰", "少年", "山猪", "骆驼", "白马", "公牛", "强风"]
    property var disabledSkills: []     // 不可选的技能列表（显示灰色）
    property var selectedSkills: []     // 当前选中的技能
    property int maxSelect: 3

    // 几何参数
    property real centerX: width / 2
    property real centerY: height / 2
    property real outerRadius: 350
    property real textRadius: 410

    // 起始角度：-72°（弧度）
    property real startAngle: -Math.PI * 2 / 5
    property real step: Math.PI * 2 / allSkills.length

    // 背景图片
    Image {
        id: bg
        anchors.fill: parent
        source: "../image/anim/quanneng.png"
        fillMode: Image.PreserveAspectFit
    }

    // 绘制高亮区域（只绘制选中的扇形，不可选区域不绘制高亮）
    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            for (var i = 0; i < allSkills.length; i++) {
                var skill = allSkills[i];
                if (selectedSkills.indexOf(skill) !== -1) {
                    var sAngle = startAngle + i * step;
                    var eAngle = sAngle + step;
                    ctx.beginPath();
                    ctx.moveTo(centerX, centerY);
                    ctx.arc(centerX, centerY, outerRadius, sAngle, eAngle);
                    ctx.closePath();
                    ctx.fillStyle = "rgba(255,255,255,0.6)";
                    ctx.fill();
                }
            }
        }
    }

    // 文字标注
    Repeater {
        model: skillNames
        Text {
            property real angle: startAngle + (index + 0.5) * step
            x: centerX + textRadius * Math.cos(angle) - width/2
            y: centerY + textRadius * Math.sin(angle) - height/2
            text: modelData
            font.pixelSize: 22
            font.bold: true
            color: disabledSkills.indexOf(allSkills[index]) !== -1 ? "#888888" : "#F0E68C"
            style: Text.Outline
            styleColor: "black"
        }
    }

    // 鼠标交互
    MouseArea {
        anchors.fill: parent
        onClicked: (mouse) => {
            var dx = mouse.x - centerX;
            var dy = mouse.y - centerY;
            var angle = Math.atan2(dy, dx);
            var theta = (angle + Math.PI*2) % (Math.PI*2);
            var relative = (theta - startAngle + Math.PI*2) % (Math.PI*2);
            var idx = Math.floor(relative / step);
            if (idx < 0 || idx >= allSkills.length) return;

            var skill = allSkills[idx];
            // 如果不可选，忽略点击
            if (disabledSkills.indexOf(skill) !== -1) return;

            var pos = selectedSkills.indexOf(skill);
            if (pos !== -1) {
                selectedSkills.splice(pos, 1);
            } else {
                if (selectedSkills.length < maxSelect) {
                    selectedSkills.push(skill);
                } else {
                    // 已达上限，不处理
                    return;
                }
            }
            updateButtonState();
            canvas.requestPaint();
        }
    }

    // 按钮区域
    RowLayout {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 30

        MetroButton {
            text: "取消"
            width: 100
            height: 40
            onClicked: {
                close();
                ClientInstance.replyToServer("", "");
            }
        }

        MetroButton {
            id: confirmBtn
            text: "确定"
            width: 100
            height: 40
            enabled: selectedSkills.length > 0 && selectedSkills.length <= maxSelect
            onClicked: {
                close();
                ClientInstance.replyToServer("", JSON.stringify(selectedSkills));
            }
        }
    }

    function updateButtonState() {
        confirmBtn.enabled = selectedSkills.length > 0 && selectedSkills.length <= maxSelect;
    }

    // 加载数据
    function loadData(data) {
        // data 格式: [available_skills, disabled_skills]
        // available_skills: 本次可选的技能列表（即未被上一回合禁用）
        // disabled_skills: 显式禁用的技能列表（例如上回合获得过的）
        if (data && data.length >= 2) {
            var available = data[0] || [];
            var disabledFromData = data[1] || [];
            // 计算最终禁用列表：所有不在 available 中的技能 + 显式禁用的技能
            var newDisabled = [];
            for (var i = 0; i < allSkills.length; i++) {
                var skill = allSkills[i];
                if (available.indexOf(skill) === -1 || disabledFromData.indexOf(skill) !== -1) {
                    newDisabled.push(skill);
                }
            }
            disabledSkills = newDisabled;
        } else {
            disabledSkills = [];
        }
        selectedSkills = [];
        updateButtonState();
        canvas.requestPaint();
    }
}
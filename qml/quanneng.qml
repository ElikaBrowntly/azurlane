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
    // 居中显示（GraphicsBox 可能已处理，这里仍保留）
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    property var allSkills: [
        "yyfy_qiangfeng", "yyfy_gongniu", "yyfy_baima", "yyfy_luotuo", "yyfy_shanzhu",
        "yyfy_shaonian", "yyfy_fenghuang", "yyfy_muyang", "yyfy_shanyang", "yyfy_zhanshi"
    ]
    property var skillNames: ["强风", "公牛", "白马", "骆驼", "山猪", "少年", "凤凰", "牡羊", "山羊", "战士"]
    property var disabledSkills: []
    property var selectedSkills: []
    property int maxSelect: 3

    // 几何参数
    property real centerX: width / 2
    property real centerY: height / 2
    property real outerRadius: 350
    property real textRadius: 410

    // 起始角度：-18°
    property real startAngle: -Math.PI * 3 / 5
    property real step: Math.PI * 2 / allSkills.length

    // 背景图片
    Image {
        id: bg
        anchors.fill: parent
        source: "../image/anim/quanneng.png"
        fillMode: Image.PreserveAspectFit
    }

    // 绘制高亮区域（只绘制选中的扇形，无描边）
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
            if (disabledSkills.indexOf(skill) !== -1) return;

            var pos = selectedSkills.indexOf(skill);
            if (pos !== -1) {
                selectedSkills.splice(pos, 1);
            } else {
                if (selectedSkills.length < maxSelect) {
                    selectedSkills.push(skill);
                } else {
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
                close();   // GraphicsBox 提供的方法
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
                close();   // GraphicsBox 提供的方法
                ClientInstance.replyToServer("", JSON.stringify(selectedSkills));
            }
        }
    }

    function updateButtonState() {
        confirmBtn.enabled = selectedSkills.length > 0 && selectedSkills.length <= maxSelect;
    }

    function loadData(data) {
        if (data && data.length >= 2) {
            if (data[0] && data[0].length > 0) {
                allSkills = data[0];
            }
            disabledSkills = data[1] || [];
        }
        selectedSkills = [];
        updateButtonState();
        canvas.requestPaint();
    }
}
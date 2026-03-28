import QtQuick
import QtQuick.Window
import QtQuick.Controls 2.5

Item {
    id: root
    anchors.fill: parent

    // 透明遮罩（无黑框）
    Rectangle {
        id: mask
        anchors.fill: parent
        color: "transparent"
    }

    AnimatedImage {
        id: animation
        source: "../videos/diyitaiyang1.gif"
        asynchronous: true
        cache: false
        playing: true

        // 动态计算位置和大小，保持比例且尽量充满屏幕
        width: {
            var screenRatio = parent.width / parent.height
            var gifRatio = implicitWidth / implicitHeight
            if (gifRatio > screenRatio) {
                // GIF 更宽，宽度撑满，高度自适应
                return parent.width
            } else {
                // GIF 更高，高度撑满，宽度自适应
                return parent.width * (gifRatio / screenRatio)
            }
        }
        height: {
            var screenRatio = parent.width / parent.height
            var gifRatio = implicitWidth / implicitHeight
            if (gifRatio > screenRatio) {
                // 宽度撑满，高度按比例
                return parent.width / gifRatio
            } else {
                // 高度撑满
                return parent.height
            }
        }
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
    }

    // 辅助矩形，用于检测最后一帧并停止播放
    Rectangle {
        property int frames: animation.frameCount
        property int gframes: animation.currentFrame
        width: 2
        height: 2
        x: (animation.width - width) * animation.currentFrame / (frames > 0 ? frames : 1)
        y: animation.height
        color: "transparent"

        onGframesChanged: {
            if (frames > 0 && animation.currentFrame === frames - 1) {
                animation.playing = false
                animation.source = ""  // 释放资源
                //close()  // 关闭 LightBox
            }
        }
    }
}
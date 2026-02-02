import QtQuick
import QtQuick.Window
import QtQuick.Controls 2.5

Item {
    id: root
    scale: 0.75
    anchors.fill: parent

    Rectangle {
        id: mask
        scale: 1 / 0.75
        anchors.fill: parent
        color: "black"
        opacity: 0.7
    }
    
    AnimatedImage {
        id: animation
        source: "../videos/diyitaiyang1.gif"
        anchors.fill: parent
        asynchronous: true
        cache: false
        playing: true
    }
    
    Rectangle {
        property int frames: animation.frameCount
        property int gframes: animation.currentFrame

        width: 2
        height: 2
        x: (animation.width - width) * animation.currentFrame / frames
        y: animation.height
        color: "red"
        
        onGframesChanged: {
            // 当动画播放到最后一帧时，停止动画并清空roomScene.bigAnim.source
            if (animation.currentFrame === animation.frameCount - 1) {
                animation.playing = false
                animation.source = ""
                roomScene.bigAnim.source = ""
            }
        }
    }
}
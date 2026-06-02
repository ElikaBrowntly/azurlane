import QtQuick
import QtQuick.Window
import QtQuick.Controls 2.5
import QtMultimedia          // 导入多媒体模块

Item {
    id: root
    anchors.fill: parent

    // 透明遮罩（无黑框）
    Rectangle {
        anchors.fill: parent
        color: "transparent"
    }

    // 视频输出区域
    VideoOutput {
        id: videoOutput
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectFit   // 等比缩放居中
    }

    // 媒体播放器
    MediaPlayer {
        id: mediaPlayer
        source: "../videos/yyfy_end__zhongyan__2.mp4"  // 请确认路径正确
        audioOutput: AudioOutput {}                   // 必须，否则无法初始化
        loops: 1                                       // 只播放一次

        // 监听媒体状态变化（播放结束）
        onMediaStatusChanged: {
            if (mediaStatus === MediaPlayer.EndOfMedia) {
                console.log("视频播放完成，释放资源")
                mediaPlayer.source = ""   // 释放视频文件
                // 如果外层需要关闭 LightBox，可调用 close()
                // close()   // 取消注释以关闭父级弹窗
            }
        }

        // 可选：播放错误处理
        onErrorOccurred: function(error, errorString) {
            console.error("视频播放错误:", error, errorString)
        }
    }

    // 组件加载后自动播放
    Component.onCompleted: {
        mediaPlayer.play()
    }
}
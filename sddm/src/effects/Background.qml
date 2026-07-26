import QtQuick 2.15
import QtMultimedia

Item {
    id: background
    anchors.fill: parent

    property var config: ({})
    property color fallbackColor: "#000000"
    property alias imageItem: backgroundImage

    readonly property string requestedPath: (config.Background && config.Background !== "") ? String(config.Background) : ""
    readonly property string fallbackPath: "backgrounds/default.jpg"
    property string activePath: requestedPath || fallbackPath
    property bool fallbackTried: false

    readonly property string backgroundExtension: activePath !== "" ? activePath.split(".").pop().toLowerCase() : ""
    readonly property bool hasBackground: activePath !== ""
    readonly property bool isVideo: ["avi", "mp4", "mov", "mkv", "m4v", "webm"].indexOf(backgroundExtension) !== -1
    readonly property bool isAnimatedImage: ["gif", "webp"].indexOf(backgroundExtension) !== -1
    readonly property bool isStaticImage: hasBackground && !isVideo && !isAnimatedImage
    readonly property url backgroundUrl: hasBackground ? Qt.resolvedUrl("../../" + activePath) : ""

    function useFallback() {
        if (!fallbackTried && activePath !== fallbackPath) {
            fallbackTried = true;
            activePath = fallbackPath;
        }
    }

    onRequestedPathChanged: {
        fallbackTried = false;
        activePath = requestedPath || fallbackPath;
    }

    Rectangle {
        anchors.fill: parent
        color: background.fallbackColor
    }

    Image {
        id: backgroundImage
        anchors.fill: parent

        source: background.isStaticImage ? background.backgroundUrl : ""
        asynchronous: false
        cache: true
        clip: true
        mipmap: false

        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignVCenter
        fillMode: Image.PreserveAspectCrop
        visible: background.isStaticImage && status === Image.Ready

        onStatusChanged: {
            if (status === Image.Error)
                background.useFallback();
        }
    }

    AnimatedImage {
        id: animatedBackground
        anchors.fill: parent

        source: background.isAnimatedImage ? background.backgroundUrl : ""
        fillMode: Image.PreserveAspectCrop
        playing: background.isAnimatedImage
        visible: background.isAnimatedImage && status === AnimatedImage.Ready

        onStatusChanged: {
            if (status === AnimatedImage.Error)
                background.useFallback();
        }
    }

    VideoOutput {
        id: videoOutput
        anchors.fill: parent
        visible: background.isVideo
        fillMode: VideoOutput.PreserveAspectCrop
    }

    MediaPlayer {
        id: player
        videoOutput: videoOutput
        autoPlay: background.isVideo
        loops: -1
        source: background.isVideo ? background.backgroundUrl : ""

        onErrorOccurred: background.useFallback()
        onMediaStatusChanged: {
            if (mediaStatus === MediaPlayer.InvalidMedia)
                background.useFallback();
        }
    }
}

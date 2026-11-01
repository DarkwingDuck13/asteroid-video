import QtQuick
import QtMultimedia

Item {
    id: root
    width: 400
    height: 400

    property int index: 0
    property bool showStats: true
    property int fps: 0
    property int frameCount: 0
    property string lastError: ""
    property string keepAliveState: "off"
    readonly property bool hasFiles: videoFiles.length > 0
    readonly property bool playing: player.playbackState === MediaPlayer.PlayingState

    function play(i) {
        if (!hasFiles) return;
        index = (i + videoFiles.length) % videoFiles.length;
        lastError = "";
        player.play();
    }
    function next() { play(index + 1); }
    function prev() { play(index - 1); }
    function togglePause() {
        if (playing) player.pause(); else player.play();
    }
    function fileName(url) {
        var s = url.toString();
        return s.substring(s.lastIndexOf("/") + 1);
    }
    function clock(ms) {
        var s = Math.floor(ms / 1000);
        var m = Math.floor(s / 60);
        s = s % 60;
        return m + ":" + (s < 10 ? "0" : "") + s;
    }

    Rectangle { anchors.fill: parent; color: "black" }

    MediaPlayer {
        id: player
        source: root.hasFiles ? videoFiles[root.index] : ""
        videoOutput: video
        audioOutput: AudioOutput { }
        onErrorOccurred: function(error, errorString) { root.lastError = errorString }
        onMediaStatusChanged: {
            if (mediaStatus === MediaPlayer.EndOfMedia) root.next();
        }
    }

    VideoOutput {
        id: video
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectCrop
    }

    // Frames per second that actually reach the screen
    Connections {
        target: video.videoSink
        function onVideoFrameChanged() { root.frameCount++; }
    }
    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: { root.fps = root.frameCount; root.frameCount = 0; }
    }

    // Keep the display awake while playing. Nemo.KeepAlive 1.1 must be imported
    // WITH the version on Qt6, otherwise DisplayBlanking silently does nothing.
    property var blanker: null
    Component.onCompleted: {
        try {
            blanker = Qt.createQmlObject(
                'import QtQuick; import Nemo.KeepAlive 1.1; Item { property bool active: false; onActiveChanged: DisplayBlanking.preventBlanking = active }',
                root, "keepalive");
            keepAliveState = "on";
        } catch (e) {
            keepAliveState = "missing";
        }
        if (hasFiles) player.play();
    }
    onPlayingChanged: { if (blanker) blanker.active = playing; }

    MouseArea {
        anchors.fill: parent
        property real startX: 0
        property bool held: false
        onPressed: function(m) { startX = m.x; held = false; }
        onPressAndHold: { held = true; root.showStats = !root.showStats; }
        onReleased: function(m) {
            if (held) return;
            var d = m.x - startX;
            if (d < -60) root.next();
            else if (d > 60) root.prev();
            else root.togglePause();
        }
    }

    // Stats overlay (long-press to hide or show)
    Column {
        visible: root.showStats || !root.hasFiles
        anchors.centerIn: parent
        width: parent.width * 0.62
        spacing: 3

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAnywhere
            maximumLineCount: 2
            elide: Text.ElideRight
            color: "#ffffff"
            font.pixelSize: 14
            font.bold: true
            style: Text.Outline
            styleColor: "#000000"
            text: root.hasFiles ? root.fileName(videoFiles[root.index]) : "No videos found"
        }
        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            color: "#ffffff"
            font.pixelSize: 12
            style: Text.Outline
            styleColor: "#000000"
            text: root.hasFiles
                ? (root.fps + " fps  " + video.sourceRect.width + "x" + video.sourceRect.height
                   + "\n" + root.clock(player.position) + " / " + root.clock(player.duration)
                   + "\nkeepalive: " + root.keepAliveState)
                : ("Put files in " + videoDir)
        }
        Text {
            visible: root.lastError.length > 0
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            color: "#ff8080"
            font.pixelSize: 11
            style: Text.Outline
            styleColor: "#000000"
            text: root.lastError
        }
        Text {
            visible: !root.playing || !root.hasFiles
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            color: "#bbbbbb"
            font.pixelSize: 10
            style: Text.Outline
            styleColor: "#000000"
            text: decoderInfo
        }
    }
}

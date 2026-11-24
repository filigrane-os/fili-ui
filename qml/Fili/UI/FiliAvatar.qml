// Round picture of a person or a conversation: the initial on a disc until the picture is loaded, or when there is none.
// The picture is drawn into a circle by a Canvas, not by a shader mask: shader effects draw nothing with software rendering (the
// Filigrane session), where a MultiEffect mask would leave the corners of the square picture. Cropped to the middle.
import QtQuick

Item {
    id: av
    property string name
    property url source
    property int size: 32
    readonly property bool loaded: canvas.ready

    implicitWidth: size
    implicitHeight: size
    Accessible.role: Accessible.Graphic
    Accessible.name: name

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: FiliTheme.surfaceActive
        Text {
            anchors.centerIn: parent
            text: av.name.trim().charAt(0).toUpperCase()
            textFormat: Text.PlainText
            font.family: FiliTheme.font
            font.pixelSize: Math.round(av.size * 0.42)
            font.weight: FiliTheme.weightAccent
            color: FiliTheme.textSecondary
        }
    }
    // Only to know the size of the picture (the Canvas cannot tell)
    Image {
        id: probe
        visible: false
        asynchronous: true
        source: av.source
        onStatusChanged: if (status === Image.Ready) canvas.load()
    }
    Canvas {
        id: canvas
        anchors.fill: parent
        property bool ready: false
        visible: ready
        function load() {
            ready = false;
            if (av.source == "")
                return;
            unloadImage(av.source);
            loadImage(av.source);
            // The probe has already read the picture, so the Canvas finds it in the cache and never says imageLoaded
            if (isImageLoaded(av.source)) {
                ready = true;
                requestPaint();
            }
        }
        onImageLoaded: {
            ready = true;
            requestPaint();
        }
        onPaint: {
            const c = getContext("2d");
            c.reset();
            if (!ready || probe.implicitWidth <= 0)
                return;
            c.beginPath();
            c.arc(width / 2, height / 2, width / 2, 0, 2 * Math.PI);
            c.clip();
            const w = probe.implicitWidth, h = probe.implicitHeight, s = Math.min(w, h);
            c.drawImage(av.source, (w - s) / 2, (h - s) / 2, s, s, 0, 0, width, height);
        }
    }
    onSourceChanged: canvas.ready = false
}

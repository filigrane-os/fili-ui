// Toolbar icon button: hover surfaceHover, pressed surfaceActive, disabled muted. Merges the four variants found in the
// applications: font glyph (`glyph`, `size`), toggle state, accent band (`accented` + `ink`), accessible name (`tip`).
// The hover label is NOT drawn here: Qt Quick Controls' ToolTip costs ~3 MB per window process. The window draws it
// (`showTip(item, text)` / `hideTip(item)` on the Window), as fili-term does; `hint` is the key shown after the name.
// A line icon (`name`, FiliIcon) or a font glyph (`glyph`).
import QtQuick
import QtQuick.Window

Rectangle {
    id: b
    property string glyph
    property int size: 14
    // A line icon of the kit (FiliIcon, `name` is one of its keys) instead of a font glyph; `filled` also fills the shape
    // (starred), `iconSize` is its size
    property string name
    property bool filled: false
    property int iconSize: 16
    property string tip
    property string hint
    property bool enabledState: true
    property bool toggled: false
    // On a band in the accent colour (the header while the window waits for the user): ink is the text colour to use
    property bool accented: false
    property color ink: FiliTheme.text
    readonly property bool containsMouse: area.containsMouse
    signal clicked()

    implicitWidth: 28
    implicitHeight: 24
    radius: FiliTheme.radiusControl
    color: !enabledState ? "transparent" : accented ? (area.pressed || toggled || area.containsMouse ? FiliTheme.alpha(ink, 0.2) : "transparent") : area.pressed || toggled ? FiliTheme.surfaceActive : area.containsMouse ? FiliTheme.surfaceHover : "transparent"
    activeFocusOnTab: false
    Accessible.role: Accessible.Button
    Accessible.name: tip

    FiliIcon {
        visible: b.name !== ""
        anchors.centerIn: parent
        name: b.name
        filled: b.filled
        size: b.iconSize
        color: b.accented ? b.ink : b.enabledState ? FiliTheme.text : FiliTheme.muted
    }
    Text {
        visible: b.name === ""
        anchors.centerIn: parent
        text: b.glyph
        font.family: FiliTheme.icons
        font.pixelSize: b.size
        color: b.accented ? b.ink : b.enabledState ? FiliTheme.text : FiliTheme.muted
    }
    Timer {
        id: tipTimer
        interval: 450
        onTriggered: {
            const w = b.Window.window;
            if (w && w.showTip && b.tip !== "")
                w.showTip(b, b.hint !== "" ? b.tip + "   " + b.hint : b.tip);
        }
    }
    function hideTip() {
        tipTimer.stop();
        const w = b.Window.window;
        if (w && w.hideTip)
            w.hideTip(b);
    }
    onVisibleChanged: if (!visible) hideTip()
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onContainsMouseChanged: containsMouse ? tipTimer.restart() : b.hideTip()
        onPressed: b.hideTip()
        onClicked: if (b.enabledState) b.clicked()
    }
}

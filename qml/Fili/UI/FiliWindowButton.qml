// The "Window" button of a header, at the far right next to the close button (28 x 24): one click toggles the maximized column
// (niri's Mod+F, `maximize-column`; outside niri Qt's maximize), and the glyph shows the state: a plain square, or a square with
// a bar down its middle once maximized. Resting the pointer on it for `hoverDelay` (1 s) opens the window panel, a right click opens
// it at once.
// Use: FiliWindowButton { panel: windowPanel; anchors { right: closeButton.left; … } } next to a FiliWindowPanel.
import QtQuick
import QtQuick.Window

Rectangle {
    id: b
    // The FiliWindowPanel this button opens
    property FiliWindowPanel panel
    property color ink: FiliTheme.text
    property color hoverColor: FiliTheme.hoverFill
    property color pressedColor: FiliTheme.selectionPressed
    property int hoverDelay: 1000
    readonly property bool niri: FiliHost.backend.windowControl()
    property bool maximized: false

    function refresh() {
        const w = Window.window;
        maximized = niri ? FiliHost.backend.windowState().split(",").includes("maximize-column") : !!w && w.visibility === Window.Maximized;
    }
    function toggle() {
        hover.stop();
        if (panel && panel.visible)
            panel.close();
        if (niri) {
            FiliHost.backend.windowAction("maximize-column");
        } else if (Window.window) {
            const w = Window.window;
            w.visibility = w.visibility === Window.Maximized ? Window.Windowed : Window.Maximized;
        }
        settle.restart();
    }

    width: 28
    height: 24
    radius: FiliTheme.radiusControl
    color: area.pressed ? pressedColor : area.containsMouse || (panel && panel.visible) ? hoverColor : "transparent"
    Accessible.role: Accessible.Button
    Accessible.name: maximized ? FiliHost.tr("Restore the width") : FiliHost.tr("Maximize the column")
    Component.onCompleted: refresh()
    // The state changes from outside too (the key, the panel): follow the size of the window
    Connections {
        target: b.Window.window
        function onWidthChanged() { settle.restart(); }
        function onVisibilityChanged() { settle.restart(); }
    }
    Timer { id: settle; interval: 150; onTriggered: b.refresh() }
    Timer {
        id: hover
        interval: b.hoverDelay
        onTriggered: if (b.panel && !b.panel.visible) b.panel.open()
    }
    WindowGlyph {
        anchors.centerIn: parent
        kind: b.maximized ? "window-maximized" : "window"
        width: 16
        height: 16
        color: b.ink
    }
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onEntered: { b.refresh(); hover.restart(); }
        onExited: hover.stop()
        onClicked: e => {
            if (e.button === Qt.RightButton && b.panel) {
                hover.stop();
                b.panel.open();
            } else {
                b.toggle();
            }
        }
    }
}

// Text button (toolbars, status bar, confirmation): hover surfaceHover, pressed surfaceActive. Reachable with Tab,
// activated by Return, Enter or Space (the superset of the variants found in the applications).
// primary: text in accentColor (default action).
import QtQuick

Rectangle {
    id: b
    property string label
    property bool primary: false
    property bool enabledState: true
    signal clicked()

    implicitWidth: text.implicitWidth + 2 * FiliTheme.space3
    implicitHeight: 22
    radius: FiliTheme.radiusControl
    color: !enabledState ? "transparent" : area.pressed ? FiliTheme.surfaceActive : area.containsMouse ? FiliTheme.surfaceHover : "transparent"
    border.width: primary ? 1 : 0
    border.color: FiliTheme.accentColor
    activeFocusOnTab: enabledState
    Accessible.role: Accessible.Button
    Accessible.name: label
    Keys.onReturnPressed: if (enabledState) b.clicked()
    Keys.onEnterPressed: if (enabledState) b.clicked()
    Keys.onSpacePressed: if (enabledState) b.clicked()
    FocusRing {}

    Text {
        id: text
        anchors.centerIn: parent
        text: b.label
        font.family: FiliTheme.font
        font.pixelSize: FiliTheme.sizeList
        color: !b.enabledState ? FiliTheme.muted : b.primary ? FiliTheme.accentColor : FiliTheme.text
    }
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        enabled: b.enabledState
        onClicked: b.clicked()
    }
}

// Text button (toolbars, status bar, confirmation): hover surfaceHover, pressed surfaceActive. Reachable with Tab,
// activated by Return, Enter or Space (the superset of the variants found in the applications).
// primary: text in accentColor (default action). `iconName`: a FiliIcon (plus, pencil…) before the label, in the text colour; use it
// for "New" or "Add" instead of typing a "+" in the label.
import QtQuick

Rectangle {
    id: b
    property string label
    property bool primary: false
    property string iconName
    property bool enabledState: true
    signal clicked()

    implicitWidth: content.implicitWidth + 2 * FiliTheme.space3
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

    Row {
        id: content
        anchors.centerIn: parent
        spacing: FiliTheme.space1 + 2
        FiliIcon {
            visible: b.iconName !== ""
            anchors.verticalCenter: parent.verticalCenter
            name: b.iconName
            size: 14
            color: text.color
        }
        Text {
            id: text
            anchors.verticalCenter: parent.verticalCenter
            text: b.label
            font.family: FiliTheme.font
            font.pixelSize: FiliTheme.sizeList
            color: !b.enabledState ? FiliTheme.muted : b.primary ? FiliTheme.accentColor : FiliTheme.text
        }
    }
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        enabled: b.enabledState
        onClicked: b.clicked()
    }
}

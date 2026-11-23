// Back / forward capsule at the left of a header (a window with a history): 30 high, radius 8, `surface` with a 1 px
// `border`; a half greys out when it has nowhere to go.
import QtQuick

Rectangle {
    id: c
    property bool canBack: false
    property bool canForward: false
    signal back()
    signal forward()

    implicitWidth: 68
    implicitHeight: 30
    radius: 8
    color: FiliTheme.surface
    border.width: FiliTheme.borderWidth
    border.color: FiliTheme.border

    component Half: Rectangle {
        id: half
        property string glyph
        property bool active
        property string name
        signal activated()
        width: parent.width / 2
        height: parent.height
        radius: 8
        color: !active ? "transparent" : area.pressed ? FiliTheme.surfaceActive : area.containsMouse ? FiliTheme.surfaceHover : "transparent"
        Accessible.role: Accessible.Button
        Accessible.name: name
        Text {
            anchors.centerIn: parent
            text: half.glyph
            font.family: FiliTheme.font
            font.pixelSize: 18
            color: half.active ? FiliTheme.text : FiliTheme.muted
        }
        MouseArea {
            id: area
            anchors.fill: parent
            enabled: half.active
            hoverEnabled: true
            onClicked: half.activated()
        }
    }
    Half { glyph: "‹"; active: c.canBack; name: "Back"; onActivated: c.back() }
    Half { x: parent.width / 2; glyph: "›"; active: c.canForward; name: "Forward"; onActivated: c.forward() }
}

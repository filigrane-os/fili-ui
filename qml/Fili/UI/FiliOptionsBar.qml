// Options bar of an image editor (`tabBarHeight` high, under the window's top edge): the options of the current tool (children,
// left to right from `margin`), `trailing` on the right and, when `closeButton` is on, the close button at the far right as
// FiliHeader has it. Background `background`, a 1 px `border` line below. No menu is drawn: it lives in the fili-bar.
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: o
    property bool closeButton: false
    default property alias options: optionsRow.data
    property alias trailing: trailingRow.data
    signal closeRequested()

    implicitHeight: FiliTheme.tabBarHeight
    color: FiliTheme.background

    RowLayout {
        id: optionsRow
        // As wide as its options, no wider: a layout with room to spare would spread them apart
        x: FiliTheme.margin
        width: Math.min(implicitWidth, trailingRow.x - FiliTheme.margin - FiliTheme.space3)
        anchors.verticalCenter: parent.verticalCenter
        spacing: FiliTheme.space3
    }
    RowLayout {
        id: trailingRow
        anchors { right: closeRect.visible ? closeRect.left : parent.right; rightMargin: closeRect.visible ? FiliTheme.space3 : FiliTheme.margin; verticalCenter: parent.verticalCenter }
        spacing: FiliTheme.space3
    }
    Rectangle {
        id: closeRect
        visible: o.closeButton
        anchors { right: parent.right; rightMargin: (o.height - 24) / 2; verticalCenter: parent.verticalCenter }
        width: 28
        height: 24
        radius: FiliTheme.radiusControl
        color: closeArea.pressed ? FiliTheme.danger : closeArea.containsMouse ? FiliTheme.alpha(FiliTheme.danger, 0.75) : "transparent"
        Accessible.role: Accessible.Button
        Accessible.name: "Close window"
        WindowGlyph {
            anchors.centerIn: parent
            kind: "close"
            width: 16
            height: 16
            color: closeArea.containsMouse ? "#ffffff" : FiliTheme.text
        }
        MouseArea {
            id: closeArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: o.closeRequested()
        }
    }
    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: FiliTheme.borderWidth
        color: FiliTheme.border
    }
}

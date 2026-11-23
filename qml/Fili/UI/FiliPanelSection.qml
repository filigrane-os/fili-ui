// Subheading of a panel: small and muted, preceded by a thin rule unless it is the first of its view (the rule separates the
// sections from one another). `divided: false` for sections of the same block.
import QtQuick

Item {
    id: sec
    property alias text: label.text
    property bool divided: true

    implicitWidth: parent ? parent.width : 0
    implicitHeight: label.implicitHeight + (divided ? 17 : 6)

    Rectangle {
        visible: sec.divided
        anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: FiliTheme.space2 }
        height: 1
        color: FiliTheme.surfaceActive
    }
    Text {
        id: label
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        color: FiliTheme.muted
        elide: Text.ElideRight
        font.family: FiliTheme.font
        font.pixelSize: FiliTheme.sizeSmall
        font.letterSpacing: 1
    }
}

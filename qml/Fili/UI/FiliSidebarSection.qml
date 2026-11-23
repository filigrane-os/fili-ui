// Foldable section of a sidebar (accounts, Labels, Favorites, Devices…). Header of `sideRowHeight + space4` (the extra is room
// above it): fold arrow at `margin / 2` (▾ open, ▸ folded), then the title (`sizeSmall`, `weightAccent`, `muted`); hover on
// the whole header `alpha(surfaceHover, 0.5)`; a click folds or unfolds. Rows are children; folded rows are hidden, not
// disabled. `trailing` is an optional button on the right of the header (`space2` from the edge).
import QtQuick

Item {
    id: s
    property string title
    property bool folded: false
    default property alias rows: body.data
    property alias trailing: trailingRow.data

    width: parent ? parent.width : 0
    implicitHeight: head.height + body.height

    Item {
        id: head
        width: parent.width
        height: FiliTheme.sideRowHeight + FiliTheme.space4
        Rectangle {
            anchors { fill: parent; topMargin: FiliTheme.space4; leftMargin: FiliTheme.space2 + 2; rightMargin: FiliTheme.space2 + 2 }
            radius: FiliTheme.radiusControl
            color: headArea.containsMouse ? FiliTheme.alpha(FiliTheme.surfaceHover, 0.5) : "transparent"
        }
        Text {
            id: arrow
            x: FiliTheme.margin / 2
            anchors { bottom: parent.bottom; bottomMargin: (FiliTheme.sideRowHeight - height) / 2 }
            text: s.folded ? "▸" : "▾"
            font.pixelSize: FiliTheme.sizeSmall
            color: FiliTheme.muted
        }
        Text {
            anchors { left: arrow.right; leftMargin: FiliTheme.space2; right: trailingRow.left; rightMargin: FiliTheme.space2; bottom: parent.bottom; bottomMargin: (FiliTheme.sideRowHeight - height) / 2 }
            text: s.title
            elide: Text.ElideRight
            font.family: FiliTheme.font
            font.pixelSize: FiliTheme.sizeSmall
            font.weight: FiliTheme.weightAccent
            color: FiliTheme.muted
        }
        MouseArea {
            id: headArea
            anchors { fill: parent; topMargin: FiliTheme.space4 }
            hoverEnabled: true
            Accessible.role: Accessible.Button
            Accessible.name: s.title
            onClicked: s.folded = !s.folded
        }
        Row {
            id: trailingRow
            anchors { right: parent.right; rightMargin: FiliTheme.space2 + 2; bottom: parent.bottom; bottomMargin: (FiliTheme.sideRowHeight - height) / 2 }
        }
    }
    Column {
        id: body
        anchors.top: head.bottom
        width: parent.width
        visible: !s.folded
        height: s.folded ? 0 : implicitHeight
    }
}

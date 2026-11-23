// The dock of an image editor: the column of panel groups on the right of the canvas. Its left edge is a handle that resizes it
// (`minWidth` .. `maxWidth`, `dockWidth` keeps the choice); the children are FiliDockGroup, stacked, the one that sets
// `Layout.fillHeight: true` takes the rest of the height and the others keep their own. A 1 px `border` line separates the groups.
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: d
    property real dockWidth: 332
    property real minWidth: 240
    property real maxWidth: 520
    default property alias groups: column.data

    implicitWidth: Math.max(minWidth, Math.min(maxWidth, dockWidth))
    color: FiliTheme.border

    ColumnLayout {
        id: column
        anchors { fill: parent; leftMargin: FiliTheme.borderWidth }
        spacing: FiliTheme.borderWidth
    }
    // The edge: drag to resize
    MouseArea {
        id: edge
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
        width: 6
        hoverEnabled: true
        cursorShape: Qt.SizeHorCursor
        property real startX
        property real startWidth
        onPressed: e => { startX = mapToItem(null, e.x, 0).x; startWidth = d.width; }
        onPositionChanged: e => {
            if (pressed)
                d.dockWidth = Math.max(d.minWidth, Math.min(d.maxWidth, startWidth + startX - mapToItem(null, e.x, 0).x));
        }
        Rectangle { visible: edge.containsMouse || edge.pressed; anchors.fill: parent; color: FiliTheme.alpha(FiliTheme.accentColor, 0.35) }
    }
}

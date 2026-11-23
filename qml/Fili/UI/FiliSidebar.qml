// Sidebar of a window: width `sidebarWidth`, recessed `backgroundDeep`, a 1 px `border` line on its right, top padding
// `space3`. Children (FiliSidebarSection, FiliSidebarRow) are stacked and scroll with the kit's pair (KineticScroll +
// FiliScrollBar). An action tied to the sidebar goes in `actions`, just above the footer.
import QtQuick

Rectangle {
    id: sb
    default property alias content: col.data
    property alias actions: bottomRow.data

    implicitWidth: FiliTheme.sidebarWidth
    color: FiliTheme.backgroundDeep

    Rectangle {
        anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
        width: FiliTheme.borderWidth
        color: FiliTheme.border
    }
    Flickable {
        id: fl
        anchors { left: parent.left; right: parent.right; top: parent.top; bottom: bottomRow.top; topMargin: FiliTheme.space3 }
        contentHeight: col.height
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        Column {
            id: col
            width: fl.width - FiliTheme.borderWidth
        }
        KineticScroll {}
    }
    FiliScrollBar {
        flick: fl
        anchors { top: fl.top; bottom: fl.bottom; right: parent.right }
    }
    Column {
        id: bottomRow
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; bottomMargin: FiliTheme.space2 }
        leftPadding: FiliTheme.space2 + 2
        rightPadding: FiliTheme.space2 + 2
    }
}

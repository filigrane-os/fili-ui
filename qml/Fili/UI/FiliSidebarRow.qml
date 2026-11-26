// Row of a sidebar: `sideRowHeight` high, glyph (Fili Icons font) or `iconSource` at `margin`, label in `size`; the selected row
// is on `surfaceHover` with an accent label, hover is lighter; `count` (unread, items) on the right in `sizeSmall` + `muted`.
// Reachable with Tab, Return/Enter/Space = click.
import QtQuick

Item {
    id: r
    property string label
    property string glyph
    property url iconSource
    property string count
    property bool selected: false
    signal clicked()
    signal contextRequested(real x, real y)

    width: parent ? parent.width : 0
    height: FiliTheme.sideRowHeight + 4
    activeFocusOnTab: true
    Accessible.role: Accessible.ListItem
    Accessible.name: label
    Accessible.selected: selected
    Keys.onReturnPressed: { FiliHost.keyboard(); r.clicked(); }
    Keys.onEnterPressed: { FiliHost.keyboard(); r.clicked(); }
    Keys.onSpacePressed: { FiliHost.keyboard(); r.clicked(); }

    Rectangle {
        id: bg
        anchors { fill: parent; topMargin: 1; bottomMargin: 1; leftMargin: FiliTheme.space2 + 2; rightMargin: FiliTheme.space2 + 2 }
        radius: FiliTheme.radiusControl
        color: r.selected ? (area.containsMouse ? FiliTheme.selectionHover : FiliTheme.selection) : area.containsMouse ? FiliTheme.hoverFill : "transparent"
        FocusRing { gap: 0 }
    }
    Item {
        id: icon
        x: FiliTheme.margin
        anchors.verticalCenter: parent.verticalCenter
        width: 16
        height: 16
        Text {
            visible: r.glyph !== ""
            anchors.centerIn: parent
            text: r.glyph
            font.family: FiliTheme.icons
            font.pixelSize: 16
            color: r.selected ? FiliTheme.accentBright : FiliTheme.accentColor
        }
        Image {
            visible: r.glyph === "" && r.iconSource != ""
            anchors.fill: parent
            sourceSize: Qt.size(32, 32)
            source: r.iconSource
        }
    }
    Text {
        anchors { left: icon.right; leftMargin: FiliTheme.space2 + 2; right: countText.visible ? countText.left : parent.right; rightMargin: FiliTheme.space2 + 2; verticalCenter: parent.verticalCenter }
        text: r.label
        elide: Text.ElideRight
        font.family: FiliTheme.font
        font.pixelSize: FiliTheme.size
        color: FiliTheme.text
    }
    Text {
        id: countText
        visible: r.count !== ""
        anchors { right: parent.right; rightMargin: FiliTheme.space2 + 2 + FiliTheme.space2; verticalCenter: parent.verticalCenter }
        text: r.count
        font.family: FiliTheme.font
        font.pixelSize: FiliTheme.sizeSmall
        color: FiliTheme.muted
    }
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: e => {
            if (e.button === Qt.RightButton) {
                const p = area.mapToItem(null, e.x, e.y);
                r.contextRequested(p.x, p.y);
            } else {
                FiliHost.backend && (FiliHost.backend.keyNav = false);
                r.clicked();
            }
        }
    }
}

// Row of a layer list (image editors): an eye that shows or hides the layer, the name and a muted `detail` (kind, opacity).
// Same height, selection and hover as FiliSidebarRow; `depth` indents the children of a group. A hidden layer has a dimmed
// name. Tab reaches the row (Return/Enter = select) and then its eye (Space/Return = show or hide).
import QtQuick

Item {
    id: r
    property string label
    property string detail
    property int depth: 0
    property bool layerVisible: true
    property bool selected: false
    signal clicked()
    signal visibilityToggled(bool shown)

    width: parent ? parent.width : 0
    height: FiliTheme.sideRowHeight + 4
    activeFocusOnTab: true
    Accessible.role: Accessible.ListItem
    Accessible.name: label
    Accessible.selected: selected
    Keys.onReturnPressed: { FiliHost.keyboard(); r.clicked(); }
    Keys.onEnterPressed: { FiliHost.keyboard(); r.clicked(); }

    Rectangle {
        anchors { fill: parent; topMargin: 1; bottomMargin: 1; leftMargin: FiliTheme.space2 + 2; rightMargin: FiliTheme.space2 + 2 }
        radius: FiliTheme.radiusControl
        color: r.selected || area.containsMouse || eyeArea.containsMouse ? FiliTheme.surfaceHover : "transparent"
        FocusRing { gap: 0 }
    }
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: { FiliHost.backend && (FiliHost.backend.keyNav = false); r.clicked(); }
    }
    Item {
        id: eye
        x: FiliTheme.margin + r.depth * FiliTheme.space3
        anchors.verticalCenter: parent.verticalCenter
        width: 16
        height: 16
        activeFocusOnTab: true
        Accessible.role: Accessible.CheckBox
        Accessible.name: r.label
        Accessible.checked: r.layerVisible
        Keys.onSpacePressed: { FiliHost.keyboard(); r.visibilityToggled(!r.layerVisible); }
        Keys.onReturnPressed: { FiliHost.keyboard(); r.visibilityToggled(!r.layerVisible); }
        Keys.onEnterPressed: { FiliHost.keyboard(); r.visibilityToggled(!r.layerVisible); }
        FiliIcon {
            anchors.centerIn: parent
            size: 14
            name: r.layerVisible ? "eye" : "eye-off"
            color: r.layerVisible ? FiliTheme.textSecondary : FiliTheme.muted
        }
        FocusRing { gap: 2 }
        MouseArea {
            id: eyeArea
            anchors { fill: parent; margins: -4 }
            hoverEnabled: true
            onClicked: { FiliHost.backend && (FiliHost.backend.keyNav = false); r.visibilityToggled(!r.layerVisible); }
        }
    }
    Text {
        anchors { left: eye.right; leftMargin: FiliTheme.space2 + 2; right: detailText.visible ? detailText.left : parent.right; rightMargin: FiliTheme.space2 + 2; verticalCenter: parent.verticalCenter }
        text: r.label
        elide: Text.ElideRight
        font.family: FiliTheme.font
        font.pixelSize: FiliTheme.size
        color: !r.layerVisible ? FiliTheme.muted : r.selected ? FiliTheme.accentColor : FiliTheme.text
    }
    Text {
        id: detailText
        visible: r.detail !== ""
        anchors { right: parent.right; rightMargin: FiliTheme.space2 + 2 + FiliTheme.space2; verticalCenter: parent.verticalCenter }
        text: r.detail
        font.family: FiliTheme.font
        font.pixelSize: FiliTheme.sizeSmall
        color: FiliTheme.muted
    }
}

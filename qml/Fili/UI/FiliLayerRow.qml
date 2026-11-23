// Row of a layer list (image editors): an eye that shows or hides the layer, an optional `thumbnail`, the name with a muted
// `subtitle` (the kind of layer) under it, and a muted `detail` on the right (opacity). Same selection and hover as FiliSidebarRow,
// `sideRowHeight` + 4 high, taller with a subtitle or a thumbnail; `depth` indents the children of a group. A hidden layer has a dimmed
// name. Tab reaches the row (Return/Enter = select) and then its eye (Space/Return = show or hide).
import QtQuick

Item {
    id: r
    property string label
    property string detail
    property string subtitle
    property url thumbnail
    property int depth: 0
    property bool layerVisible: true
    property bool selected: false
    signal clicked()
    signal visibilityToggled(bool shown)

    width: parent ? parent.width : 0
    readonly property bool tall: subtitle !== "" || thumbnail != ""
    height: FiliTheme.sideRowHeight + (tall ? 18 : 4)
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
    // The picture of the layer, on a checkerboard so that a transparent one reads as such
    Rectangle {
        id: thumb
        visible: r.thumbnail != ""
        anchors { left: eye.right; leftMargin: FiliTheme.space2 + 2; verticalCenter: parent.verticalCenter }
        width: 32
        height: 32
        radius: 2
        color: FiliTheme.backgroundDeep
        border { width: 1; color: FiliTheme.border }
        Image { anchors { fill: parent; margins: 1 } source: r.thumbnail; fillMode: Image.PreserveAspectFit; asynchronous: true; cache: false }
    }
    Column {
        anchors { left: thumb.visible ? thumb.right : eye.right; leftMargin: FiliTheme.space2 + 2; right: detailText.visible ? detailText.left : parent.right; rightMargin: FiliTheme.space2 + 2; verticalCenter: parent.verticalCenter }
        Text {
            width: parent.width
            text: r.label
            elide: Text.ElideRight
            font.family: FiliTheme.font
            font.pixelSize: FiliTheme.size
            color: !r.layerVisible ? FiliTheme.muted : r.selected ? FiliTheme.accentColor : FiliTheme.text
        }
        Text {
            visible: r.subtitle !== ""
            width: parent.width
            text: r.subtitle
            elide: Text.ElideRight
            font.family: FiliTheme.font
            font.pixelSize: FiliTheme.sizeSmall
            color: FiliTheme.muted
        }
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

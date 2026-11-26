// Drop-down choice for a long list (chips would take several lines). model = [{label, value, off?}], current = chosen value.
// Click or Enter/Space opens the list under the button, drawn over the whole window so no scrolling page clips it; Up/Down
// move, Enter or a click chooses, Esc or a click outside closes without changing anything.
import QtQuick
import QtQuick.Window

Rectangle {
    id: sel
    property var model: []
    property var current: null
    property string placeholder
    property bool enabledState: true
    signal picked(var value)

    property bool opened: false
    property int cursor: -1
    property point origin: Qt.point(0, 0)
    readonly property int currentIndex: model.findIndex(m => String(m.value) === String(current))
    readonly property string text: currentIndex >= 0 ? model[currentIndex].label : placeholder

    // A choice (also called by the tests)
    function pick(i) {
        if (i >= 0 && i < model.length && !model[i].off)
            picked(model[i].value);
        opened = false;
    }
    function open() {
        cursor = currentIndex >= 0 ? currentIndex : model.findIndex(m => !m.off);
        origin = sel.mapToItem(pop, 0, sel.height + 2);
        opened = true;
        forceActiveFocus();
    }
    function move(d) {
        FiliHost.keyboard();
        for (let i = cursor + d; i >= 0 && i < model.length; i += d) {
            if (!model[i].off) {
                cursor = i;
                return;
            }
        }
    }

    implicitWidth: Math.max(120, label.implicitWidth + 3 * FiliTheme.space2 + 12)
    implicitHeight: 26
    radius: FiliTheme.radiusControl
    color: area.containsMouse || opened ? FiliTheme.surfaceHover : FiliTheme.surface
    border.width: FiliTheme.borderWidth
    border.color: opened ? FiliTheme.accentColor : FiliTheme.border
    opacity: enabledState ? 1 : 0.4
    activeFocusOnTab: enabledState && model.some(m => !m.off)
    Accessible.role: Accessible.ComboBox
    Accessible.name: text
    FocusRing {}
    Keys.onPressed: e => {
        if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter || e.key === Qt.Key_Space) {
            FiliHost.keyboard();
            opened ? pick(cursor) : open();
        } else if (e.key === Qt.Key_Escape && opened) {
            opened = false;
        } else if (e.key === Qt.Key_Down) {
            opened ? move(1) : open();
        } else if (e.key === Qt.Key_Up) {
            opened ? move(-1) : open();
        } else {
            return;
        }
        e.accepted = true;
    }
    Text {
        id: label
        anchors { left: parent.left; leftMargin: FiliTheme.space2; right: arrow.left; rightMargin: FiliTheme.space1; verticalCenter: parent.verticalCenter }
        text: sel.text
        elide: Text.ElideRight
        font.family: FiliTheme.font
        font.pixelSize: FiliTheme.sizeList
        color: sel.currentIndex >= 0 ? FiliTheme.text : FiliTheme.muted
    }
    Text {
        id: arrow
        anchors { right: parent.right; rightMargin: FiliTheme.space2; verticalCenter: parent.verticalCenter }
        text: "▾"
        font.pixelSize: FiliTheme.sizeSmall
        color: FiliTheme.muted
    }
    MouseArea {
        id: area
        anchors.fill: parent
        enabled: sel.enabledState
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: sel.opened ? sel.opened = false : sel.open()
    }
    // The list and the catcher of the clicks outside it, over the whole window
    Item {
        id: pop
        visible: sel.opened
        parent: sel.Window.window ? sel.Window.window.contentItem : sel
        anchors.fill: parent
        z: 1000
        MouseArea {
            anchors.fill: parent
            onClicked: sel.opened = false
        }
        Rectangle {
            x: sel.origin.x
            y: sel.origin.y
            width: Math.max(sel.width, 120)
            height: rows.height + 2 * FiliTheme.space1
            radius: FiliTheme.radiusControl
            color: FiliTheme.surface
            border.width: FiliTheme.borderWidth
            border.color: FiliTheme.border
            Column {
                id: rows
                x: FiliTheme.space1
                y: FiliTheme.space1
                width: parent.width - 2 * FiliTheme.space1
                Repeater {
                    model: sel.model
                    Rectangle {
                        required property var modelData
                        required property int index
                        width: rows.width
                        height: 26
                        radius: FiliTheme.radiusControl
                        color: index === sel.cursor ? FiliTheme.selection : rowArea.containsMouse ? FiliTheme.hoverFill : "transparent"
                        opacity: modelData.off ? 0.4 : 1
                        Text {
                            anchors { left: parent.left; leftMargin: FiliTheme.space2; right: parent.right; rightMargin: FiliTheme.space2; verticalCenter: parent.verticalCenter }
                            text: modelData.label
                            elide: Text.ElideRight
                            font.family: FiliTheme.font
                            font.pixelSize: FiliTheme.sizeList
                            font.weight: index === sel.currentIndex ? FiliTheme.weightAccent : Font.Normal
                            color: index === sel.currentIndex ? FiliTheme.accentColor : FiliTheme.text
                        }
                        MouseArea {
                            id: rowArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: sel.pick(index)
                        }
                    }
                }
            }
        }
    }
}

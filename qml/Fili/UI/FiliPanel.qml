// The fili-panel: the action card under the clicked bar item (network, sound, Bluetooth, power…), one view at a time. 340 wide,
// `space5` of padding, radius `radiusWindow`, 6 px under the item and kept inside the window. Put your content in it (sections,
// sliders, switches, panel buttons). Closes on Esc, on a click anywhere else, or when the same item is clicked again (call
// `toggle(item)`). `settingsPage` non empty shows a gear at the top right: it closes the panel and emits `settingsRequested(page)`
// (the application opens its settings there). Parent it to the window's content item.
import QtQuick

Item {
    id: panel
    property string settingsPage
    property Item item: null
    default property alias content: body.data
    readonly property bool opened: visible
    signal settingsRequested(string page)
    signal closed()

    anchors.fill: parent
    visible: false
    z: 300
    focus: visible

    function openAt(target) {
        item = target;
        visible = true;
        forceActiveFocus();
    }
    function toggle(target) {
        if (visible && item === target)
            close();
        else
            openAt(target);
    }
    function close() {
        if (!visible)
            return;
        visible = false;
        closed();
    }
    Keys.onEscapePressed: close()
    // A click elsewhere closes it (the shell closes it when the window loses the focus)
    MouseArea {
        anchors.fill: parent
        onPressed: panel.close()
    }
    Rectangle {
        id: card
        readonly property point at: panel.item ? panel.item.mapToItem(panel, panel.item.width / 2, panel.item.height) : Qt.point(0, 0)
        width: 340
        height: body.implicitHeight + 2 * FiliTheme.space5
        x: Math.max(8, Math.min(panel.width - width - 8, at.x - width / 2))
        y: at.y + 6
        color: FiliTheme.background
        border.width: FiliTheme.borderWidth
        border.color: FiliTheme.border
        radius: FiliTheme.radiusWindow
        MouseArea { anchors.fill: parent }
        Column {
            id: body
            anchors { fill: parent; margins: FiliTheme.space5 }
            spacing: FiliTheme.space3
        }
        // Gear at the top right: the settings page of the view
        Rectangle {
            id: gear
            visible: panel.settingsPage !== ""
            anchors { top: parent.top; right: parent.right; topMargin: FiliTheme.space2; rightMargin: FiliTheme.space2 }
            width: 24
            height: 24
            radius: FiliTheme.radiusControl
            color: gearArea.containsMouse ? FiliTheme.surfaceHover : "transparent"
            activeFocusOnTab: true
            Accessible.role: Accessible.Button
            Accessible.name: FiliHost.tr("Settings…")
            function press() {
                const page = panel.settingsPage;
                panel.close();
                panel.settingsRequested(page);
            }
            Keys.onReturnPressed: { FiliHost.keyboard(); press(); }
            Keys.onEnterPressed: { FiliHost.keyboard(); press(); }
            Keys.onSpacePressed: { FiliHost.keyboard(); press(); }
            FocusRing {}
            FiliIcon {
                anchors.centerIn: parent
                name: "settings"
                size: 14
                color: gearArea.containsMouse ? FiliTheme.text : FiliTheme.muted
            }
            MouseArea {
                id: gearArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: gear.press()
            }
        }
    }
}

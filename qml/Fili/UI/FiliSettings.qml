// The settings window ("Réglages"): what is set once. A card centred over the window, 640 wide: the list of pages on the left (160,
// one per module of the bar), a rule, the chosen page on the right, a close button at the top right. The frequent, instant and
// reversible settings stay in the fili-panel of their module, whose gear opens the matching page here (`open(pageId)`).
// pages = [{ id, label }, …]; the content of each page is a child with `visible: settings.page === "id"` (or use `pageItems`).
// Closes on Esc or the button, never when it loses the focus. Tab goes through the list then the page.
import QtQuick

Item {
    id: settings
    property var pages: []
    property string page: pages.length > 0 ? pages[0].id : ""
    default property alias content: pageArea.data
    readonly property bool opened: visible
    signal closed()

    anchors.fill: parent
    visible: false
    z: 320
    focus: visible

    function open(id) {
        if (id && pages.some(p => p.id === id))
            page = id;
        visible = true;
        forceActiveFocus();
    }
    function close() {
        if (!visible)
            return;
        visible = false;
        closed();
    }
    Keys.onEscapePressed: close()
    Rectangle {
        anchors.fill: parent
        color: FiliTheme.alpha(FiliTheme.backgroundDeep, 0.5)
        MouseArea { anchors.fill: parent }
    }
    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(640, parent.width - 2 * FiliTheme.margin)
        height: Math.min(560, parent.height - 2 * FiliTheme.margin)
        color: FiliTheme.background
        border.width: FiliTheme.borderWidth
        border.color: FiliTheme.border
        radius: FiliTheme.radiusWindow
        clip: true
        Column {
            id: side
            anchors { left: parent.left; top: parent.top; margins: FiliTheme.space3 }
            width: 160
            spacing: FiliTheme.space1
            Repeater {
                model: settings.pages
                FiliPanelButton {
                    required property var modelData
                    width: side.width
                    label: modelData.label
                    sel: modelData.id === settings.page
                    onClicked: settings.page = modelData.id
                }
            }
        }
        Rectangle {
            id: rule
            anchors { left: side.right; top: parent.top; bottom: parent.bottom; leftMargin: FiliTheme.space3 }
            width: 1
            color: FiliTheme.surfaceActive
        }
        // The page scrolls when it is taller than the window
        Flickable {
            id: flick
            anchors { left: rule.right; right: parent.right; top: parent.top; bottom: parent.bottom; margins: FiliTheme.space5; topMargin: 40 }
            contentWidth: width
            contentHeight: pageArea.childrenRect.height
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            KineticScroll {}
            Item {
                id: pageArea
                width: flick.width
                height: childrenRect.height
            }
        }
        FiliScrollBar { flick: flick; anchors { top: flick.top; bottom: flick.bottom; right: flick.right } }
        // Close button at the top right (a cross drawn with two bars: no glyph, no font dependency)
        Rectangle {
            id: closeBtn
            anchors { top: parent.top; right: parent.right; margins: FiliTheme.space2 }
            width: 24
            height: 24
            radius: FiliTheme.radiusControl
            color: closeArea.containsMouse ? FiliTheme.surfaceHover : "transparent"
            Accessible.role: Accessible.Button
            Accessible.name: FiliHost.tr("Close")
            Repeater {
                model: [45, -45]
                Rectangle {
                    required property int modelData
                    anchors.centerIn: parent
                    width: 12
                    height: 1.5
                    radius: 1
                    rotation: modelData
                    color: closeArea.containsMouse ? FiliTheme.text : FiliTheme.muted
                }
            }
            MouseArea {
                id: closeArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: settings.close()
            }
        }
    }
}

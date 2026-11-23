// A group of panels of an image editor's dock (Properties / Adjustments, Layers / Channels / Paths): a row of text tabs (`tabs`, the
// current one in `text` with an accent line, the others `textSecondary`), the panel menu button on the right (`menuRequested`) and
// the panel of the current tab below. Children are the panels, one per tab in order: the others are hidden, the current one fills.
import QtQuick

Rectangle {
    id: g
    property var tabs: []
    property int currentIndex: 0
    default property alias panels: body.data
    signal tabClicked(int index)
    signal menuRequested()

    implicitHeight: FiliTheme.tabBarHeight + 80
    color: FiliTheme.background

    function sync() {
        for (let i = 0; i < body.children.length; i++) {
            const c = body.children[i];
            c.visible = i === currentIndex;
            c.anchors.fill = body;
        }
    }
    onCurrentIndexChanged: sync()
    Component.onCompleted: sync()

    Item {
        id: strip
        anchors { left: parent.left; right: parent.right; top: parent.top }
        height: FiliTheme.tabHeight + FiliTheme.space2
        Row {
            anchors { left: parent.left; leftMargin: FiliTheme.space3; verticalCenter: parent.verticalCenter }
            spacing: FiliTheme.space4
            Repeater {
                model: g.tabs
                Item {
                    id: tab
                    required property string modelData
                    required property int index
                    readonly property bool current: index === g.currentIndex
                    width: label.implicitWidth
                    height: strip.height
                    activeFocusOnTab: true
                    Accessible.role: Accessible.PageTab
                    Accessible.name: modelData
                    Accessible.selected: current
                    Keys.onReturnPressed: { FiliHost.keyboard(); g.tabClicked(index); }
                    Keys.onSpacePressed: { FiliHost.keyboard(); g.tabClicked(index); }
                    FocusRing { gap: 0 }
                    Text {
                        id: label
                        anchors.verticalCenter: parent.verticalCenter
                        text: tab.modelData
                        font.family: FiliTheme.font
                        font.pixelSize: FiliTheme.size
                        color: tab.current || tabArea.containsMouse ? FiliTheme.text : FiliTheme.textSecondary
                    }
                    Rectangle {
                        visible: tab.current
                        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                        height: 2
                        color: FiliTheme.accentColor
                    }
                    MouseArea {
                        id: tabArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: { FiliHost.backend && (FiliHost.backend.keyNav = false); g.tabClicked(tab.index); }
                    }
                }
            }
        }
        Rectangle {
            id: menuButton
            anchors { right: parent.right; rightMargin: FiliTheme.space2; verticalCenter: parent.verticalCenter }
            width: 24
            height: 24
            radius: FiliTheme.radiusControl
            color: menuArea.pressed ? FiliTheme.surfaceActive : menuArea.containsMouse ? FiliTheme.surfaceHover : "transparent"
            Accessible.role: Accessible.Button
            Accessible.name: "Panel menu"
            FiliIcon { anchors.centerIn: parent; size: 14; name: "menu"; color: FiliTheme.textSecondary }
            MouseArea { id: menuArea; anchors.fill: parent; hoverEnabled: true; onClicked: g.menuRequested() }
        }
        Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: FiliTheme.borderWidth; color: FiliTheme.border }
    }
    Item {
        id: body
        anchors { left: parent.left; right: parent.right; top: strip.bottom; bottom: parent.bottom }
        clip: true
    }
}

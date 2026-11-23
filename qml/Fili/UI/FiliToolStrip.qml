// Tools of an image editor, one column (44 wide): a 32 square button per tool, separators between the groups, the current tool on
// `surfaceActive` with an accent icon, a small corner mark on a tool that hides variants (`variants`), and at the bottom the
// foreground and background colours. Model: [{ id, icon (a FiliIcon name), tip, hint, variants }, { sep: true }].
// The hover label is drawn by the window (`showTip(item, text)` / `hideTip(item)`), as FiliIconButton does.
import QtQuick
import QtQuick.Window

Rectangle {
    id: t
    property var model: []
    property string current
    property color foreground: "black"
    property color background: "white"
    property bool swatches: true
    signal picked(string id)
    signal swatchClicked(string which)

    implicitWidth: 44
    color: FiliTheme.background
    clip: true

    Rectangle { anchors { top: parent.top; bottom: parent.bottom; right: parent.right } width: FiliTheme.borderWidth; color: FiliTheme.border }

    Column {
        id: tools
        anchors { top: parent.top; topMargin: FiliTheme.space3; horizontalCenter: parent.horizontalCenter; horizontalCenterOffset: -FiliTheme.borderWidth / 2 }
        spacing: FiliTheme.space1
        Repeater {
            model: t.model
            Item {
                id: cell
                required property var modelData
                readonly property bool isSep: modelData.sep === true
                readonly property bool isCurrent: !isSep && modelData.id === t.current
                width: 32
                height: isSep ? FiliTheme.space3 + FiliTheme.borderWidth : 32
                Rectangle {
                    visible: cell.isSep
                    anchors { verticalCenter: parent.verticalCenter; left: parent.left; right: parent.right; leftMargin: 4; rightMargin: 4 }
                    height: FiliTheme.borderWidth
                    color: FiliTheme.border
                }
                Rectangle {
                    visible: !cell.isSep
                    anchors.fill: parent
                    radius: FiliTheme.radiusControl
                    color: cell.isCurrent || area.pressed ? FiliTheme.surfaceActive : area.containsMouse ? FiliTheme.surfaceHover : "transparent"
                    activeFocusOnTab: true
                    Accessible.role: Accessible.Button
                    Accessible.name: cell.modelData.tip ?? ""
                    Accessible.checked: cell.isCurrent
                    Keys.onReturnPressed: { FiliHost.keyboard(); t.picked(cell.modelData.id); }
                    Keys.onSpacePressed: { FiliHost.keyboard(); t.picked(cell.modelData.id); }
                    FocusRing { gap: 0 }
                    FiliIcon {
                        anchors.centerIn: parent
                        size: 18
                        name: cell.modelData.icon ?? ""
                        color: cell.isCurrent ? FiliTheme.accentColor : FiliTheme.text
                    }
                    // Variants of the tool (a group): the corner mark
                    Rectangle {
                        visible: cell.modelData.variants === true
                        anchors { right: parent.right; bottom: parent.bottom; rightMargin: 3; bottomMargin: 3 }
                        width: 4
                        height: 4
                        rotation: 45
                        color: FiliTheme.muted
                    }
                }
                Timer {
                    id: tip
                    interval: 450
                    onTriggered: {
                        const w = cell.Window.window;
                        if (w && w.showTip && !cell.isSep && (cell.modelData.tip ?? "") !== "")
                            w.showTip(cell, (cell.modelData.hint ?? "") !== "" ? cell.modelData.tip + "   " + cell.modelData.hint : cell.modelData.tip);
                    }
                }
                function hideTip() {
                    tip.stop();
                    const w = cell.Window.window;
                    if (w && w.hideTip)
                        w.hideTip(cell);
                }
                onVisibleChanged: if (!visible) hideTip()
                MouseArea {
                    id: area
                    anchors.fill: parent
                    enabled: !cell.isSep
                    hoverEnabled: true
                    onContainsMouseChanged: containsMouse ? tip.restart() : cell.hideTip()
                    onPressed: cell.hideTip()
                    onClicked: { FiliHost.backend && (FiliHost.backend.keyNav = false); t.picked(cell.modelData.id); }
                }
            }
        }
    }

    // Foreground over background, the way the painters know them
    Item {
        id: colours
        visible: t.swatches
        anchors { bottom: parent.bottom; bottomMargin: FiliTheme.space3; horizontalCenter: parent.horizontalCenter; horizontalCenterOffset: -FiliTheme.borderWidth / 2 }
        width: 32
        height: 32
        Rectangle {
            x: 12; y: 12; width: 18; height: 18
            color: t.background
            border { width: 1; color: FiliTheme.border }
            MouseArea { anchors.fill: parent; onClicked: t.swatchClicked("background") }
        }
        Rectangle {
            x: 2; y: 2; width: 18; height: 18
            color: t.foreground
            border { width: 1; color: FiliTheme.border }
            MouseArea { anchors.fill: parent; onClicked: t.swatchClicked("foreground") }
        }
    }
}

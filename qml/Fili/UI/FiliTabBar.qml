// Row of tabs (view filters, categories, folder tabs): a band `tabBarHeight` (40) high, `background`, a 1 px `border` line
// below; tabs `tabHeight` (28) high from `margin`, `space3` apart, `space4` of padding each side, label in `sizeList`. The
// current tab is on `surfaceActive` with `weightAccent`; the others transparent in `textSecondary`; hover `surfaceHover`. No
// underline, no border. Tabs are always reorderable: drag one over another, `reordered(from, to)` is emitted on release and
// the owner reorders its model (the order is its to keep). model = [label, …] or [{label}, …].
import QtQuick

Rectangle {
    id: bar
    property var model: []
    property int currentIndex: 0
    signal tabClicked(int index)
    signal reordered(int from, int to)

    // Drag: the tab picked up and the tab whose place it would take (-1: no drag)
    property int dragFrom: -1
    property int dragTo: -1

    implicitHeight: FiliTheme.tabBarHeight
    color: FiliTheme.background

    function labelOf(m) { return typeof m === "string" ? m : m.label; }

    Row {
        id: row
        x: FiliTheme.margin
        anchors.verticalCenter: parent.verticalCenter
        spacing: FiliTheme.space3
        Repeater {
            id: rep
            model: bar.model
            Rectangle {
                id: tab
                required property var modelData
                required property int index
                readonly property bool current: index === bar.currentIndex
                height: FiliTheme.tabHeight
                width: Math.max(60, Math.min(180, text.implicitWidth + 2 * FiliTheme.space4))
                radius: FiliTheme.radiusControl
                color: current ? FiliTheme.surfaceActive : area.containsMouse || (bar.dragFrom >= 0 && bar.dragTo === index && bar.dragTo !== bar.dragFrom) ? FiliTheme.surfaceHover : "transparent"
                opacity: bar.dragFrom === index ? 0.4 : 1
                activeFocusOnTab: true
                Accessible.role: Accessible.PageTab
                Accessible.name: bar.labelOf(modelData)
                Accessible.selected: current
                Keys.onReturnPressed: { FiliHost.keyboard(); bar.tabClicked(index); }
                Keys.onSpacePressed: { FiliHost.keyboard(); bar.tabClicked(index); }
                FocusRing { gap: 0 }
                Text {
                    id: text
                    anchors { fill: parent; leftMargin: FiliTheme.space4; rightMargin: FiliTheme.space4 }
                    verticalAlignment: Text.AlignVCenter
                    text: bar.labelOf(tab.modelData)
                    elide: Text.ElideRight
                    font.family: FiliTheme.font
                    font.pixelSize: FiliTheme.sizeList
                    font.weight: tab.current ? FiliTheme.weightAccent : Font.Normal
                    color: tab.current ? FiliTheme.text : FiliTheme.textSecondary
                }
                // Where the dragged tab would land: an accent line on the edge it would be inserted against
                Rectangle {
                    visible: bar.dragFrom >= 0 && bar.dragTo === tab.index && bar.dragTo !== bar.dragFrom
                    width: 2
                    height: parent.height
                    color: FiliTheme.accentColor
                    x: bar.dragTo < bar.dragFrom ? -FiliTheme.space3 / 2 - 1 : parent.width + FiliTheme.space3 / 2 - 1
                }
                MouseArea {
                    id: area
                    anchors.fill: parent
                    hoverEnabled: true
                    property bool reordering: false
                    property bool dragged: false
                    property real pressX: 0
                    preventStealing: reordering
                    cursorShape: reordering ? Qt.ClosedHandCursor : Qt.ArrowCursor
                    onPressed: e => { reordering = false; dragged = false; pressX = area.mapToItem(row, e.x, e.y).x; }
                    onPositionChanged: e => {
                        if (!pressed)
                            return;
                        const x = area.mapToItem(row, e.x, e.y).x;
                        if (!reordering && Math.abs(x - pressX) > 6) {
                            reordering = true;
                            bar.dragFrom = tab.index;
                        }
                        if (reordering) {
                            // The tab under the pointer, or the nearest end
                            let to = bar.model.length - 1;
                            for (let i = 0; i < rep.count; ++i) {
                                const t = rep.itemAt(i);
                                if (t && x < t.x + t.width) { to = i; break; }
                            }
                            bar.dragTo = to;
                        }
                    }
                    onReleased: {
                        if (reordering) {
                            dragged = true;
                            const from = bar.dragFrom, to = bar.dragTo;
                            reordering = false;
                            bar.dragFrom = -1;
                            bar.dragTo = -1;
                            if (from >= 0 && to >= 0 && from !== to)
                                bar.reordered(from, to);
                        }
                    }
                    onCanceled: { reordering = false; bar.dragFrom = -1; bar.dragTo = -1; }
                    onClicked: {
                        if (dragged) { dragged = false; return; }
                        FiliHost.backend && (FiliHost.backend.keyNav = false);
                        bar.tabClicked(tab.index);
                    }
                }
            }
        }
    }
    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: FiliTheme.borderWidth
        color: FiliTheme.border
    }
}

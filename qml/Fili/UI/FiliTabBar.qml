// The tab row of every Filigrane application (view filters, categories, folders, conversations): a band `tabBarHeight` (40) high,
// `background`, a 1 px `border` line below; tabs `tabHeight` (28) high from `margin`, equal widths between 80 and 180, `space3`
// apart, label in `sizeList`. The current tab is on `surfaceActive` with `weightAccent`; the others transparent in `textSecondary`;
// hover `surfaceHover`. No underline, no border.
//
// A tab can always be moved, closed and detached, the same way everywhere:
//  - move: drag it sideways, it follows the pointer and the others make room; `reordered(from, to)` on release (the owner reorders
//    its model). Keyboard: Ctrl+Shift+Left / Right.
//  - close: the × that shows on hover and on the current tab, a middle click, or Delete; `closeRequested(index)`.
//  - detach: drag it far from the bar (it turns half transparent) and release: `detachRequested(index)`, the owner makes a window of it.
//  - many tabs: below 80 each the row scrolls with the wheel (`overflows`) and keeps the current tab in view.
//  - also: `contextRequested(index, x, y)` on right click, `addRequested()` for the + button (`addable`), files dragged over a tab
//    (`tabDropped(index, drop)`; hovering one for `springDelay` ms selects it, so the target can be chosen in the view).
// model = [label, …] or [{ label, count, icon, iconColor, spin, closable }, …] (`count`: a muted figure after the label, such as unread
// messages; `icon`: the name of a FiliIcon shown before the label, in `iconColor` (a colour, `textSecondary` by default), turning
// while `spin` is true and the window is active: a command running, a conversation loading; `dots`: colours of small discs shown
// before the label, such as the platforms of a conversation).
// Tab and Left / Right choose a tab, Return or Space too.
import QtQuick
import QtQuick.Window

Rectangle {
    id: bar
    property var model: []
    property int currentIndex: 0
    property bool closable: true
    property bool detachable: true
    property bool addable: false
    property int springDelay: 700
    signal tabClicked(int index)
    signal closeRequested(int index)
    signal detachRequested(int index)
    signal reordered(int from, int to)
    signal addRequested()
    signal contextRequested(int index, real x, real y)
    signal tabDropped(int index, var drop)

    // The tab picked up and the place it would take (-1: no drag), the sideways move of the picked tab, and whether it is far
    // enough from the bar to become a window
    property int dragFrom: -1
    property int dragTo: -1
    property real dragDx: 0
    property bool leaving: false

    readonly property int count: model.length
    readonly property int addWidth: addable ? 28 + FiliTheme.space3 : 0
    // Equal widths, like Casier's tabs: the row shrinks to 80 before it overflows
    readonly property real tabWidth: Math.max(80, Math.min(180, (width - 2 * FiliTheme.margin - addWidth) / Math.max(1, count) - FiliTheme.space3))
    readonly property real slot: tabWidth + FiliTheme.space3

    // More tabs than room (each tab keeps 80 at least): the wheel scrolls the row, and the current tab is brought into view
    property real scrollX: 0
    readonly property real viewWidth: width - 2 * FiliTheme.margin
    readonly property real contentWidth: count * slot + addWidth
    readonly property bool overflows: contentWidth - FiliTheme.space3 > viewWidth + 0.5
    function clampScroll(v) { return Math.max(0, Math.min(v, Math.max(0, contentWidth - FiliTheme.space3 - viewWidth))); }
    function showCurrent() {
        if (!overflows) { scrollX = 0; return; }
        const left = currentIndex * slot, right = left + tabWidth;
        if (left < scrollX) scrollX = clampScroll(left);
        else if (right > scrollX + viewWidth) scrollX = clampScroll(right - viewWidth);
        else scrollX = clampScroll(scrollX);
    }
    onCurrentIndexChanged: showCurrent()
    onWidthChanged: showCurrent()
    onCountChanged: showCurrent()

    implicitHeight: FiliTheme.tabBarHeight
    color: FiliTheme.background

    function labelOf(m) { return typeof m === "string" ? m : m.label; }
    function countOf(m) { return typeof m === "string" ? "" : (m.count ?? ""); }
    function dotsOf(m) { return typeof m === "string" ? [] : (m.dots ?? []); }
    // A tab can opt out of closing (`closable: false`, such as the fixed categories of a mailbox)
    function closableOf(m) { return bar.closable && (typeof m === "string" || m.closable !== false); }
    function iconOf(m) { return typeof m === "string" ? "" : (m.icon ?? ""); }
    // Sideways shift of a tab that is not the picked one: it makes room for it
    function shiftOf(i) {
        if (dragFrom < 0 || i === dragFrom)
            return 0;
        if (dragFrom < i && i <= dragTo)
            return -slot;
        if (dragTo <= i && i < dragFrom)
            return slot;
        return 0;
    }

    Item {
        id: strip
        x: FiliTheme.margin
        width: parent.width - 2 * FiliTheme.margin
        height: FiliTheme.tabHeight
        anchors.verticalCenter: parent.verticalCenter
        clip: bar.overflows && bar.dragFrom < 0
        WheelHandler {
            enabled: bar.overflows
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: event => bar.scrollX = bar.clampScroll(bar.scrollX - (event.angleDelta.x !== 0 ? event.angleDelta.x : event.angleDelta.y))
        }
        Repeater {
            id: rep
            model: bar.model
            Rectangle {
                id: tab
                required property var modelData
                required property int index
                readonly property bool current: index === bar.currentIndex
                readonly property bool picked: bar.dragFrom === index
                x: index * bar.slot - bar.scrollX + (picked ? bar.dragDx : bar.shiftOf(index))
                width: bar.tabWidth
                height: FiliTheme.tabHeight
                radius: FiliTheme.radiusControl
                z: picked ? 10 : 0
                opacity: picked && bar.leaving ? 0.45 : picked ? 0.9 : 1
                color: current ? FiliTheme.surfaceActive : area.containsMouse || drop.containsDrag ? FiliTheme.surfaceHover : "transparent"
                border.width: drop.containsDrag ? 1 : 0
                border.color: FiliTheme.accentColor
                activeFocusOnTab: true
                Accessible.role: Accessible.PageTab
                Accessible.name: bar.labelOf(modelData)
                Accessible.selected: current
                Keys.onPressed: e => {
                    if (e.key === Qt.Key_Left || e.key === Qt.Key_Right) {
                        const d = e.key === Qt.Key_Left ? -1 : 1, to = index + d;
                        FiliHost.keyboard();
                        if (to >= 0 && to < bar.count) {
                            if (e.modifiers & Qt.ShiftModifier && e.modifiers & Qt.ControlModifier)
                                bar.reordered(index, to);
                            else
                                bar.tabClicked(to);
                        }
                    } else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter || e.key === Qt.Key_Space) {
                        FiliHost.keyboard();
                        bar.tabClicked(index);
                    } else if (e.key === Qt.Key_Delete && bar.closableOf(modelData)) {
                        FiliHost.keyboard();
                        bar.closeRequested(index);
                    } else {
                        return;
                    }
                    e.accepted = true;
                }
                FocusRing { gap: 0 }
                // Files dragged over a tab: they can be dropped on it; resting on it for a moment selects it. Not on the current
                // tab: that would be its own view
                DropArea {
                    id: drop
                    anchors.fill: parent
                    enabled: !tab.current
                    keys: ["text/uri-list"]
                    onEntered: spring.restart()
                    onExited: spring.stop()
                    onDropped: d => {
                        spring.stop();
                        bar.tabDropped(tab.index, d);
                    }
                    Timer {
                        id: spring
                        interval: bar.springDelay
                        onTriggered: bar.tabClicked(tab.index)
                    }
                }
                FiliIcon {
                    id: tabIcon
                    visible: name !== ""
                    anchors { left: parent.left; leftMargin: FiliTheme.space3; verticalCenter: parent.verticalCenter }
                    name: bar.iconOf(tab.modelData)
                    size: 12
                    color: typeof tab.modelData === "object" && tab.modelData.iconColor ? tab.modelData.iconColor : FiliTheme.textSecondary
                    RotationAnimator on rotation {
                        running: typeof tab.modelData === "object" && !!tab.modelData.spin && !!Window.window && Window.window.active
                        from: 0; to: 360; duration: 1400; loops: Animation.Infinite
                    }
                }
                Row {
                    id: tabDots
                    visible: bar.dotsOf(tab.modelData).length > 0
                    anchors { left: parent.left; leftMargin: FiliTheme.space3; verticalCenter: parent.verticalCenter }
                    spacing: 2
                    Repeater {
                        model: bar.dotsOf(tab.modelData)
                        Rectangle { required property string modelData; width: 8; height: 8; radius: 4; color: modelData }
                    }
                }
                Text {
                    id: label
                    anchors { left: tabDots.visible ? tabDots.right : tabIcon.visible ? tabIcon.right : parent.left; leftMargin: tabDots.visible || tabIcon.visible ? FiliTheme.space2 : FiliTheme.space4; right: countText.visible ? countText.left : closeX.left; rightMargin: FiliTheme.space1; verticalCenter: parent.verticalCenter }
                    text: bar.labelOf(tab.modelData)
                    elide: Text.ElideRight
                    font.family: FiliTheme.font
                    font.pixelSize: FiliTheme.sizeList
                    font.weight: tab.current ? FiliTheme.weightAccent : Font.Normal
                    color: tab.current ? FiliTheme.text : FiliTheme.textSecondary
                }
                Text {
                    id: countText
                    visible: text !== "" && !closeX.visible
                    anchors { right: parent.right; rightMargin: FiliTheme.space4; verticalCenter: parent.verticalCenter }
                    text: bar.countOf(tab.modelData)
                    font.family: FiliTheme.font
                    font.pixelSize: FiliTheme.sizeSmall
                    color: FiliTheme.muted
                }
                MouseArea {
                    id: area
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                    property real pressX: 0
                    property bool wasDrag: false
                    preventStealing: wasDrag
                    cursorShape: bar.dragFrom === tab.index ? Qt.ClosedHandCursor : Qt.ArrowCursor
                    // Far from the bar (above, well below it, or outside the window): the tab will become a window
                    function outside(e) {
                        const p = area.mapToItem(null, e.x, e.y), w = Window.window;
                        return p.y < -24 || p.y > bar.mapToItem(null, 0, bar.height).y + 48 || p.x < -24 || (!!w && p.x > w.width + 24);
                    }
                    onPressed: e => {
                        pressX = area.mapToItem(bar, e.x, 0).x;
                        wasDrag = false;
                    }
                    onPositionChanged: e => {
                        if (!pressed || !(pressedButtons & Qt.LeftButton))
                            return;
                        const dx = area.mapToItem(bar, e.x, 0).x - pressX;
                        if (bar.dragFrom < 0 && Math.abs(dx) < 8 && !outside(e))
                            return;
                        bar.dragFrom = tab.index;
                        wasDrag = true;
                        // Stays in the row: from the first to the last tab
                        bar.dragDx = Math.max(-tab.index * bar.slot, Math.min((bar.count - 1 - tab.index) * bar.slot, dx));
                        bar.dragTo = Math.max(0, Math.min(bar.count - 1, tab.index + Math.round(bar.dragDx / bar.slot)));
                        bar.leaving = bar.detachable && outside(e);
                    }
                    onReleased: e => {
                        if (bar.dragFrom !== tab.index)
                            return;
                        const from = bar.dragFrom, to = bar.dragTo, detach = bar.leaving;
                        bar.dragFrom = -1;
                        bar.dragTo = -1;
                        bar.dragDx = 0;
                        bar.leaving = false;
                        if (detach)
                            bar.detachRequested(from);
                        else if (to !== from)
                            bar.reordered(from, to);
                    }
                    onCanceled: {
                        bar.dragFrom = -1;
                        bar.dragTo = -1;
                        bar.dragDx = 0;
                        bar.leaving = false;
                    }
                    onClicked: e => {
                        if (wasDrag) {
                            wasDrag = false;
                            return;
                        }
                        if (e.button === Qt.MiddleButton) {
                            if (bar.closableOf(tab.modelData))
                                bar.closeRequested(tab.index);
                        } else if (e.button === Qt.RightButton) {
                            const p = area.mapToItem(null, e.x, e.y);
                            bar.contextRequested(tab.index, p.x, p.y);
                        } else {
                            FiliHost.backend && (FiliHost.backend.keyNav = false);
                            bar.tabClicked(tab.index);
                        }
                    }
                }
                // The ×: on hover and on the current tab
                Text {
                    id: closeX
                    visible: bar.closableOf(tab.modelData) && (area.containsMouse || xHit.containsMouse || tab.current)
                    anchors { right: parent.right; rightMargin: FiliTheme.space2; verticalCenter: parent.verticalCenter }
                    text: "×"
                    font.pixelSize: 16
                    color: xHit.containsMouse ? FiliTheme.danger : FiliTheme.muted
                    Accessible.role: Accessible.Button
                    Accessible.name: "Close tab"
                    MouseArea {
                        id: xHit
                        anchors { fill: parent; margins: -5 }
                        hoverEnabled: true
                        onClicked: bar.closeRequested(tab.index)
                    }
                }
            }
        }
        // The + button after the last tab
        Rectangle {
            visible: bar.addable
            x: bar.count * bar.slot - bar.scrollX
            width: 28
            height: FiliTheme.tabHeight
            radius: FiliTheme.radiusControl
            color: addArea.containsMouse ? FiliTheme.surfaceHover : "transparent"
            activeFocusOnTab: true
            Accessible.role: Accessible.Button
            Accessible.name: "New tab"
            Keys.onReturnPressed: { FiliHost.keyboard(); bar.addRequested(); }
            Keys.onSpacePressed: { FiliHost.keyboard(); bar.addRequested(); }
            FocusRing { gap: 0 }
            Text { anchors.centerIn: parent; text: "+"; font.pixelSize: 16; color: addArea.containsMouse ? FiliTheme.text : FiliTheme.muted }
            MouseArea { id: addArea; anchors.fill: parent; hoverEnabled: true; onClicked: bar.addRequested() }
        }
    }
    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: FiliTheme.borderWidth
        color: FiliTheme.border
    }
}

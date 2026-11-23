// Segmented switch of a header: n segments in a capsule (like the navigation capsule), the active one on `surfaceHover` with
// its pictogram in `accentColor`. By default two segments, list and grid, with drawn pictograms (three bars, four squares: no icon
// font): `chose("list" | "grid")`. `modes` gives another set: [{ key, icon, tip }] (`icon`: the name of a FiliIcon), such as where
// the reader goes in a mail window (automatic, right, below); `chose(key)` is emitted and the owner sets `mode`. On the accent
// band of a header that waits for the user, `accented` with `ink` (the text colour of the band) draws the capsule in tints of it.
// Reachable with Tab; Left/Right (or Space) change the mode.
import QtQuick
import QtQuick.Window

Rectangle {
    id: sw
    property string mode: "list"
    // null: list and grid; otherwise [{ key, icon, tip }, …]
    property var modes: null
    property bool accented: false
    property color ink: FiliTheme.text
    signal chose(string mode)

    readonly property var items: modes ?? [{ key: "list", tip: "View as list" }, { key: "grid", tip: "View as icons" }]
    readonly property int segmentWidth: 30

    implicitWidth: items.length * segmentWidth + 2 * FiliTheme.space1 + 2
    implicitHeight: 30
    radius: 8
    color: accented ? FiliTheme.alpha(ink, 0.12) : FiliTheme.surface
    border.width: FiliTheme.borderWidth
    border.color: accented ? FiliTheme.alpha(ink, 0.3) : FiliTheme.border
    activeFocusOnTab: true
    Accessible.role: Accessible.RadioButton
    Accessible.name: items.find(i => i.key === mode)?.tip ?? mode
    function step(d) {
        const i = items.findIndex(x => x.key === mode);
        pick(items[Math.max(0, Math.min(items.length - 1, i + d))].key);
    }
    Keys.onLeftPressed: step(-1)
    Keys.onRightPressed: step(1)
    Keys.onSpacePressed: pick(items[(items.findIndex(x => x.key === mode) + 1) % items.length].key)
    function pick(m) {
        FiliHost.keyboard();
        if (m !== mode)
            chose(m);
    }
    FocusRing { gap: 2 }

    Repeater {
        model: sw.items
        Rectangle {
            id: seg
            required property var modelData
            required property int index
            readonly property bool on: sw.mode === modelData.key
            x: FiliTheme.space1 + index * sw.segmentWidth
            anchors.verticalCenter: parent.verticalCenter
            width: sw.segmentWidth
            height: 22
            radius: FiliTheme.radiusControl
            color: on || area.containsMouse ? (sw.accented ? FiliTheme.alpha(sw.ink, 0.2) : FiliTheme.surfaceHover) : "transparent"
            readonly property color tint: sw.accented ? sw.ink : on ? FiliTheme.accentColor : FiliTheme.textSecondary
            Accessible.role: Accessible.Button
            Accessible.name: modelData.tip ?? modelData.key
            // The pictograms of the default pair
            Item {
                anchors.centerIn: parent
                width: 14
                height: 12
                visible: !seg.modelData.icon
                Repeater {
                    model: seg.modelData.key === "list" ? 3 : seg.modelData.key === "grid" ? 4 : 0
                    Rectangle {
                        required property int index
                        readonly property bool list: seg.modelData.key === "list"
                        x: list ? 0 : (index % 2) * 8
                        y: list ? index * 5 : Math.floor(index / 2) * 7
                        width: list ? 14 : 6
                        height: list ? 2 : 5
                        radius: 1
                        color: seg.tint
                    }
                }
            }
            FiliIcon {
                visible: !!seg.modelData.icon
                anchors.centerIn: parent
                name: seg.modelData.icon ?? ""
                size: 14
                color: seg.tint
            }
            // The hover label is drawn by the window (showTip / hideTip), like FiliIconButton's
            Timer {
                id: tipTimer
                interval: 450
                onTriggered: {
                    const w = seg.Window.window;
                    if (w && w.showTip && seg.modelData.tip)
                        w.showTip(seg, seg.modelData.tip);
                }
            }
            function hideTip() {
                tipTimer.stop();
                const w = seg.Window.window;
                if (w && w.hideTip)
                    w.hideTip(seg);
            }
            MouseArea {
                id: area
                anchors.fill: parent
                hoverEnabled: true
                onContainsMouseChanged: containsMouse ? tipTimer.restart() : seg.hideTip()
                onPressed: seg.hideTip()
                onClicked: {
                    FiliHost.backend && (FiliHost.backend.keyNav = false);
                    sw.pick(seg.modelData.key);
                }
            }
        }
    }
}

// List / grid switch of a header: two segments in a capsule (like the navigation capsule), the active mode on `surfaceHover` with
// its pictogram in `accentColor`. Pictograms are drawn (three bars, four squares): no icon font. `chose(mode)` is emitted with
// "list" or "grid"; the owner sets `mode`. Reachable with Tab; Left/Right (or Space) change the mode.
import QtQuick

Rectangle {
    id: sw
    property string mode: "list"
    signal chose(string mode)

    width: 2 * 30 + 2 * FiliTheme.space1 + 2
    height: 30
    radius: 8
    color: FiliTheme.surface
    border.width: FiliTheme.borderWidth
    border.color: FiliTheme.border
    activeFocusOnTab: true
    Accessible.role: Accessible.RadioButton
    Accessible.name: mode === "list" ? "View as list" : "View as icons"
    Keys.onLeftPressed: pick("list")
    Keys.onRightPressed: pick("grid")
    Keys.onSpacePressed: pick(mode === "list" ? "grid" : "list")
    function pick(m) {
        FiliHost.keyboard();
        if (m !== mode)
            chose(m);
    }
    FocusRing { gap: 2 }

    component Segment: Rectangle {
        id: seg
        required property string value
        property string name
        property bool on: sw.mode === value
        x: FiliTheme.space1 + (value === "list" ? 0 : 30)
        anchors.verticalCenter: parent.verticalCenter
        width: 30
        height: 22
        radius: FiliTheme.radiusControl
        color: on || area.containsMouse ? FiliTheme.surfaceHover : "transparent"
        readonly property color ink: on ? FiliTheme.accentColor : FiliTheme.textSecondary
        default property alias glyph: holder.data
        Accessible.role: Accessible.Button
        Accessible.name: name
        Item {
            id: holder
            anchors.centerIn: parent
            width: 14
            height: 12
        }
        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                FiliHost.backend && (FiliHost.backend.keyNav = false);
                if (seg.value !== sw.mode)
                    sw.chose(seg.value);
            }
        }
    }

    Segment {
        value: "list"
        name: "View as list"
        Repeater {
            model: 3
            Rectangle {
                required property int index
                y: index * 5
                width: 14
                height: 2
                radius: 1
                color: parent.parent.ink
            }
        }
    }
    Segment {
        value: "grid"
        name: "View as icons"
        Repeater {
            model: 4
            Rectangle {
                required property int index
                x: (index % 2) * 8
                y: Math.floor(index / 2) * 7
                width: 6
                height: 5
                radius: 1
                color: parent.parent.ink
            }
        }
    }
}

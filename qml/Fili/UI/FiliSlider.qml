// Slider 0..1 (volume, brightness): click or drag the track; Left/Right move by 5 % (one step with `steps`). `value` stays
// 0..1 along the track; `from`/`to` only change the number shown on the right (`showValue`). The owner sets `value` on
// `moved`. `released` ends a drag: apply a heavy change there, not at each `moved`.
import QtQuick

Item {
    id: s
    property real value: 0
    property real from: 0
    property real to: 1
    property bool showValue: false
    property bool enabledState: true
    // steps > 0: the value snaps to steps + 1 positions (0, 1/steps ... 1)
    property int steps: 0
    readonly property bool dragging: area.pressed
    signal moved(real v)
    signal released()

    implicitWidth: 160
    implicitHeight: 22
    opacity: enabledState ? 1 : 0.4
    activeFocusOnTab: enabledState
    Accessible.role: Accessible.Slider
    Accessible.name: String(Math.round(from + value * (to - from)))
    Keys.onLeftPressed: s.nudge(-0.05)
    Keys.onRightPressed: s.nudge(0.05)
    function snap(v) {
        v = Math.max(0, Math.min(1, v));
        return steps > 0 ? Math.round(v * steps) / steps : v;
    }
    function nudge(d) {
        FiliHost.keyboard();
        moved(snap(value + (steps > 0 ? Math.sign(d) / steps : d)));
    }
    FocusRing { gap: 4 }
    Rectangle {
        id: track
        anchors { left: parent.left; right: label.visible ? label.left : parent.right; rightMargin: label.visible ? FiliTheme.space2 : 0; verticalCenter: parent.verticalCenter }
        height: 4
        radius: 2
        color: FiliTheme.surfaceActive
        Rectangle {
            width: knob.x + knob.width / 2
            height: parent.height
            radius: 2
            color: FiliTheme.accentColor
        }
        Rectangle {
            id: knob
            x: s.value * (track.width - width)
            anchors.verticalCenter: parent.verticalCenter
            width: 14
            height: 14
            radius: 7
            color: FiliTheme.text
            border.width: FiliTheme.borderWidth
            border.color: FiliTheme.border
        }
    }
    Text {
        id: label
        visible: s.showValue
        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
        width: 36
        horizontalAlignment: Text.AlignRight
        text: Math.round(s.from + s.value * (s.to - s.from))
        font.family: FiliTheme.font
        font.pixelSize: FiliTheme.sizeList
        color: FiliTheme.textSecondary
    }
    MouseArea {
        id: area
        anchors { left: track.left; right: track.right; top: parent.top; bottom: parent.bottom }
        enabled: s.enabledState
        cursorShape: Qt.PointingHandCursor
        function at(x) {
            s.moved(s.snap((x - knob.width / 2) / (track.width - knob.width)));
        }
        onPressed: e => { s.forceActiveFocus(); at(e.x); }
        onPositionChanged: e => { if (pressed) at(e.x); }
        onReleased: s.released()
    }
}

// Progress of an operation, 0..1 (footer, dialogs). `indeterminate`: a moving block when the end is unknown (the only
// animation here, and only while it runs).
import QtQuick

Rectangle {
    id: p
    property real value: 0
    property bool indeterminate: false

    implicitWidth: 160
    implicitHeight: 4
    radius: height / 2
    color: FiliTheme.surfaceActive
    clip: true
    Accessible.role: Accessible.ProgressBar
    Rectangle {
        id: bar
        height: parent.height
        radius: parent.radius
        color: FiliTheme.accentColor
        width: p.indeterminate ? parent.width * 0.3 : parent.width * Math.max(0, Math.min(1, p.value))
        NumberAnimation on x {
            running: p.indeterminate && p.visible
            from: -bar.width
            to: p.width
            duration: 1100
            loops: Animation.Infinite
        }
    }
}

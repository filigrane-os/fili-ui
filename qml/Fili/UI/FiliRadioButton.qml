// Radio button: one choice among a few that are all shown. The owner sets `checked` on `clicked` (a group is the owner's
// business: `checked: choice === "x"`).
import QtQuick

Item {
    id: r
    property bool checked: false
    property string label
    property bool enabledState: true
    signal clicked()

    implicitWidth: dot.width + FiliTheme.space2 + text.implicitWidth
    implicitHeight: 22
    opacity: enabledState ? 1 : 0.4
    activeFocusOnTab: enabledState
    Accessible.role: Accessible.RadioButton
    Accessible.name: label
    Accessible.checked: checked
    Keys.onSpacePressed: { FiliHost.keyboard(); r.press(); }
    Keys.onReturnPressed: { FiliHost.keyboard(); r.press(); }
    function press() {
        if (enabledState && !checked)
            clicked();
    }
    FocusRing { gap: 3 }
    Rectangle {
        id: dot
        width: 16
        height: 16
        anchors.verticalCenter: parent.verticalCenter
        radius: 8
        color: "transparent"
        border.width: FiliTheme.borderWidth
        border.color: r.checked ? FiliTheme.accentColor : FiliTheme.muted
        Rectangle {
            visible: r.checked
            anchors.centerIn: parent
            width: 8
            height: 8
            radius: 4
            color: FiliTheme.accentColor
        }
    }
    Text {
        id: text
        anchors { left: dot.right; leftMargin: FiliTheme.space2; verticalCenter: parent.verticalCenter }
        text: r.label
        font.family: FiliTheme.font
        font.pixelSize: FiliTheme.size
        color: FiliTheme.text
    }
    MouseArea {
        anchors.fill: parent
        enabled: r.enabledState
        cursorShape: Qt.PointingHandCursor
        onClicked: r.press()
    }
}

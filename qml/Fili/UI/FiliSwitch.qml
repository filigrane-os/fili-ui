// On/off switch for a setting that applies at once. checked = on; switchable = false greys it out (nothing to turn on).
// `toggled` is emitted on a click or Enter/Space: the owner flips `checked` (the switch never changes its own state).
import QtQuick

Rectangle {
    id: sw
    property bool checked: false
    property bool switchable: true
    property string label
    signal toggled()

    implicitWidth: 34
    implicitHeight: 18
    radius: height / 2
    opacity: switchable ? 1 : 0.4
    color: checked ? FiliTheme.accentColor : FiliTheme.surfaceActive
    activeFocusOnTab: switchable
    Accessible.role: Accessible.CheckBox
    Accessible.name: label
    Accessible.checked: checked
    Keys.onReturnPressed: key()
    Keys.onEnterPressed: key()
    Keys.onSpacePressed: key()
    function key() {
        FiliHost.keyboard();
        press();
    }
    // A click (also called by the tests)
    function press() {
        if (switchable)
            toggled();
    }
    FocusRing { gap: 3 }
    Rectangle {
        x: sw.checked ? parent.width - width - 2 : 2
        anchors.verticalCenter: parent.verticalCenter
        width: 14
        height: 14
        radius: 7
        color: sw.checked ? FiliTheme.background : FiliTheme.text
    }
    MouseArea {
        anchors.fill: parent
        enabled: sw.switchable
        cursorShape: Qt.PointingHandCursor
        onClicked: sw.press()
    }
}

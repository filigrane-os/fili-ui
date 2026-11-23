// Check box with its label on the right, aligned left like every choice control. The owner flips `checked` on `toggled`.
import QtQuick

Item {
    id: c
    property bool checked: false
    property string label
    property bool enabledState: true
    signal toggled()

    implicitWidth: box.width + FiliTheme.space2 + text.implicitWidth
    implicitHeight: 22
    opacity: enabledState ? 1 : 0.4
    activeFocusOnTab: enabledState
    Accessible.role: Accessible.CheckBox
    Accessible.name: label
    Accessible.checked: checked
    Keys.onSpacePressed: { FiliHost.keyboard(); c.press(); }
    Keys.onReturnPressed: { FiliHost.keyboard(); c.press(); }
    function press() {
        if (enabledState)
            toggled();
    }
    FocusRing { gap: 3 }
    Rectangle {
        id: box
        width: 16
        height: 16
        anchors.verticalCenter: parent.verticalCenter
        radius: FiliTheme.radiusMark + 1
        color: c.checked ? FiliTheme.accentColor : "transparent"
        border.width: FiliTheme.borderWidth
        border.color: c.checked ? FiliTheme.accentColor : FiliTheme.muted
        // The tick, drawn with two bars so that no icon font is needed
        Item {
            visible: c.checked
            anchors.centerIn: parent
            width: 10
            height: 8
            Rectangle { x: 0; y: 4; width: 5; height: 2; radius: 1; rotation: 45; color: FiliTheme.background; transformOrigin: Item.Left }
            Rectangle { x: 3.5; y: 6; width: 8; height: 2; radius: 1; rotation: -50; color: FiliTheme.background; transformOrigin: Item.Left }
        }
    }
    Text {
        id: text
        anchors { left: box.right; leftMargin: FiliTheme.space2; verticalCenter: parent.verticalCenter }
        text: c.label
        font.family: FiliTheme.font
        font.pixelSize: FiliTheme.size
        color: FiliTheme.text
    }
    MouseArea {
        anchors.fill: parent
        enabled: c.enabledState
        cursorShape: Qt.PointingHandCursor
        onClicked: c.press()
    }
}

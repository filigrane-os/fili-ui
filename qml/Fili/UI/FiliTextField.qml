// Text field: placeholder in `muted` (an example, never the only label), accent border on focus. `clearable` shows a × as
// soon as there is text: a click clears the field, as does Esc (every search or filter field has it). `accepted` on Enter.
import QtQuick

Rectangle {
    id: f
    property alias text: input.text
    property string placeholder
    property bool clearable: false
    property bool enabledState: true
    property bool error: false
    readonly property bool hasFocus: input.activeFocus
    signal accepted()
    signal cleared()

    implicitWidth: 180
    implicitHeight: 26
    radius: FiliTheme.radiusControl
    color: FiliTheme.surface
    opacity: enabledState ? 1 : 0.4
    border.width: FiliTheme.borderWidth
    border.color: error ? FiliTheme.danger : input.activeFocus ? FiliTheme.accentColor : FiliTheme.border
    Accessible.role: Accessible.EditableText
    Accessible.name: placeholder

    function clear() {
        input.text = "";
        cleared();
    }
    function focusField() { input.forceActiveFocus(); }

    TextInput {
        id: input
        anchors { left: parent.left; right: x.visible ? x.left : parent.right; leftMargin: FiliTheme.space2; rightMargin: FiliTheme.space1; verticalCenter: parent.verticalCenter }
        enabled: f.enabledState
        clip: true
        font.family: FiliTheme.font
        font.pixelSize: FiliTheme.sizeList
        color: FiliTheme.text
        selectionColor: FiliTheme.accentColor
        selectedTextColor: FiliTheme.background
        selectByMouse: true
        activeFocusOnTab: true
        onAccepted: f.accepted()
        Keys.onEscapePressed: e => {
            if (f.clearable && text !== "")
                f.clear();
            else
                e.accepted = false;
        }
        Text {
            visible: input.text === "" && !input.preeditText
            anchors.verticalCenter: parent.verticalCenter
            text: f.placeholder
            font: input.font
            color: FiliTheme.muted
        }
    }
    Text {
        id: x
        visible: f.clearable && input.text !== ""
        anchors { right: parent.right; rightMargin: FiliTheme.space2; verticalCenter: parent.verticalCenter }
        text: "✕"
        font.pixelSize: FiliTheme.sizeSmall
        color: clearArea.containsMouse ? FiliTheme.text : FiliTheme.muted
        Accessible.role: Accessible.Button
        Accessible.name: "Clear"
        MouseArea {
            id: clearArea
            anchors { fill: parent; margins: -6 }
            hoverEnabled: true
            onClicked: { f.clear(); input.forceActiveFocus(); }
        }
    }
}

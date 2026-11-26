// Text field: placeholder in `muted` (an example, never the only label), accent border on focus. `clearable` shows a × as
// soon as there is text: a click clears the field, as does Esc (every search or filter field has it). `accepted` on Enter.
// `suggestions` (strings, or {label, detail, value}: `value` is what the field gets when it differs from the label) show in a list under the field while it has the focus (a place, an address,
// a contact): ↑ ↓ move in it, Enter or a click takes one (the field gets its label, `suggestionPicked(item)`), Esc closes it.
// The owner fills the list (as the user types: `textEdited`) and empties it when it has nothing to offer.
import QtQuick
import QtQuick.Window

Rectangle {
    id: f
    property alias text: input.text
    property string placeholder
    property bool clearable: false
    property bool enabledState: true
    property bool error: false
    // Dots instead of the text (passwords); the × stays off
    property bool secret: false
    // Shown but not editable (an address); the keyboard hints of the field (an e-mail address, digits); the field Tab goes to
    property bool readOnly: false
    property int inputMethodHints: Qt.ImhNone
    property Item tabNext: null
    readonly property bool hasFocus: input.activeFocus
    signal accepted()
    signal cleared()
    signal textEdited()
    property var suggestions: []
    signal suggestionPicked(var item)
    property int suggestion: -1
    readonly property bool suggesting: suggestions.length > 0 && input.activeFocus
    onSuggestionsChanged: suggestion = -1
    function labelOf(item) { return typeof item === "string" ? item : item.label; }
    function pick(i) {
        const item = suggestions[i];
        input.text = typeof item === "string" ? item : item.value || item.label;
        suggestions = [];
        suggestionPicked(item);
    }

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
    function selectAll() { input.selectAll(); }
    // Gives up the keyboard focus (Esc in a filter that hands the keys back to the list)
    function blurField() { input.focus = false; }

    TextInput {
        id: input
        anchors { left: parent.left; right: x.visible ? x.left : parent.right; leftMargin: FiliTheme.space2; rightMargin: FiliTheme.space1; verticalCenter: parent.verticalCenter }
        enabled: f.enabledState
        clip: true
        font.family: FiliTheme.font
        font.pixelSize: FiliTheme.sizeList
        color: FiliTheme.text
        selectionColor: FiliTheme.selectionText
        selectedTextColor: FiliTheme.text
        selectByMouse: true
        readOnly: f.readOnly
        inputMethodHints: f.inputMethodHints
        KeyNavigation.tab: f.tabNext
        echoMode: f.secret ? TextInput.Password : TextInput.Normal
        activeFocusOnTab: true
        onAccepted: f.accepted()
        onTextEdited: f.textEdited()
        Keys.onDownPressed: e => { if (f.suggesting) f.suggestion = (f.suggestion + 1) % f.suggestions.length; else e.accepted = false; }
        Keys.onUpPressed: e => { if (f.suggesting) f.suggestion = f.suggestion <= 0 ? f.suggestions.length - 1 : f.suggestion - 1; else e.accepted = false; }
        Keys.onReturnPressed: e => { if (f.suggesting && f.suggestion >= 0) f.pick(f.suggestion); else e.accepted = false; }
        Keys.onEnterPressed: e => { if (f.suggesting && f.suggestion >= 0) f.pick(f.suggestion); else e.accepted = false; }
        Keys.onEscapePressed: e => {
            if (f.suggesting)
                f.suggestions = [];
            else if (f.clearable && text !== "")
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
        visible: f.clearable && !f.secret && input.text !== ""
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
    // The list of suggestions, over the whole window (a dialog or a card does not clip it)
    Item {
        id: pop
        visible: f.suggesting
        parent: f.Window.window ? f.Window.window.contentItem : f
        anchors.fill: parent
        z: 1000
        property point origin: Qt.point(0, 0)
        onVisibleChanged: if (visible) origin = f.mapToItem(pop, 0, f.height + 2)
        Rectangle {
            x: pop.origin.x
            y: pop.origin.y
            width: Math.max(f.width, 200)
            height: rows.height + 2 * FiliTheme.space1
            radius: FiliTheme.radiusControl
            color: FiliTheme.surface
            border.width: FiliTheme.borderWidth
            border.color: FiliTheme.border
            Column {
                id: rows
                x: FiliTheme.space1
                y: FiliTheme.space1
                width: parent.width - 2 * FiliTheme.space1
                Repeater {
                    model: f.suggestions
                    Rectangle {
                        id: row
                        required property var modelData
                        required property int index
                        readonly property string detail: typeof row.modelData === "string" ? "" : row.modelData.detail || ""
                        width: rows.width
                        height: row.detail !== "" ? 40 : 26
                        radius: FiliTheme.radiusControl
                        color: row.index === f.suggestion ? FiliTheme.selection : rowArea.containsMouse ? FiliTheme.hoverFill : "transparent"
                        Column {
                            anchors { left: parent.left; leftMargin: FiliTheme.space2; right: parent.right; rightMargin: FiliTheme.space2; verticalCenter: parent.verticalCenter }
                            Text {
                                width: parent.width
                                text: f.labelOf(row.modelData)
                                elide: Text.ElideRight
                                font.family: FiliTheme.font
                                font.pixelSize: FiliTheme.sizeList
                                color: FiliTheme.text
                            }
                            Text {
                                visible: row.detail !== ""
                                width: parent.width
                                text: row.detail
                                elide: Text.ElideRight
                                font.family: FiliTheme.font
                                font.pixelSize: FiliTheme.sizeSmall
                                color: FiliTheme.textSecondary
                            }
                        }
                        MouseArea {
                            id: rowArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: f.pick(row.index)
                        }
                    }
                }
            }
        }
    }
}

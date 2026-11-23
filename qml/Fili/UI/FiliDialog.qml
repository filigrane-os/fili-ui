// Modal dialog: a scrim over the whole window and a centred card (radius `radiusWindow`, `space5` of padding) with a title, the
// content you put in it, and a right-aligned row with Cancel and the main action (Cancel to its left, the main action is the
// default one). Esc or a click on the scrim rejects, Enter accepts while `confirmEnabled`. `showButtons: false` makes an
// information card (About, shortcuts): any of Enter, Esc or a click closes it.
// Use: FiliDialog { title: "…"; onAccepted: … ; <content> } then open(). Parent it to the window's content item.
import QtQuick

Rectangle {
    id: dlg
    property string title
    property string confirmLabel
    property string cancelLabel
    property bool showButtons: true
    property bool showCancel: true
    property bool confirmEnabled: true
    property int cardWidth: 400
    default property alias content: body.data
    signal accepted()
    signal rejected()

    visible: false
    anchors.fill: parent
    z: 250
    color: FiliTheme.alpha(FiliTheme.backgroundDeep, 0.7)
    focus: visible

    function open() {
        visible = true;
        forceActiveFocus();
    }
    function close() { visible = false; }
    function accept() {
        if (!showButtons) {
            close();
            return;
        }
        if (!confirmEnabled)
            return;
        close();
        accepted();
    }
    function reject() {
        close();
        rejected();
    }
    Keys.onEscapePressed: reject()
    Keys.onReturnPressed: accept()
    Keys.onEnterPressed: accept()
    MouseArea {
        anchors.fill: parent
        onClicked: dlg.reject()
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(dlg.cardWidth, parent.width - 2 * FiliTheme.margin)
        height: Math.min(col.implicitHeight + 2 * FiliTheme.space5, parent.height - 2 * FiliTheme.margin)
        radius: FiliTheme.radiusWindow
        color: FiliTheme.surface
        border.width: FiliTheme.borderWidth
        border.color: FiliTheme.border
        // A click on the card is not a click on the scrim
        MouseArea { anchors.fill: parent }
        Column {
            id: col
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: FiliTheme.space5 }
            spacing: FiliTheme.space3
            Text {
                visible: dlg.title !== ""
                width: parent.width
                wrapMode: Text.Wrap
                text: dlg.title
                font.family: FiliTheme.font
                font.pixelSize: FiliTheme.size
                font.weight: FiliTheme.weightAccent
                color: FiliTheme.text
            }
            Column {
                id: body
                width: parent.width
                spacing: FiliTheme.space3
            }
            Row {
                visible: dlg.showButtons
                anchors.right: parent.right
                spacing: FiliTheme.space2
                FiliButton { visible: dlg.showCancel; label: dlg.cancelLabel !== "" ? dlg.cancelLabel : FiliHost.tr("Cancel"); onClicked: dlg.reject() }
                FiliButton { label: dlg.confirmLabel !== "" ? dlg.confirmLabel : FiliHost.tr("OK"); primary: true; enabledState: dlg.confirmEnabled; onClicked: dlg.accept() }
            }
        }
    }
}

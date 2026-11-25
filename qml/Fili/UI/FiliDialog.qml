// Modal dialog: a scrim over the whole window and a centred card (radius `radiusWindow`, `space5` of padding) with a title, the
// content you put in it, and a right-aligned row with Cancel and the main action (Cancel to its left, the main action is the
// default one). Esc or a click on the scrim rejects, Enter accepts while `confirmEnabled`. `showButtons: false` makes an
// information card (About, shortcuts): any of Enter, Esc or a click closes it. Every dialog has a × at the top right
// (`closeButton`, on by default; it rejects) so the way out is always visible. Extra actions (Join Teams…) go in `actions`:
// they sit left of Cancel (`showConfirm: false` hides the main action, Enter then just closes), with `space4` more than the
// usual gap between the content and the buttons.
// Use: FiliDialog { title: "…"; onAccepted: … ; <content> } then open(). Parent it to the window's content item.
import QtQuick

Rectangle {
    id: dlg
    property string title
    property string confirmLabel
    property string cancelLabel
    property bool showButtons: true
    property bool showCancel: true
    property bool showConfirm: true
    property bool closeButton: true
    property bool confirmEnabled: true
    property int cardWidth: 400
    default property alias content: body.data
    property alias actions: extra.data
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
        if (!showButtons || !showConfirm) {
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
            Item {
                visible: dlg.title !== "" || dlg.closeButton
                width: parent.width
                height: Math.max(titleText.implicitHeight, dlg.closeButton ? 24 : 0)
                Text {
                    id: titleText
                    anchors { left: parent.left; right: parent.right; rightMargin: dlg.closeButton ? 32 : 0; verticalCenter: parent.verticalCenter }
                    wrapMode: Text.Wrap
                    text: dlg.title
                    font.family: FiliTheme.font
                    font.pixelSize: FiliTheme.size
                    font.weight: FiliTheme.weightAccent
                    color: FiliTheme.text
                }
                Rectangle {
                    visible: dlg.closeButton
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    width: 24
                    height: 24
                    radius: FiliTheme.radiusControl
                    color: closeArea.pressed ? FiliTheme.selectionPressed : closeArea.containsMouse ? FiliTheme.hoverFill : "transparent"
                    Accessible.role: Accessible.Button
                    Accessible.name: FiliHost.tr("Close")
                    WindowGlyph {
                        anchors.centerIn: parent
                        width: 12
                        height: 12
                        kind: "close"
                        color: FiliTheme.text
                    }
                    MouseArea {
                        id: closeArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: dlg.reject()
                    }
                }
            }
            Column {
                id: body
                width: parent.width
                spacing: FiliTheme.space3
            }
            Item { visible: dlg.showButtons; width: 1; height: FiliTheme.space4 }
            Row {
                visible: dlg.showButtons
                anchors.right: parent.right
                spacing: FiliTheme.space2
                Row { id: extra; visible: implicitWidth > 0; spacing: FiliTheme.space2 }
                FiliButton { visible: dlg.showCancel; label: dlg.cancelLabel !== "" ? dlg.cancelLabel : FiliHost.tr("Cancel"); onClicked: dlg.reject() }
                FiliButton { visible: dlg.showConfirm; label: dlg.confirmLabel !== "" ? dlg.confirmLabel : FiliHost.tr("OK"); primary: true; enabledState: dlg.confirmEnabled; onClicked: dlg.accept() }
            }
        }
    }
}

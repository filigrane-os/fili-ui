// Keyboard shortcuts card (F1): everything can be done without the mouse, this lists how. groups = [{ title, rows: [[keys,
// description], …] }, …], supplied by the application (they are its shortcuts). Scrolls when it is taller than the window.
// Enter, Esc, F1 or a click closes it.
import QtQuick

Rectangle {
    id: card
    property var groups: []
    property string title: FiliHost.tr("Keyboard shortcuts")
    z: 250
    visible: false
    anchors.fill: parent
    color: FiliTheme.alpha(FiliTheme.backgroundDeep, 0.7)
    focus: visible

    function show() { visible = true; forceActiveFocus(); }
    function close() { visible = false; }
    Keys.onPressed: e => {
        if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter || e.key === Qt.Key_Escape || e.key === Qt.Key_F1) {
            close();
            e.accepted = true;
        }
    }
    MouseArea { anchors.fill: parent; onClicked: card.close() }

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(620, card.width - 2 * FiliTheme.margin)
        height: Math.min(card.height - 2 * FiliTheme.margin, flick.contentHeight + 2 * FiliTheme.space5)
        radius: FiliTheme.radiusWindow
        color: FiliTheme.surface
        border.width: FiliTheme.borderWidth
        border.color: FiliTheme.border
        MouseArea { anchors.fill: parent }
        Flickable {
            id: flick
            anchors { fill: parent; margins: FiliTheme.space5 }
            contentHeight: column.height
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            KineticScroll {}
            Column {
                id: column
                width: flick.width
                spacing: FiliTheme.space2
                Text {
                    text: card.title
                    font.family: FiliTheme.font
                    font.pixelSize: FiliTheme.sizeTitle
                    font.weight: FiliTheme.weightAccent
                    color: FiliTheme.text
                }
                Repeater {
                    model: card.groups
                    Column {
                        required property var modelData
                        width: column.width
                        spacing: FiliTheme.space1
                        Item { width: 1; height: FiliTheme.space2 }
                        Text {
                            text: modelData.title
                            font.family: FiliTheme.font
                            font.pixelSize: FiliTheme.sizeSmall
                            font.weight: FiliTheme.weightAccent
                            color: FiliTheme.muted
                        }
                        Repeater {
                            model: modelData.rows
                            Row {
                                required property var modelData
                                width: column.width
                                spacing: FiliTheme.space3
                                Text { width: 250; text: modelData[0]; wrapMode: Text.Wrap; font.family: FiliTheme.mono; font.pixelSize: FiliTheme.sizeList; color: FiliTheme.accentColor }
                                Text { objectName: "shortcutDescription"; width: parent.width - 250 - FiliTheme.space3; text: modelData[1]; wrapMode: Text.Wrap; font.family: FiliTheme.font; font.pixelSize: FiliTheme.sizeList; color: FiliTheme.text }
                            }
                        }
                    }
                }
            }
        }
        FiliScrollBar {
            flick: flick
            anchors { top: flick.top; bottom: flick.bottom; right: flick.right }
        }
    }
}

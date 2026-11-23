// "About" card: icon, the display name of the application (its alias: Casier for fili-file) with a line saying what it is,
// then the rows the application reports (version, program name, "Also known as", licence…). `show()` reads the rows from
// FiliHost.backend.aboutRows() (JSON: [[label, value], …]); set `rows` yourself to give them directly.
import QtQuick

FiliDialog {
    id: card
    property string appName
    property string tagline
    property url iconSource
    property var rows: []
    showButtons: false
    cardWidth: 380

    function show() {
        if (FiliHost.backend && FiliHost.backend.aboutRows)
            rows = JSON.parse(FiliHost.backend.aboutRows());
        open();
    }
    Image {
        visible: card.iconSource != ""
        anchors.horizontalCenter: parent.horizontalCenter
        width: 96
        height: 96
        source: card.iconSource
        sourceSize: Qt.size(192, 192)
        fillMode: Image.PreserveAspectFit
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: card.appName
        font.family: FiliTheme.font
        font.pixelSize: FiliTheme.sizeTitle
        font.weight: FiliTheme.weightAccent
        color: FiliTheme.text
    }
    Text {
        visible: card.tagline !== ""
        anchors.horizontalCenter: parent.horizontalCenter
        text: card.tagline
        font.family: FiliTheme.font
        font.pixelSize: FiliTheme.size
        font.weight: Font.Light
        color: FiliTheme.textSecondary
    }
    Rectangle { width: parent.width; height: FiliTheme.borderWidth; color: FiliTheme.surfaceActive }
    Grid {
        id: grid
        width: parent.width
        columns: 2
        columnSpacing: FiliTheme.space3
        rowSpacing: FiliTheme.space2
        Repeater {
            model: card.rows.length * 2
            Text {
                required property int index
                readonly property bool label: index % 2 === 0
                width: label ? 110 : grid.width - 110 - FiliTheme.space3
                horizontalAlignment: label ? Text.AlignRight : Text.AlignLeft
                wrapMode: Text.WrapAnywhere
                text: card.rows[Math.floor(index / 2)][label ? 0 : 1]
                textFormat: Text.PlainText
                font.family: FiliTheme.font
                font.pixelSize: FiliTheme.sizeList
                font.weight: label ? FiliTheme.weightAccent : Font.Normal
                color: label ? FiliTheme.textSecondary : FiliTheme.text
            }
        }
    }
}

// Footer / status bar (28): recessed `backgroundDeep`, a 1 px `border` line above. Left from `margin`: where we are; right,
// `margin` from the edge: counts, selection. `error`: the text takes the whole band in `danger`. Children go in the middle.
import QtQuick

Rectangle {
    id: f
    property string leftText
    property string rightText
    property bool error: false
    default property alias content: middle.data

    implicitHeight: FiliTheme.statusHeight
    color: FiliTheme.backgroundDeep

    Rectangle {
        anchors { left: parent.left; right: parent.right; top: parent.top }
        height: FiliTheme.borderWidth
        color: FiliTheme.border
    }
    Text {
        anchors { left: parent.left; leftMargin: FiliTheme.margin; right: f.error ? parent.right : middle.left; rightMargin: FiliTheme.margin; verticalCenter: parent.verticalCenter }
        text: f.leftText
        elide: Text.ElideRight
        font.family: FiliTheme.font
        font.pixelSize: FiliTheme.sizeSmall
        font.weight: f.error ? FiliTheme.weightAccent : Font.Normal
        color: f.error ? FiliTheme.danger : FiliTheme.text
    }
    Row {
        id: middle
        anchors.centerIn: parent
        spacing: FiliTheme.space2
    }
    Text {
        visible: !f.error
        anchors { right: parent.right; rightMargin: FiliTheme.margin; verticalCenter: parent.verticalCenter }
        text: f.rightText
        elide: Text.ElideLeft
        font.family: FiliTheme.font
        font.pixelSize: FiliTheme.sizeSmall
        color: FiliTheme.textSecondary
    }
}

// Clickable row of a panel (30 high): glyph, label, detail on the right; hover on `surfaceHover`, `sel` in the accent colour.
// Also the page list of FiliSettings. Enter / Space = click.
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: btn
    property string glyph
    property string label
    property string detail
    property bool sel: false
    property bool dim: false
    property color tint: sel ? FiliTheme.accentColor : dim ? FiliTheme.muted : FiliTheme.text
    signal clicked()

    implicitWidth: parent ? parent.width : 160
    implicitHeight: 30
    radius: FiliTheme.radiusControl
    color: area.containsMouse ? FiliTheme.surfaceHover : "transparent"
    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.name: label
    Keys.onReturnPressed: key()
    Keys.onEnterPressed: key()
    Keys.onSpacePressed: key()
    function key() {
        FiliHost.keyboard();
        btn.clicked();
    }
    FocusRing {}
    RowLayout {
        anchors { fill: parent; leftMargin: FiliTheme.space2; rightMargin: FiliTheme.space2 }
        spacing: FiliTheme.space2
        Text {
            visible: btn.glyph !== ""
            text: btn.glyph
            color: btn.tint
            Layout.preferredWidth: 18
            horizontalAlignment: Text.AlignHCenter
            font.family: FiliTheme.icons
            font.pixelSize: FiliTheme.size
        }
        Text {
            text: btn.label
            color: btn.tint
            Layout.fillWidth: true
            elide: Text.ElideRight
            font.family: FiliTheme.font
            font.pixelSize: FiliTheme.size
            font.weight: btn.sel ? FiliTheme.weightAccent : Font.Normal
        }
        Text {
            visible: btn.detail !== ""
            text: btn.detail
            color: FiliTheme.muted
            Layout.maximumWidth: btn.width * 0.6
            elide: Text.ElideRight
            font.family: FiliTheme.font
            font.pixelSize: FiliTheme.sizeList
        }
    }
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.clicked()
    }
}

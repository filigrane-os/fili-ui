// Header of a window (44): `leading` (the back/forward capsule), title (the capitals on the top edge of the capsule, `sizeList` over a `sizeSmall` line whose baseline is on its bottom edge when there is a second line), `tools` of the view,
// then the close button at the far right when `closeButton` is on. Background `background`, a 1 px `border` line below. No
// title bar or menu is drawn in the window: the window title lives in the fili-bar.
// Children go to `tools` (right, before the close button); `leading` is for what sits left of the title.
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: h
    property string title
    property string subtitle
    property bool closeButton: false
    default property alias tools: toolsRow.data
    property alias leading: leadingRow.data
    signal closeRequested()

    implicitHeight: FiliTheme.toolbarHeight
    color: FiliTheme.background

    RowLayout {
        id: leadingRow
        anchors { left: parent.left; leftMargin: FiliTheme.margin; verticalCenter: parent.verticalCenter }
        spacing: FiliTheme.space3
    }
    // The text block is as high as the capsule next to it (30): the capitals of the title start at its top edge and the baseline of
    // the second line sits on its bottom edge, so the text lines up with the button on the left. Measured with the font (cap height,
    // baseline), not with line boxes, so it holds for any font of the theme. A title alone is centred.
    readonly property int blockHeight: 30
    readonly property bool twoLines: subtitle !== ""
    // Where the baselines are, in the header (tests); `capHeight` is the height of the tallest letters (capitals and ascenders)
    readonly property real titleBaseline: block.y + titleText.y + titleText.baselineOffset
    readonly property real subtitleBaseline: block.y + subtitleText.y + subtitleText.baselineOffset
    readonly property real capHeight: Math.ceil(titleMetrics.tightBoundingRect("Hl").height)
    Item {
        id: block
        anchors { left: leadingRow.right; leftMargin: leadingRow.visibleChildren.length > 0 ? FiliTheme.space3 : 0; right: toolsRow.left; rightMargin: FiliTheme.space3; verticalCenter: parent.verticalCenter }
        height: h.twoLines ? h.blockHeight : titleText.height
        FontMetrics { id: titleMetrics; font: titleText.font }
        Text {
            id: titleText
            width: parent.width
            y: h.twoLines ? Math.ceil(h.capHeight - baselineOffset) : 0
            text: h.title
            elide: Text.ElideRight
            font.family: FiliTheme.font
            // A title alone is in `size`; with a second line the pair is `sizeList` + `sizeSmall`
            font.pixelSize: h.twoLines ? FiliTheme.sizeList : FiliTheme.size
            font.weight: FiliTheme.weightAccent
            color: FiliTheme.text
        }
        Text {
            id: subtitleText
            visible: h.twoLines
            width: parent.width
            y: h.blockHeight - baselineOffset
            text: h.subtitle
            elide: Text.ElideRight
            font.family: FiliTheme.font
            font.pixelSize: FiliTheme.sizeSmall
            color: FiliTheme.textSecondary
        }
    }
    // A layout, not a Row: it centres each tool vertically whatever its height (a capsule of 30 beside buttons of 24)
    RowLayout {
        id: toolsRow
        anchors { right: closeRect.visible ? closeRect.left : parent.right; rightMargin: closeRect.visible ? FiliTheme.space3 : FiliTheme.margin; verticalCenter: parent.verticalCenter }
        spacing: FiliTheme.space3
    }
    Rectangle {
        id: closeRect
        visible: h.closeButton
        anchors { right: parent.right; rightMargin: (FiliTheme.toolbarHeight - 24) / 2; verticalCenter: parent.verticalCenter }
        width: 28
        height: 24
        radius: FiliTheme.radiusControl
        color: closeArea.pressed ? FiliTheme.danger : closeArea.containsMouse ? FiliTheme.alpha(FiliTheme.danger, 0.75) : "transparent"
        Accessible.role: Accessible.Button
        Accessible.name: "Close window"
        WindowGlyph {
            anchors.centerIn: parent
            kind: "close"
            width: 16
            height: 16
            color: closeArea.containsMouse ? "#ffffff" : FiliTheme.text
        }
        MouseArea {
            id: closeArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: h.closeRequested()
        }
    }
    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: FiliTheme.borderWidth
        color: FiliTheme.border
    }
}

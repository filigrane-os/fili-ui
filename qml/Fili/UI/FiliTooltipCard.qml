// The card of the fili-tooltip, as the fili-bar shows it under a hovered item: read-only, the actions stay on the clicks and the
// help line (`hint`) recalls them. Title on the left in the accent colour, the content on the right: label / value rows (a row
// can carry a gauge under its value: [label, value, { value: 0..1, mark: 0..1 }], accent, `warning` from 80 %, `danger` from
// 95 %, `mark` a tick such as the expected usage) or a text (`mono`: fixed width). A thin rule and the hint close it.
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: card
    property string title
    property var rows: []
    property string text
    property bool mono: false
    property string hint

    implicitWidth: body.implicitWidth + 28
    implicitHeight: body.implicitHeight + 22
    color: FiliTheme.background
    border.width: FiliTheme.borderWidth
    border.color: FiliTheme.border
    radius: FiliTheme.radiusWindow

    ColumnLayout {
        id: body
        anchors.centerIn: parent
        spacing: FiliTheme.space2
        RowLayout {
            spacing: FiliTheme.space4
            Text {
                visible: card.title !== ""
                Layout.alignment: Qt.AlignTop
                Layout.maximumWidth: 160
                elide: Text.ElideRight
                text: card.title
                color: FiliTheme.accentColor
                font.family: FiliTheme.font
                font.pixelSize: FiliTheme.size
                font.weight: FiliTheme.weightAccent
            }
            ColumnLayout {
                Layout.alignment: Qt.AlignTop
                spacing: FiliTheme.space2
                GridLayout {
                    visible: card.rows.length > 0
                    columns: 2
                    columnSpacing: 16
                    rowSpacing: 3
                    Repeater {
                        model: card.rows.reduce((a, r) => a.concat([{ t: r[0], key: true }, { t: r[1], key: false, gauge: r[2] ?? null }]), [])
                        ColumnLayout {
                            id: cell
                            required property var modelData
                            spacing: FiliTheme.space1
                            Layout.alignment: Qt.AlignTop
                            Text {
                                text: cell.modelData.t
                                color: cell.modelData.key ? FiliTheme.muted : FiliTheme.text
                                Layout.maximumWidth: cell.modelData.key ? 140 : 420
                                elide: Text.ElideRight
                                font.family: FiliTheme.font
                                font.pixelSize: FiliTheme.size
                            }
                            Item {
                                readonly property var g: cell.modelData.gauge
                                visible: !!g
                                Layout.fillWidth: true
                                Layout.minimumWidth: 180
                                Layout.bottomMargin: 2
                                implicitHeight: 4
                                Rectangle {
                                    anchors.fill: parent
                                    radius: FiliTheme.radiusMark
                                    color: FiliTheme.surfaceHover
                                }
                                Rectangle {
                                    readonly property real v: Math.max(0, Math.min(1, parent.g?.value ?? 0))
                                    width: parent.width * v
                                    height: parent.height
                                    radius: FiliTheme.radiusMark
                                    color: v >= 0.95 ? FiliTheme.danger : v >= 0.8 ? FiliTheme.warning : FiliTheme.accentColor
                                }
                                Rectangle {
                                    readonly property real m: parent.g?.mark ?? -1
                                    visible: m >= 0 && m <= 1
                                    x: Math.round(parent.width * m) - 1
                                    y: -2
                                    width: 2
                                    height: parent.height + 4
                                    color: FiliTheme.text
                                }
                            }
                        }
                    }
                }
                Text {
                    visible: card.text !== ""
                    text: card.text
                    color: FiliTheme.text
                    font.family: card.mono ? FiliTheme.mono : FiliTheme.font
                    font.pixelSize: card.mono ? FiliTheme.sizeList : FiliTheme.size
                }
            }
        }
        Rectangle {
            visible: card.hint !== ""
            Layout.fillWidth: true
            Layout.topMargin: 2
            implicitHeight: 1
            color: FiliTheme.surfaceHover
        }
        Text {
            visible: card.hint !== ""
            text: card.hint
            color: FiliTheme.muted
            font.family: FiliTheme.font
            font.pixelSize: FiliTheme.sizeList
        }
    }
}

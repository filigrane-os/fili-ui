// Debug panel: the log of the application (src/logs.rs) in a band above the footer, opened from View > Debug Logs. The text is
// selectable (Ctrl+C copies the selection, "Copy" the selection or everything shown), a filter keeps warnings or errors, and the
// top edge is dragged to change the height. It only reads: FiliHost.backend.logs(since), FiliHost.backend.logFile(), FiliHost.backend.clearLogs(), FiliHost.backend.copyText()
// and FiliHost.backend.openPath(), which every fili-* application gives the same way (agents/skills/filigrane-ui/references/app-window.md).
import QtQuick

Rectangle {
    id: panel
    property bool open: false
    // What is shown: 0 everything, 1 warnings and errors, 2 errors
    property int filter: 0
    property real panelHeight: Number(FiliHost.backend.uiState("debug_height")) || 220
    readonly property int keep: 2000

    visible: open
    height: open ? panelHeight : 0
    color: FiliTheme.backgroundDeep

    // The entries received ({ level, text }) and the number of the last one
    property var entries: []
    property int seq: 0
    property int shown: 0
    // Result of "Ask Lia", shown in the header for a few seconds
    property string note: ""

    function colorOf(level) {
        return String(level >= 3 ? FiliTheme.danger : level === 2 ? FiliTheme.warning : level === 1 ? FiliTheme.textSecondary : FiliTheme.muted);
    }
    function wanted(level) {
        return filter === 0 || (filter === 1 ? level >= 2 : level >= 3);
    }
    function html(e) {
        const text = e.text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
        return '<div style="white-space: pre-wrap; color: ' + colorOf(e.level) + '">' + text + "</div>";
    }
    function rebuild() {
        const list = entries.filter(e => wanted(e.level));
        shown = list.length;
        edit.text = list.map(html).join("");
        follow();
    }
    // Stays on the last line while the reader is there (or has nothing selected to read)
    function follow() {
        Qt.callLater(() => flick.contentY = Math.max(0, flick.contentHeight - flick.height));
    }
    function poll() {
        const r = JSON.parse(FiliHost.backend.logs(seq));
        seq = r.seq;
        if (r.entries.length === 0)
            return;
        const atEnd = flick.atYEnd && edit.selectionStart === edit.selectionEnd;
        const added = r.entries.map(([level, text]) => ({ level: level, text: text }));
        entries = entries.concat(added);
        if (entries.length > keep) {
            entries = entries.slice(entries.length - keep);
            rebuild();
            return;
        }
        for (const e of added) {
            if (wanted(e.level)) {
                edit.append(html(e));
                shown++;
            }
        }
        if (atEnd)
            follow();
    }
    // The problem: the lines selected in the panel, else the last ones; Lia is asked to look at it (fili-incident)
    function askLia() {
        const id = FiliHost.backend.reportProblem(edit.selectedText);
        note = id !== "" ? FiliHost.tr("Lia was asked to look at it") : FiliHost.tr("Could not record the problem");
        noteTimer.restart();
    }
    Timer {
        id: noteTimer
        interval: 5000
        onTriggered: panel.note = ""
    }
    function reset() {
        entries = [];
        seq = 0;
        poll();
        rebuild();
    }
    function copy() {
        FiliHost.backend.copyText(edit.selectedText !== "" ? edit.selectedText : edit.getText(0, edit.length));
    }
    onOpenChanged: if (open)
        reset()
    onFilterChanged: rebuild()
    Timer {
        interval: 500
        repeat: true
        running: panel.open
        onTriggered: panel.poll()
    }

    Rectangle {
        width: parent.width
        height: FiliTheme.borderWidth
        color: FiliTheme.border
    }
    // The top edge changes the height
    MouseArea {
        id: grip
        z: 5
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 6
        cursorShape: Qt.SizeVerCursor
        onPositionChanged: e => {
            if (!pressed)
                return;
            const y = grip.mapToItem(panel.parent, 0, e.y).y;
            const bottom = panel.y + panel.height;
            panel.panelHeight = Math.max(100, Math.min(panel.parent.height * 0.7, bottom - y));
        }
        onReleased: FiliHost.backend.setUiState("debug_height", String(Math.round(panel.panelHeight)))
    }

    // Header: one line when it fits (title and filters on the left, the actions on the right), two when the panel is narrow
    // (a drawer): the actions then go under the title
    Item {
        id: head
        y: FiliTheme.borderWidth
        width: parent.width
        height: Math.max(30, bar.height + FiliTheme.space1 * 2)
        Flow {
            id: bar
            x: FiliTheme.space3
            y: Math.max(FiliTheme.space1, (30 - height) / 2)
            width: parent.width - 2 * FiliTheme.space3
            spacing: FiliTheme.space1
            readonly property bool oneLine: left.width + right.width + spacing <= width
            Row {
                id: left
                spacing: FiliTheme.space1
                Text {
                    id: title
                    height: 22
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: FiliTheme.space1
                    rightPadding: FiliTheme.space2
                    text: FiliHost.tr("Debug logs")
                    font.family: FiliTheme.font
                    font.pixelSize: FiliTheme.size
                    font.weight: FiliTheme.weightAccent
                    color: FiliTheme.text
                }
                Repeater {
                    model: [FiliHost.tr("All"), FiliHost.tr("Warnings"), FiliHost.tr("Errors")]
                    FiliButton {
                        required property string modelData
                        required property int index
                        label: modelData
                        primary: panel.filter === index
                        onClicked: panel.filter = index
                    }
                }
            }
            // Pushes the actions to the right edge while everything fits on one line
            Item { width: bar.oneLine ? bar.width - left.width - right.width - 2 * bar.spacing : 0; height: 1 }
            Row {
                id: right
                spacing: FiliTheme.space1
                Text {
                    height: 22
                    verticalAlignment: Text.AlignVCenter
                    text: panel.note !== "" ? panel.note : panel.shown + " " + FiliHost.tr("entries")
                    font.family: FiliTheme.font
                    font.pixelSize: FiliTheme.sizeSmall
                    color: panel.note !== "" ? FiliTheme.accentColor : FiliTheme.muted
                    rightPadding: FiliTheme.space2
                }
                FiliButton { label: FiliHost.tr("Ask Lia"); onClicked: panel.askLia() }
                FiliButton { label: FiliHost.tr("Copy"); onClicked: panel.copy() }
                FiliButton {
                    label: FiliHost.tr("Clear")
                    onClicked: {
                        FiliHost.backend.clearLogs();
                        panel.reset();
                    }
                }
                FiliButton { label: FiliHost.tr("Open file"); onClicked: FiliHost.backend.openPath(FiliHost.backend.logFile()) }
                FiliButton { label: "×"; onClicked: panel.open = false }
            }
        }
    }

    Flickable {
        id: flick
        anchors { top: head.bottom; bottom: parent.bottom; left: parent.left; right: parent.right; leftMargin: FiliTheme.margin; rightMargin: FiliTheme.margin; bottomMargin: FiliTheme.space1 }
        contentWidth: width
        contentHeight: edit.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        KineticScroll {}
        TextEdit {
            id: edit
            width: flick.width - 10
            readOnly: true
            selectByMouse: true
            textFormat: TextEdit.RichText
            wrapMode: TextEdit.Wrap
            font.family: FiliTheme.mono
            font.pixelSize: FiliTheme.sizeSmall
            color: FiliTheme.textSecondary
            selectionColor: FiliTheme.selectionText
            selectedTextColor: FiliTheme.text
        }
    }
    FiliScrollBar {
        flick: flick
        anchors { top: flick.top; bottom: flick.bottom; right: flick.right }
    }
    Accessible.role: Accessible.Pane
    Accessible.name: FiliHost.tr("Debug logs")
}

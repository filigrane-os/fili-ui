// Gallery of the kit as an application window: header, sidebar, tabs, footer and every control in every state, dark and
// light. Run: make demo
import QtQuick
import QtQuick.Window
import Fili.UI

Window {
    id: win
    // The kit reads the theme through the application's own object: set in the FIRST binding (see README)
    readonly property bool kitReady: { FiliHost.backend = backend; return true; }
    width: 1040
    height: 700
    visible: true
    title: "Fili UI"
    color: FiliTheme.background

    FontLoader { source: Qt.resolvedUrl("fonts/Jost-Variable.ttf") }
    FontLoader { source: Qt.resolvedUrl("fonts/FiliIcons.ttf") }

    // Stand-in for an application's Rust object (what FiliHost.backend expects)
    QtObject {
        id: backend
        property bool light: false
        property string accent: "default"
        property int settingsRev: 0
        property bool keyNav: true
        // What the window panel, the debug panel, the About card and the Lia button ask of the application
        property string lastAction: ""
        function tr(text) { return text; }
        function windowControl() { return false; }
        function windowState() { return ""; }
        function windowAction(name) { lastAction = name; }
        function askLia() { lastAction = "ask Lia"; }
        function logs(since) {
            const all = [[0, "Fili UI demo started"], [1, "A notice"], [2, "A warning: the log is a stand-in"], [3, "An error, in the danger colour"]];
            return JSON.stringify({ seq: all.length, entries: all.slice(since) });
        }
        function logFile() { return "/tmp/fili-ui-demo.log"; }
        function clearLogs() {}
        function openPath(path) { lastAction = "open " + path; }
        function copyText(text) {}
        function reportProblem(text) { return "demo"; }
        function uiState(key) { return ""; }
        function setUiState(key, value) {}
        function aboutRows() { return JSON.stringify([["Version", "0.2.0"], ["Program", "fili-ui"], ["Licence", "GPL-3.0-or-later"]]); }
        function themeJson() {
            const x = new XMLHttpRequest();
            x.open("GET", Qt.resolvedUrl("theme.json"), false);
            x.send();
            return x.responseText;
        }
    }
    // The window draws its own hover labels (FiliIconButton asks for them): a small label under the button
    function showTip(item, text) { tip.text = text; }
    function hideTip(item) { tip.text = ""; }

    property int tab: Number(Qt.application.arguments[Qt.application.arguments.length - 1]) >= 0 ? Number(Qt.application.arguments[Qt.application.arguments.length - 1]) : 0
    property var tabs: ["Controls", "Colors", "Type", "Icons", "Dialogs"]
    property string place: "Documents"
    property string view: "list"

    FiliHeader {
        id: header
        anchors { left: parent.left; right: parent.right; top: parent.top }
        title: "Fili UI"
        subtitle: win.tabs[win.tab]
        closeButton: true
        onCloseRequested: Qt.quit()
        leading: [FiliNavCapsule { canBack: win.tab > 0; canForward: win.tab < win.tabs.length - 1; onBack: win.tab--; onForward: win.tab++ }]
        FiliIconButton { glyph: ""; tip: "Previous tab"; hint: "Ctrl+Shift+Tab"; onClicked: if (win.tab > 0) win.tab-- }
        FiliIconButton { glyph: ""; tip: "Next tab"; hint: "Ctrl+Tab"; onClicked: if (win.tab < win.tabs.length - 1) win.tab++ }
        FiliIconButton { glyph: ""; tip: "Disabled"; enabledState: false }
        FiliViewSwitch { mode: win.view; onChose: m => win.view = m }
        FiliLiaButton {}
        FiliTextField { placeholder: "Search"; clearable: true }
    }
    FiliSidebar {
        id: sidebar
        anchors { left: parent.left; top: header.bottom; bottom: debug.top }
        FiliSidebarSection {
            title: "Favorites"
            Repeater {
                model: ["Applications", "Documents", "Downloads", "Pictures"]
                FiliSidebarRow { required property string modelData; label: modelData; selected: win.place === modelData; count: modelData === "Downloads" ? "12" : ""; onClicked: win.place = modelData }
            }
        }
        FiliSidebarSection {
            title: "Recents"
            Repeater {
                model: ["fili-ui", "demo"]
                FiliSidebarRow { required property string modelData; label: modelData; selected: win.place === modelData; onClicked: win.place = modelData }
            }
        }
        FiliSidebarSection {
            title: "Locations"
            folded: true
            FiliSidebarRow { label: "Computer" }
            FiliSidebarRow { label: "Trash" }
        }
    }
    Column {
        anchors { left: sidebar.right; right: parent.right; top: header.bottom; bottom: debug.top }
        FiliTabBar {
            id: tabbar
            width: parent.width
            model: win.tabs
            currentIndex: win.tab
            onTabClicked: i => win.tab = i
            onReordered: (from, to) => { const v = win.tabs.slice(); const t = v.splice(from, 1)[0]; v.splice(to, 0, t); win.tabs = v; win.tab = to; }
        }
        Item {
            width: parent.width
            height: parent.height - tabbar.height
            // --- Controls
            Flickable {
                id: controls
                visible: win.tab === 0
                anchors.fill: parent
                contentHeight: form.height + 2 * FiliTheme.margin
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                Column {
                    id: form
                    x: FiliTheme.margin
                    y: FiliTheme.margin
                    width: controls.width - 2 * FiliTheme.margin
                    spacing: FiliTheme.space5
                    component Heading: Text {
                        font.family: FiliTheme.font
                        font.pixelSize: FiliTheme.sizeSmall
                        font.weight: FiliTheme.weightAccent
                        color: FiliTheme.muted
                    }
                    component Group: Column {
                        property string title
                        spacing: FiliTheme.space2
                        Heading { text: parent.title }
                    }
                    Group {
                        title: "Buttons"
                        Row {
                            spacing: FiliTheme.space2
                            FiliButton { label: "Default" }
                            FiliButton { label: "Primary"; primary: true }
                            FiliButton { label: "Disabled"; enabledState: false }
                            FiliButton { label: backend.light ? "Dark mode" : "Light mode"; onClicked: backend.light = !backend.light }
                        }
                    }
                    Group {
                        title: "View switch"
                        Row {
                            spacing: FiliTheme.space3
                            FiliViewSwitch { mode: win.view; onChose: m => win.view = m }
                            Text { text: "Mode: " + win.view; anchors.verticalCenter: parent.verticalCenter; font.family: FiliTheme.font; font.pixelSize: FiliTheme.sizeList; color: FiliTheme.textSecondary }
                        }
                    }
                    Group {
                        title: "Choices"
                        Row {
                            spacing: FiliTheme.space6
                            Column {
                                spacing: FiliTheme.space2
                                FiliCheckBox { label: "Checked"; checked: true }
                                FiliCheckBox { id: cb; label: "Unchecked"; onToggled: checked = !checked }
                                FiliCheckBox { label: "Disabled"; enabledState: false }
                            }
                            Column {
                                spacing: FiliTheme.space2
                                property string choice: "a"
                                FiliRadioButton { label: "First"; checked: parent.choice === "a"; onClicked: parent.choice = "a" }
                                FiliRadioButton { label: "Second"; checked: parent.choice === "b"; onClicked: parent.choice = "b" }
                                FiliRadioButton { label: "Disabled"; enabledState: false }
                            }
                            Column {
                                spacing: FiliTheme.space3
                                Row { spacing: FiliTheme.space2; FiliSwitch { checked: backend.light; onToggled: backend.light = !backend.light } Text { text: "Light mode"; font.family: FiliTheme.font; font.pixelSize: FiliTheme.size; color: FiliTheme.text } }
                                Row { spacing: FiliTheme.space2; FiliSwitch { id: sw2; checked: true; onToggled: checked = !checked } Text { text: "Applies at once"; font.family: FiliTheme.font; font.pixelSize: FiliTheme.size; color: FiliTheme.text } }
                                Row { spacing: FiliTheme.space2; FiliSwitch { switchable: false } Text { text: "Nothing to turn on"; font.family: FiliTheme.font; font.pixelSize: FiliTheme.size; color: FiliTheme.muted } }
                            }
                        }
                    }
                    Group {
                        title: "Sliders"
                        FiliSlider { id: sl1; width: 320; showValue: true; to: 100; value: 0.4; onMoved: v => value = v }
                        FiliSlider { id: sl2; width: 320; showValue: true; steps: 4; to: 100; value: 0.5; onMoved: v => value = v }
                        FiliSlider { width: 320; enabledState: false; value: 0.7 }
                    }
                    Group {
                        title: "Fields"
                        Row {
                            spacing: FiliTheme.space3
                            FiliTextField { placeholder: "Name" }
                            FiliTextField { placeholder: "Search"; clearable: true; text: "fili" }
                            FiliTextField { placeholder: "Invalid"; error: true; text: "oops" }
                            FiliTextField { placeholder: "Disabled"; enabledState: false }
                        }
                    }
                    Group {
                        title: "Selection"
                        Row {
                            spacing: FiliTheme.space3
                            FiliSelect {
                                width: 160
                                placeholder: "Accent"
                                current: backend.accent
                                model: [{ label: "Default", value: "default" }, { label: "Voile", value: "voile" }, { label: "Ardoise", value: "ardoise" }, { label: "Sauge", value: "sauge" }, { label: "Unavailable", value: "x", off: true }]
                                onPicked: v => { backend.accent = v; backend.settingsRev++; }
                            }
                            FiliSelect { width: 160; placeholder: "Nothing chosen"; model: [{ label: "One", value: 1 }, { label: "Two", value: 2 }] }
                        }
                    }
                    Group {
                        title: "Progress"
                        FiliProgressBar { width: 320; value: 0.6 }
                        FiliProgressBar { width: 320; indeterminate: true }
                    }
                    Group {
                        title: "List with scrolling"
                        Item {
                            width: 320
                            height: 120
                            ListView {
                                id: lv
                                anchors.fill: parent
                                model: 40
                                clip: true
                                delegate: Text {
                                    required property int index
                                    text: "Row " + index
                                    height: FiliTheme.rowHeight
                                    verticalAlignment: Text.AlignVCenter
                                    font.family: FiliTheme.font
                                    font.pixelSize: FiliTheme.sizeList
                                    color: FiliTheme.text
                                }
                                KineticScroll {}
                            }
                            FiliScrollBar { flick: lv; anchors { top: lv.top; bottom: lv.bottom; right: lv.right } }
                        }
                    }
                }
                KineticScroll {}
            }
            FiliScrollBar { visible: win.tab === 0; flick: controls; anchors { top: controls.top; bottom: controls.bottom; right: controls.right } }
            // --- Colors
            Grid {
                visible: win.tab === 1
                x: FiliTheme.margin
                y: FiliTheme.margin
                columns: 4
                spacing: FiliTheme.space3
                Repeater {
                    model: [["background", FiliTheme.background], ["backgroundDeep", FiliTheme.backgroundDeep], ["surface", FiliTheme.surface], ["surfaceHover", FiliTheme.surfaceHover], ["surfaceActive", FiliTheme.surfaceActive], ["border", FiliTheme.border], ["muted", FiliTheme.muted], ["textSecondary", FiliTheme.textSecondary], ["text", FiliTheme.text], ["accentColor", FiliTheme.accentColor], ["accentBright", FiliTheme.accentBright], ["warning", FiliTheme.warning], ["danger", FiliTheme.danger]]
                    Column {
                        required property var modelData
                        spacing: FiliTheme.space1
                        Rectangle { width: 140; height: 56; radius: FiliTheme.radiusControl; color: modelData[1]; border.width: FiliTheme.borderWidth; border.color: FiliTheme.border }
                        Text { text: modelData[0]; font.family: FiliTheme.font; font.pixelSize: FiliTheme.sizeSmall; color: FiliTheme.textSecondary }
                    }
                }
            }
            // --- Icons
            Flow {
                visible: win.tab === 3
                x: FiliTheme.margin
                y: FiliTheme.margin
                width: parent.width - 2 * FiliTheme.margin
                spacing: FiliTheme.space4
                FiliIcon { id: iconProbe; visible: false; width: 0; height: 0 }
                Repeater {
                    model: Object.keys(iconProbe.paths)
                    Column {
                        required property string modelData
                        width: 84
                        spacing: FiliTheme.space1
                        FiliIcon { anchors.horizontalCenter: parent.horizontalCenter; name: modelData; size: 24; color: FiliTheme.text }
                        Text { width: parent.width; horizontalAlignment: Text.AlignHCenter; text: modelData; elide: Text.ElideRight; font.family: FiliTheme.font; font.pixelSize: FiliTheme.sizeLabel; color: FiliTheme.textSecondary }
                    }
                }
            }
            // --- Dialogs and menus
            Column {
                visible: win.tab === 4
                x: FiliTheme.margin
                y: FiliTheme.margin
                spacing: FiliTheme.space4
                Text { text: "Dialogs, cards and menus"; font.family: FiliTheme.font; font.pixelSize: FiliTheme.sizeSmall; font.weight: FiliTheme.weightAccent; color: FiliTheme.muted }
                Row {
                    spacing: FiliTheme.space2
                    FiliButton { label: "Dialog"; onClicked: dialog.open() }
                    FiliButton { label: "About card"; onClicked: about.show() }
                    FiliButton { label: "Shortcuts"; onClicked: shortcuts.show() }
                    FiliButton { label: "Window actions"; onClicked: windowPanel.open() }
                    FiliButton { label: "Debug logs"; onClicked: debug.open = !debug.open }
                }
                Text { text: "Right click the area below for a menu"; font.family: FiliTheme.font; font.pixelSize: FiliTheme.sizeList; color: FiliTheme.textSecondary }
                Rectangle {
                    width: 360
                    height: 90
                    radius: FiliTheme.radiusControl
                    color: FiliTheme.surface
                    border.width: FiliTheme.borderWidth
                    border.color: FiliTheme.border
                    Text { anchors.centerIn: parent; text: backend.lastAction === "" ? "Last action: none" : "Last action: " + backend.lastAction; font.family: FiliTheme.font; font.pixelSize: FiliTheme.sizeList; color: FiliTheme.text }
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        onClicked: e => { const p = mapToItem(null, e.x, e.y); menu.open(p.x, p.y, [{ id: "open", label: "Open", hint: "Enter" }, { id: "copy", label: "Copy", hint: "Ctrl+C" }, { separator: true }, { id: "view", label: "Show hidden files", checked: true }, { id: "more", label: "More", children: [{ id: "a", label: "First" }, { id: "b", label: "Second" }] }, { id: "off", label: "Unavailable", enabled: false }, { separator: true }, { id: "del", label: "Move to Trash", danger: true }]); }
                    }
                }
                Row {
                    spacing: FiliTheme.space5
                    FiliSpinner { size: 48 }
                    Row {
                        spacing: FiliTheme.space2
                        FiliAvatar { name: "Ada"; size: 32 }
                        FiliAvatar { name: "Bruno"; size: 40 }
                        FiliAvatar { name: "Chloé"; size: 56 }
                    }
                }
            }
            // --- Type
            Column {
                visible: win.tab === 2
                x: FiliTheme.margin
                y: FiliTheme.margin
                spacing: FiliTheme.space3
                Repeater {
                    model: [["Title", FiliTheme.sizeTitle], ["Body", FiliTheme.size], ["List", FiliTheme.sizeList], ["Small", FiliTheme.sizeSmall], ["Label", FiliTheme.sizeLabel]]
                    Text {
                        required property var modelData
                        text: modelData[0] + " · " + modelData[1] + " px · The quick brown fox jumps over the lazy dog"
                        font.family: FiliTheme.font
                        font.pixelSize: modelData[1]
                        font.weight: modelData[0] === "Title" ? FiliTheme.weightAccent : Font.Normal
                        color: FiliTheme.text
                    }
                }
                Text { text: "Mono · 0123456789 {}[]()"; font.family: FiliTheme.mono; font.pixelSize: FiliTheme.size; color: FiliTheme.textSecondary }
            }
        }
    }
    FiliDebugPanel {
        id: debug
        anchors { left: parent.left; right: parent.right; bottom: footer.top }
    }
    FiliFooter {
        id: footer
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        leftText: win.place
        rightText: win.tabs[win.tab]
        FiliProgressBar { width: 120; indeterminate: true; anchors.verticalCenter: parent.verticalCenter }
    }
    // Label of a hovered icon button, drawn by the window like the applications do
    Text {
        id: tip
        visible: text !== ""
        anchors { top: header.bottom; right: parent.right; margins: FiliTheme.space2 }
        font.family: FiliTheme.font
        font.pixelSize: FiliTheme.sizeSmall
        color: FiliTheme.muted
    }
    FiliWindowPanel {
        id: windowPanel
        anchorRight: win.width - FiliTheme.margin
        anchorTop: FiliTheme.toolbarHeight
    }
    FiliMenu {
        id: menu
        onActivated: id => backend.lastAction = "menu: " + id
    }
    FiliDialog {
        id: dialog
        title: "Rename the folder"
        confirmLabel: "Rename"
        confirmEnabled: field.text !== ""
        onAccepted: backend.lastAction = "renamed to " + field.text
        FiliTextField { id: field; width: parent.width; placeholder: "Name"; text: "Documents"; onAccepted: dialog.accept() }
    }
    FiliAboutCard {
        id: about
        appName: "Fili UI"
        tagline: "The shared controls of Filigrane"
    }
    FiliShortcutsCard {
        id: shortcuts
        groups: [{ title: "Moving around", rows: [["Alt+←  Alt+→", "Back / forward"], ["Ctrl+F  /", "Search"], ["Ctrl+Shift+W", "Window actions"]] }, { title: "List", rows: [["↑ ↓", "Move"], ["Enter", "Open"], ["Ctrl+A", "Select all"]] }]
    }
}

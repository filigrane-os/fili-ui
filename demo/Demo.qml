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

    // `make demo TAB=5 OPEN=panel`: the tab to start on and a card to open at once (panel, settings, tooltip)
    readonly property var cli: Qt.application.arguments.slice(1)
    property int tab: { const n = cli.map(Number).filter(v => !isNaN(v) && v >= 0 && v < tabs.length); return n.length ? n[0] : 0; }
    property var tabs: ["Controls", "Colors", "Type", "Icons", "Dialogs", "Fili-bar"]
    Component.onCompleted: {
        if (cli.includes("panel")) { panel.settingsPage = "sound"; panel.openAt(bar); }
        else if (cli.includes("settings")) settings.open("sound");
        else if (cli.includes("tooltip")) tooltip.show(bar, { title: "Sound", rows: [["Output", "Built-in speakers"], ["Volume", "42 %", { value: 0.42, mark: 0.5 }]], hint: "Click: panel · Right click: menu" });
    }
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
            // --- Fili-bar: the tooltip on hover, the panel on click, the settings from its gear
            Column {
                visible: win.tab === 5
                width: parent.width
                Rectangle {
                    id: bar
                    width: parent.width
                    height: 34
                    color: FiliTheme.backgroundDeep
                    Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: FiliTheme.borderWidth; color: FiliTheme.border }
                    Text { anchors { left: parent.left; leftMargin: FiliTheme.space3; verticalCenter: parent.verticalCenter } text: "Filigrane"; font.family: FiliTheme.font; font.pixelSize: FiliTheme.size; font.weight: FiliTheme.weightAccent; color: FiliTheme.text }
                    Row {
                        anchors { right: parent.right; rightMargin: FiliTheme.space2; verticalCenter: parent.verticalCenter }
                        Repeater {
                            model: [
                                { glyph: "\uf028", value: "42", page: "sound", card: { title: "Sound", rows: [["Output", "Built-in speakers"], ["Volume", "42 %", { value: 0.42, mark: 0.5 }]], hint: "Click: panel · Right click: menu" } },
                                { glyph: "\uf1eb", value: "", page: "network", card: { title: "Network", rows: [["Wi-Fi", "Filigrane-5G"], ["Signal", "78 %", { value: 0.78 }], ["Download", "12.4 MB/s"]], hint: "Click: panel" } },
                                { glyph: "\uf293", value: "", page: "bluetooth", card: { title: "Bluetooth", text: "2 devices connected", hint: "Click: panel" } },
                                { glyph: "\uf240", value: "92", page: "power", card: { title: "Battery", rows: [["Level", "92 %", { value: 0.92, mark: 0.8 }], ["Time left", "5 h 12 min"]], hint: "Click: panel" } },
                                { glyph: "\uf0f3", value: "", page: "notifications", card: { text: "No new notification" } }
                            ]
                            Item {
                                id: mod
                                required property var modelData
                                width: row.implicitWidth + 2 * FiliTheme.space2
                                height: 34
                                Rectangle { anchors { fill: parent; topMargin: 3; bottomMargin: 3 } radius: FiliTheme.radiusControl; color: modArea.containsMouse || (panel.opened && panel.item === mod) ? FiliTheme.surfaceHover : "transparent" }
                                Row {
                                    id: row
                                    anchors.centerIn: parent
                                    spacing: FiliTheme.space1
                                    Text { text: mod.modelData.glyph; font.family: FiliTheme.icons; font.pixelSize: FiliTheme.size; color: FiliTheme.muted; anchors.verticalCenter: parent.verticalCenter }
                                    Text { visible: mod.modelData.value !== ""; text: mod.modelData.value; font.family: FiliTheme.font; font.pixelSize: FiliTheme.size; color: FiliTheme.text; anchors.verticalCenter: parent.verticalCenter }
                                }
                                MouseArea {
                                    id: modArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onContainsMouseChanged: containsMouse ? tooltip.show(mod, mod.modelData.card) : tooltip.hide(mod)
                                    onClicked: { tooltip.hide(mod); panel.settingsPage = mod.modelData.page; panel.toggle(mod); }
                                }
                            }
                        }
                        Item {
                            id: clock
                            width: clockText.implicitWidth + 2 * FiliTheme.space2
                            height: 34
                            Text { id: clockText; anchors.centerIn: parent; text: "Sun 23 Nov  10:42"; font.family: FiliTheme.font; font.pixelSize: FiliTheme.size; color: FiliTheme.text }
                            MouseArea { anchors.fill: parent; hoverEnabled: true; onContainsMouseChanged: containsMouse ? tooltip.show(clock, { title: "Sunday", text: "23 November 2026", hint: "Click: calendar" }) : tooltip.hide(clock) }
                        }
                    }
                }
                Column {
                    x: FiliTheme.margin
                    width: parent.width - 2 * FiliTheme.margin
                    topPadding: FiliTheme.margin
                    spacing: FiliTheme.space3
                    Text { text: "The three cards of the fili-shell"; font.family: FiliTheme.font; font.pixelSize: FiliTheme.sizeSmall; font.weight: FiliTheme.weightAccent; color: FiliTheme.muted }
                    Text { width: parent.width; wrapMode: Text.Wrap; text: "Hover an icon of the bar above: the tooltip opens under it after 400 ms (read-only, the actions stay on the clicks). Click an icon: the panel opens under it (340 wide, Esc or a click elsewhere closes it, the same icon again too). The gear at its top right opens the settings window on the matching page (640 wide, Esc or the cross closes it)."; font.family: FiliTheme.font; font.pixelSize: FiliTheme.size; color: FiliTheme.textSecondary }
                    Row {
                        spacing: FiliTheme.space2
                        FiliButton { label: "Open the panel"; onClicked: { panel.settingsPage = "sound"; panel.openAt(bar); } }
                        FiliButton { label: "Open the settings"; onClicked: settings.open("sound") }
                    }
                    Text { text: "The tooltip card on its own"; font.family: FiliTheme.font; font.pixelSize: FiliTheme.sizeSmall; font.weight: FiliTheme.weightAccent; color: FiliTheme.muted; topPadding: FiliTheme.space3 }
                    Row {
                        spacing: FiliTheme.space4
                        FiliTooltipCard { title: "Sound"; rows: [["Output", "Built-in speakers"], ["Volume", "86 %", { value: 0.86, mark: 0.5 }], ["Peak", "97 %", { value: 0.97 }]]; hint: "Click: panel · Right click: menu" }
                        FiliTooltipCard { text: "A one line card"; }
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
    FiliTooltip {
        id: tooltip
        blocked: panel.opened || settings.opened
    }
    FiliPanel {
        id: panel
        onSettingsRequested: page => settings.open(page)
        FiliPanelSection { text: "OUTPUT"; divided: false; width: parent.width }
        FiliSlider { width: parent.width; showValue: true; to: 100; value: 0.42; onMoved: v => value = v }
        FiliPanelButton { glyph: "\uf028"; label: "Built-in speakers"; detail: "Default"; sel: true; width: parent.width }
        FiliPanelButton { glyph: "\uf028"; label: "Headphones"; detail: "Not connected"; dim: true; width: parent.width }
        FiliPanelSection { text: "OPTIONS"; width: parent.width }
        Row {
            spacing: FiliTheme.space2
            FiliSwitch { checked: sw3.on; onToggled: sw3.on = !sw3.on; QtObject { id: sw3; property bool on: false } }
            Text { text: "Mute"; font.family: FiliTheme.font; font.pixelSize: FiliTheme.size; color: FiliTheme.text; anchors.verticalCenter: parent.verticalCenter }
        }
    }
    FiliSettings {
        id: settings
        pages: [{ id: "display", label: "Display" }, { id: "sound", label: "Sound" }, { id: "network", label: "Network" }, { id: "appearance", label: "Appearance" }, { id: "about", label: "About" }]
        page: "sound"
        Column {
            visible: settings.page === "sound"
            width: parent.width
            spacing: FiliTheme.space3
            Text { text: "Sound"; font.family: FiliTheme.font; font.pixelSize: FiliTheme.sizeTitle; font.weight: FiliTheme.weightAccent; color: FiliTheme.text }
            FiliPanelSection { text: "OUTPUT"; divided: false; width: parent.width }
            FiliSelect { width: 220; placeholder: "Device"; current: 1; model: [{ label: "Built-in speakers", value: 1 }, { label: "Headphones", value: 2, off: true }] }
            FiliPanelSection { text: "VOLUME"; width: parent.width }
            FiliSlider { width: 320; showValue: true; to: 100; value: 0.42; onMoved: v => value = v }
            FiliCheckBox { label: "Raise the volume above 100 %"; checked: false; onToggled: checked = !checked }
        }
        Column {
            visible: settings.page !== "sound"
            width: parent.width
            spacing: FiliTheme.space3
            Text { text: settings.pages.find(p => p.id === settings.page).label; font.family: FiliTheme.font; font.pixelSize: FiliTheme.sizeTitle; font.weight: FiliTheme.weightAccent; color: FiliTheme.text }
            Text { width: parent.width; wrapMode: Text.Wrap; text: "The page of this module: what is set once. The frequent settings stay in its panel."; font.family: FiliTheme.font; font.pixelSize: FiliTheme.size; color: FiliTheme.textSecondary }
        }
    }
}

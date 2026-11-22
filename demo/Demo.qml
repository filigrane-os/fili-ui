// Gallery of the kit: every control in every state, dark and light. Run: make demo
import QtQuick
import QtQuick.Window
import Fili.UI

Window {
    id: win
    width: 720
    height: 480
    visible: true
    title: "Fili UI"
    color: FiliTheme.background

    // Stand-in for an application's Rust object (what FiliHost.backend expects)
    QtObject {
        id: backend
        property bool light: false
        property string accent: "default"
        property int settingsRev: 0
        property bool keyNav: true
        property string json: ""
        function themeJson() { return json; }
    }
    Component.onCompleted: {
        const x = new XMLHttpRequest();
        x.open("GET", Qt.resolvedUrl("theme.json"), false);
        x.send();
        backend.json = x.responseText;
        FiliHost.backend = backend;
    }
    function showTip(item, text) { tip.text = text; }
    function hideTip(item) { tip.text = ""; }

    Column {
        anchors { fill: parent; margins: FiliTheme.margin }
        spacing: FiliTheme.space4
        Text {
            text: "Fili UI"
            font { family: FiliTheme.font; pixelSize: FiliTheme.sizeTitle; weight: FiliTheme.weightAccent }
            color: FiliTheme.text
        }
        Row {
            spacing: FiliTheme.space2
            FiliButton { label: "Default" }
            FiliButton { label: "Primary"; primary: true }
            FiliButton { label: "Disabled"; enabledState: false }
            FiliButton { label: backend.light ? "Dark" : "Light"; onClicked: backend.light = !backend.light }
        }
        Row {
            spacing: FiliTheme.space2
            FiliIconButton { glyph: ""; tip: "Icon" }
            FiliIconButton { glyph: ""; tip: "Toggled"; toggled: true }
            FiliIconButton { glyph: ""; tip: "Disabled"; enabledState: false }
        }
        Text {
            id: tip
            font.family: FiliTheme.font
            font.pixelSize: FiliTheme.sizeSmall
            color: FiliTheme.muted
        }
        Item {
            width: 320; height: 160
            ListView {
                id: lv
                anchors.fill: parent
                model: 40
                clip: true
                delegate: Text {
                    required property int index
                    text: "Row " + index
                    font.family: FiliTheme.font
                    font.pixelSize: FiliTheme.sizeList
                    color: FiliTheme.text
                    height: 24
                }
                KineticScroll {}
            }
            FiliScrollBar { flick: lv; anchors { top: lv.top; bottom: lv.bottom; right: lv.right } }
        }
    }
}

// The fili-tooltip: one information card under the hovered item, after 400 ms, 6 px below it and kept inside the window. Put one
// over the content of the window (it takes no click) and drive it from the items: `show(item, { title, rows, text, mono, hint })`
// on hover, `hide(item)` when the pointer leaves or the item is clicked. `update(item, card)` changes the card shown (data that
// arrived after the hover) without restarting the delay. Nothing opens while a panel is open or `blocked` (e.g. just after one
// closed, `cooldown`): leave the icon, then come back.
import QtQuick

Item {
    id: tip
    property Item target: null
    property var card: ({})
    property bool shown: false
    property bool blocked: false
    readonly property int delay: 400

    anchors.fill: parent
    z: 280

    function empty(c) { return !c || (!c.title && !c.text && !(c.rows && c.rows.length)); }
    function show(item, content) {
        if (empty(content) || blocked) {
            hide(item);
            return;
        }
        card = content;
        if (target !== item) {
            target = item;
            shown = false;
            timer.restart();
        }
    }
    function update(item, content) {
        if (item === target)
            card = content;
    }
    function hide(item) {
        if (item && item !== target)
            return;
        timer.stop();
        shown = false;
        target = null;
    }
    Timer {
        id: timer
        interval: tip.delay
        onTriggered: if (tip.target && !tip.empty(tip.card)) tip.shown = true
    }
    FiliTooltipCard {
        id: view
        visible: tip.shown && tip.target !== null
        title: tip.card.title ?? ""
        rows: tip.card.rows ?? []
        text: tip.card.text ?? ""
        mono: tip.card.mono ?? false
        hint: tip.card.hint ?? ""
        readonly property point at: tip.target ? tip.target.mapToItem(tip, tip.target.width / 2, tip.target.height) : Qt.point(0, 0)
        x: Math.max(8, Math.min(tip.width - width - 8, at.x - width / 2))
        y: at.y + 6
    }
}

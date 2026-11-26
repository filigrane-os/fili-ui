// Curve editor of an image editor (the Curves adjustment): a square graph with the input on the horizontal axis and the output on the
// vertical one, both 0..255. `points` is the curve as [[input, output], …] sorted by input; `samples` is the curve to draw between them
// (outputs 0..1 at evenly spaced inputs, from the owner: the engine's own spline), a straight line through the points when empty;
// `histogram` (256 values 0..1) is drawn behind. Click on the graph to add a point, drag a point to move it (it stays between its
// neighbours), double-click it or press Delete to remove it, the arrows move the selected point by 1 (Shift: 10). The owner follows
// `pointsMoved` while the pointer is down (to update `samples`) and applies `pointsCommitted` when it is released.
import QtQuick

Item {
    id: e
    property var points: [[0, 0], [255, 255]]
    property var samples: []
    property var histogram: []
    property color curveColor: FiliTheme.text
    property int maxPoints: 16
    property int selected: -1
    readonly property var selectedPoint: selected >= 0 && selected < drawn.length ? drawn[selected] : null
    signal pointsMoved(var points)
    signal pointsCommitted(var points)

    implicitWidth: 256
    implicitHeight: 256
    activeFocusOnTab: true
    Accessible.role: Accessible.Graphic
    Accessible.name: "Curve"

    // What the graph shows: the points, or the copy being dragged
    property var drawn: points
    property bool dragging: false
    onPointsChanged: if (!dragging) { drawn = points; selected = Math.min(selected, drawn.length - 1); }
    onDrawnChanged: graph.requestPaint()
    onSamplesChanged: graph.requestPaint()
    onHistogramChanged: graph.requestPaint()
    onCurveColorChanged: graph.requestPaint()
    onSelectedChanged: graph.requestPaint()
    Connections {
        target: FiliTheme
        function onLightChanged() { graph.requestPaint(); }
        function onAccentChanged() { graph.requestPaint(); }
    }

    function px(v) { return v / 255 * graph.width; }
    function py(v) { return graph.height - v / 255 * graph.height; }
    function valueX(x) { return Math.max(0, Math.min(255, Math.round(x / graph.width * 255))); }
    function valueY(y) { return Math.max(0, Math.min(255, Math.round((graph.height - y) / graph.height * 255))); }
    // The point under (x, y) within 9 px, or -1
    function hit(x, y) {
        let best = -1, bestD = 81;
        for (let i = 0; i < drawn.length; i++) {
            const d = Math.pow(px(drawn[i][0]) - x, 2) + Math.pow(py(drawn[i][1]) - y, 2);
            if (d < bestD) { best = i; bestD = d; }
        }
        return best;
    }
    function copy() { return drawn.map(p => [p[0], p[1]]); }
    function moveTo(index, x, y) {
        const c = copy();
        const lo = index > 0 ? c[index - 1][0] + 1 : 0;
        const hi = index < c.length - 1 ? c[index + 1][0] - 1 : 255;
        c[index] = [Math.max(lo, Math.min(hi, x)), Math.max(0, Math.min(255, y))];
        drawn = c;
        pointsMoved(c);
    }
    function remove(index) {
        if (drawn.length <= 2 || index < 0)
            return;
        const c = copy();
        c.splice(index, 1);
        drawn = c;
        selected = Math.min(index, c.length - 1);
        pointsMoved(c);
        pointsCommitted(c);
    }
    Keys.onDeletePressed: remove(selected)
    Keys.onPressed: ev => {
        if (selected < 0)
            return;
        const step = ev.modifiers & Qt.ShiftModifier ? 10 : 1;
        const p = drawn[selected];
        const to = { [Qt.Key_Left]: [p[0] - step, p[1]], [Qt.Key_Right]: [p[0] + step, p[1]], [Qt.Key_Up]: [p[0], p[1] + step], [Qt.Key_Down]: [p[0], p[1] - step] }[ev.key];
        if (to) {
            FiliHost.keyboard();
            moveTo(selected, to[0], to[1]);
            pointsCommitted(drawn);
            ev.accepted = true;
        }
    }

    FocusRing { gap: 2 }
    Canvas {
        id: graph
        anchors.fill: parent
        renderTarget: Canvas.Image
        onPaint: {
            const ctx = getContext("2d");
            const w = width, h = height;
            ctx.reset();
            ctx.fillStyle = FiliTheme.backgroundDeep;
            ctx.fillRect(0, 0, w, h);
            // Histogram behind
            if (e.histogram.length > 1) {
                ctx.fillStyle = Qt.rgba(FiliTheme.text.r, FiliTheme.text.g, FiliTheme.text.b, 0.16);
                ctx.beginPath();
                ctx.moveTo(0, h);
                for (let i = 0; i < e.histogram.length; i++)
                    ctx.lineTo(i / (e.histogram.length - 1) * w, h - Math.min(1, e.histogram[i]) * h);
                ctx.lineTo(w, h);
                ctx.closePath();
                ctx.fill();
            }
            // Grid every quarter, the neutral diagonal dashed
            ctx.strokeStyle = FiliTheme.border;
            ctx.lineWidth = 1;
            ctx.beginPath();
            for (let i = 1; i < 4; i++) {
                ctx.moveTo(Math.round(w * i / 4) + 0.5, 0); ctx.lineTo(Math.round(w * i / 4) + 0.5, h);
                ctx.moveTo(0, Math.round(h * i / 4) + 0.5); ctx.lineTo(w, Math.round(h * i / 4) + 0.5);
            }
            ctx.stroke();
            ctx.setLineDash([4, 4]);
            ctx.beginPath();
            ctx.moveTo(0, h); ctx.lineTo(w, 0);
            ctx.stroke();
            ctx.setLineDash([]);
            ctx.strokeRect(0.5, 0.5, w - 1, h - 1);
            // The curve
            ctx.strokeStyle = e.curveColor;
            ctx.lineWidth = 2;
            ctx.lineJoin = "round";
            ctx.beginPath();
            if (e.samples.length > 1) {
                for (let i = 0; i < e.samples.length; i++) {
                    const x = i / (e.samples.length - 1) * w, y = h - Math.max(0, Math.min(1, e.samples[i])) * h;
                    i === 0 ? ctx.moveTo(x, y) : ctx.lineTo(x, y);
                }
            } else {
                for (let i = 0; i < e.drawn.length; i++)
                    i === 0 ? ctx.moveTo(e.px(e.drawn[i][0]), e.py(e.drawn[i][1])) : ctx.lineTo(e.px(e.drawn[i][0]), e.py(e.drawn[i][1]));
            }
            ctx.stroke();
            // The points: a square, filled with the accent when selected
            for (let i = 0; i < e.drawn.length; i++) {
                const x = e.px(e.drawn[i][0]), y = e.py(e.drawn[i][1]);
                ctx.fillStyle = i === e.selected ? FiliTheme.accentColor : FiliTheme.background;
                ctx.strokeStyle = i === e.selected ? FiliTheme.accentColor : e.curveColor;
                ctx.lineWidth = 1.5;
                ctx.fillRect(x - 4, y - 4, 8, 8);
                ctx.strokeRect(x - 4, y - 4, 8, 8);
            }
        }
    }
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: e.hit(mouseX, mouseY) >= 0 ? Qt.SizeAllCursor : Qt.CrossCursor
        property int grabbed: -1
        onPressed: m => {
            e.forceActiveFocus();
            FiliHost.backend && (FiliHost.backend.keyNav = false);
            let i = e.hit(m.x, m.y);
            if (i < 0 && e.drawn.length < e.maxPoints) {
                // A new point where the pointer is, between its neighbours
                const x = e.valueX(m.x);
                if (!e.drawn.some(p => p[0] === x)) {
                    const c = e.copy();
                    i = c.findIndex(p => p[0] > x);
                    if (i < 0) i = c.length;
                    c.splice(i, 0, [x, e.valueY(m.y)]);
                    e.drawn = c;
                    e.pointsMoved(c);
                }
            }
            e.selected = i;
            grabbed = i;
            e.dragging = i >= 0;
        }
        onPositionChanged: m => {
            if (pressed && grabbed >= 0)
                e.moveTo(grabbed, e.valueX(m.x), e.valueY(m.y));
        }
        onReleased: {
            if (grabbed >= 0)
                e.pointsCommitted(e.drawn);
            grabbed = -1;
            e.dragging = false;
        }
        onDoubleClicked: m => e.remove(e.hit(m.x, m.y))
    }
}

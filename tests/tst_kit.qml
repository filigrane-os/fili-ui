// Behaviour of the controls and of the window anatomy, headless (QT_QPA_PLATFORM=offscreen, see scripts/run-tests.sh).
import QtQuick
import QtTest
import Fili.UI

Item {
    id: root
    // First binding of the root: the backend must be set before anything reads FiliTheme (see README)
    readonly property bool kitReady: { FiliHost.backend = backend; return true; }
    width: 500
    height: 900

    QtObject {
        id: backend
        property bool light: false
        property string accent: "default"
        property int settingsRev: 0
        property bool keyNav: false
        function themeJson() {
            const x = new XMLHttpRequest();
            x.open("GET", Qt.resolvedUrl("../demo/theme.json"), false);
            x.send();
            return x.responseText;
        }
    }
    Column {
        spacing: 8
        FiliSwitch { id: sw }
        FiliSwitch { id: swOff; switchable: false }
        FiliCheckBox { id: cb; label: "Check" }
        FiliRadioButton { id: rb; label: "Radio" }
        FiliSlider { id: sl; width: 200; steps: 0 }
        FiliSlider { id: slSteps; width: 200; steps: 4 }
        FiliTextField { id: tf; width: 200; clearable: true; placeholder: "Search" }
        FiliTextField { id: tfPlain; width: 200 }
        FiliSelect { id: se; width: 160; model: [{ label: "One", value: 1 }, { label: "Two", value: 2, off: true }, { label: "Three", value: 3 }]; current: 1 }
        FiliSidebar {
            id: sb
            width: 200
            height: 200
            FiliSidebarSection {
                id: sec
                title: "Favorites"
                FiliSidebarRow { id: row1; label: "Documents"; count: "3" }
                FiliSidebarRow { label: "Pictures" }
            }
        }
        FiliTabBar { id: tabs; width: 400; model: ["A", "B", "C"] }
        FiliViewSwitch { id: vs; mode: "list" }
        FiliButton { id: btn; label: "Go" }
    }

    SignalSpy { id: swSpy; target: sw; signalName: "toggled" }
    SignalSpy { id: swOffSpy; target: swOff; signalName: "toggled" }
    SignalSpy { id: cbSpy; target: cb; signalName: "toggled" }
    SignalSpy { id: rbSpy; target: rb; signalName: "clicked" }
    SignalSpy { id: movedSpy; target: sl; signalName: "moved" }
    SignalSpy { id: stepsSpy; target: slSteps; signalName: "moved" }
    SignalSpy { id: clearedSpy; target: tf; signalName: "cleared" }
    SignalSpy { id: pickedSpy; target: se; signalName: "picked" }
    SignalSpy { id: rowSpy; target: row1; signalName: "clicked" }
    SignalSpy { id: tabSpy; target: tabs; signalName: "tabClicked" }
    SignalSpy { id: orderSpy; target: tabs; signalName: "reordered" }
    SignalSpy { id: btnSpy; target: btn; signalName: "clicked" }
    SignalSpy { id: viewSpy; target: vs; signalName: "chose" }

    TestCase {
        name: "kit"
        when: windowShown

        function init() {
            swSpy.clear(); swOffSpy.clear(); cbSpy.clear(); rbSpy.clear(); movedSpy.clear(); stepsSpy.clear();
            clearedSpy.clear(); viewSpy.clear(); pickedSpy.clear(); rowSpy.clear(); tabSpy.clear(); orderSpy.clear(); btnSpy.clear();
            tf.text = "";
        }
        function center(item) { return item.mapToItem(root, item.width / 2, item.height / 2); }

        function test_switch_asks_the_owner_to_flip() {
            const c = center(sw);
            mouseClick(root, c.x, c.y);
            compare(swSpy.count, 1);
            compare(sw.checked, false, "the switch never flips itself");
            sw.forceActiveFocus();
            keyClick(Qt.Key_Space);
            compare(swSpy.count, 2);
            compare(backend.keyNav, true, "the keyboard was used: the focus ring shows");
        }
        function test_a_switch_that_cannot_be_switched() {
            const c = center(swOff);
            mouseClick(root, c.x, c.y);
            compare(swOffSpy.count, 0);
        }
        function test_check_box_and_radio() {
            let c = center(cb);
            mouseClick(root, c.x, c.y);
            compare(cbSpy.count, 1);
            c = center(rb);
            mouseClick(root, c.x, c.y);
            compare(rbSpy.count, 1);
            rb.checked = true;
            mouseClick(root, c.x, c.y);
            compare(rbSpy.count, 1, "a radio that is already chosen does not ask again");
            rb.checked = false;
        }
        function test_slider_click_and_keys() {
            let p = sl.mapToItem(root, sl.width * 0.75, sl.height / 2);
            mouseClick(root, p.x, p.y);
            verify(movedSpy.count >= 1);
            verify(Math.abs(movedSpy.signalArguments[movedSpy.count - 1][0] - 0.75) < 0.1, "a click moves to the clicked position");
            p = slSteps.mapToItem(root, slSteps.width * 0.5, slSteps.height / 2);
            mouseClick(root, p.x, p.y);
            const v = stepsSpy.signalArguments[stepsSpy.count - 1][0];
            verify([0, 0.25, 0.5, 0.75, 1].some(s => Math.abs(s - v) < 1e-9), "snaps to a step: " + v);
            sl.value = 0.5;
            sl.forceActiveFocus();
            movedSpy.clear();
            keyClick(Qt.Key_Right);
            compare(movedSpy.count, 1);
            verify(Math.abs(movedSpy.signalArguments[0][0] - 0.55) < 1e-9, "right = +5 %");
        }
        function test_search_field_clears() {
            tf.text = "abc";
            const x = tf.mapToItem(root, tf.width - 10, tf.height / 2);
            mouseClick(root, x.x, x.y);
            compare(tf.text, "");
            compare(clearedSpy.count, 1);
            tf.text = "xyz";
            tf.focusField();
            keyClick(Qt.Key_Escape);
            compare(tf.text, "", "Esc clears too");
            compare(clearedSpy.count, 2);
        }
        function test_a_plain_field_has_no_clear_button() {
            tfPlain.text = "abc";
            tfPlain.focusField();
            keyClick(Qt.Key_Escape);
            compare(tfPlain.text, "abc");
            tfPlain.text = "";
        }
        function test_select_chooses_and_skips_unavailable() {
            se.open();
            compare(se.opened, true);
            se.pick(1);
            compare(pickedSpy.count, 0, "an unavailable choice is refused");
            se.open();
            se.pick(2);
            compare(pickedSpy.count, 1);
            compare(pickedSpy.signalArguments[0][0], 3);
            compare(se.opened, false);
            se.open();
            se.forceActiveFocus();
            keyClick(Qt.Key_Escape);
            compare(se.opened, false);
            compare(pickedSpy.count, 1, "Esc closes without choosing");
        }
        function test_select_keyboard_skips_unavailable() {
            se.current = 1;
            se.forceActiveFocus();
            keyClick(Qt.Key_Down);
            compare(se.opened, true);
            keyClick(Qt.Key_Down);
            compare(se.cursor, 2, "the unavailable Two is skipped");
            keyClick(Qt.Key_Return);
            compare(pickedSpy.signalArguments[pickedSpy.count - 1][0], 3);
        }
        function test_sidebar_section_folds_and_rows_click() {
            compare(row1.visible, true);
            const h = sec.mapToItem(root, 40, FiliTheme.space4 + FiliTheme.sideRowHeight / 2);
            mouseClick(root, h.x, h.y);
            compare(sec.folded, true);
            compare(row1.visible, false, "folded rows are hidden");
            mouseClick(root, h.x, h.y);
            compare(sec.folded, false);
            const p = center(row1);
            mouseClick(root, p.x, p.y);
            compare(rowSpy.count, 1);
        }
        function test_tabs_click_and_reorder() {
            // The tabs are the Repeater's items, in the Row (the first child of the bar)
            const row = tabs.children[0];
            const t0 = row.children[0], t2 = row.children[2];
            const c0 = t0.mapToItem(root, t0.width / 2, t0.height / 2), c2 = t2.mapToItem(root, t2.width / 2, t2.height / 2);
            mouseClick(root, c0.x, c0.y);
            compare(tabSpy.count, 1);
            tabSpy.clear();
            mousePress(root, c0.x, c0.y);
            mouseMove(root, c0.x + 10, c0.y);
            mouseMove(root, c2.x, c2.y);
            mouseRelease(root, c2.x, c2.y);
            compare(orderSpy.count, 1);
            compare(orderSpy.signalArguments[0][0], 0);
            compare(orderSpy.signalArguments[0][1], 2);
            compare(tabSpy.count, 0, "the release of a drag is not a click");
        }
        function test_view_switch() {
            // The segments are the capsule's children: list on the left, grid on the right
            const grid = vs.children[2];
            let c = grid.mapToItem(root, grid.width / 2, grid.height / 2);
            mouseClick(root, c.x, c.y);
            compare(viewSpy.count, 1);
            compare(viewSpy.signalArguments[0][0], "grid");
            compare(vs.mode, "list", "the owner sets the mode, the switch never changes it");
            const list = vs.children[1];
            c = list.mapToItem(root, list.width / 2, list.height / 2);
            mouseClick(root, c.x, c.y);
            compare(viewSpy.count, 1, "choosing the mode already shown does nothing");
            vs.forceActiveFocus();
            keyClick(Qt.Key_Right);
            compare(viewSpy.count, 2);
            compare(viewSpy.signalArguments[1][0], "grid");
        }
        function test_button_keyboard() {
            btn.forceActiveFocus();
            keyClick(Qt.Key_Return);
            compare(btnSpy.count, 1);
        }
    }
}

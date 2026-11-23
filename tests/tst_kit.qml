// Behaviour of the controls and of the window anatomy, headless (QT_QPA_PLATFORM=offscreen, see scripts/run-tests.sh).
import QtQuick
import QtQuick.Layouts
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
        FiliLayerRow { id: layerRow; width: 200; label: "Curves"; detail: "80 %"; onVisibilityToggled: shown => layerVisible = shown }
        FiliToolStrip {
            id: toolStrip
            height: 300
            model: [{ id: "move", icon: "move", tip: "Move" }, { sep: true }, { id: "brush", icon: "brush", tip: "Brush", variants: true }, { id: "hand", icon: "hand", tip: "Hand" }]
            current: "move"
        }
        FiliOptionsBar { id: optionsBar; width: 400; closeButton: true; FiliCheckBox { id: optionsCheck; label: "Auto" } }
        FiliDock {
            id: dock
            height: 240
            FiliDockGroup {
                id: dockGroup
                Layout.fillWidth: true
                Layout.fillHeight: true
                tabs: ["One", "Two", "Three"]
                Rectangle { id: panelOne; color: "red" }
                Rectangle { id: panelTwo; color: "green" }
                Rectangle { id: panelThree; color: "blue" }
            }
        }
        FiliTabBar { id: tabs; width: 400; model: ["A", "B", { label: "C", count: "3" }]; addable: true }
        FiliViewSwitch { id: vs; mode: "list" }
        FiliButton { id: btn; label: "Go" }
        FiliHeader {
            id: hdr
            width: 480
            title: "Title"
            subtitle: "Second line"
            closeButton: true
            leading: [FiliNavCapsule { id: hdrNav }]
            FiliIconButton { id: hdrIcon; glyph: "x" }
            FiliViewSwitch { id: hdrView }
            FiliTextField { id: hdrSearch; clearable: true }
        }
        FiliIcon { id: ico; name: "x"; size: 24; color: "#ffffff" }
        FiliAvatar { id: avatar; name: "Ada" }
    }
    FiliDialog {
        id: dlg
        title: "Rename"
        FiliTextField { id: dlgField; width: parent.width; text: "x" }
    }
    FiliAboutCard { id: aboutCard; appName: "App"; rows: [["Version", "1"]] }
    FiliShortcutsCard { id: shortcutsCard; groups: [{ title: "G", rows: [["Ctrl+X", "Cut"]] }] }
    FiliMenu { id: menu }
    FiliTooltip { id: tooltip }
    FiliPanel { id: panel; settingsPage: "sound"; FiliPanelSection { text: "OUTPUT"; divided: false } }
    FiliSettings { id: settings; pages: [{ id: "a", label: "A" }, { id: "b", label: "B" }]; Text { text: "page" } }
    Item { id: anchorItem; x: 200; y: 40; width: 30; height: 30 }

    SignalSpy { id: swSpy; target: sw; signalName: "toggled" }
    SignalSpy { id: swOffSpy; target: swOff; signalName: "toggled" }
    SignalSpy { id: cbSpy; target: cb; signalName: "toggled" }
    SignalSpy { id: rbSpy; target: rb; signalName: "clicked" }
    SignalSpy { id: movedSpy; target: sl; signalName: "moved" }
    SignalSpy { id: stepsSpy; target: slSteps; signalName: "moved" }
    SignalSpy { id: clearedSpy; target: tf; signalName: "cleared" }
    SignalSpy { id: pickedSpy; target: se; signalName: "picked" }
    SignalSpy { id: rowSpy; target: row1; signalName: "clicked" }
    SignalSpy { id: layerSpy; target: layerRow; signalName: "clicked" }
    SignalSpy { id: toolSpy; target: toolStrip; signalName: "picked" }
    SignalSpy { id: optionsCloseSpy; target: optionsBar; signalName: "closeRequested" }
    SignalSpy { id: tabSpy; target: tabs; signalName: "tabClicked" }
    SignalSpy { id: orderSpy; target: tabs; signalName: "reordered" }
    SignalSpy { id: closeSpy; target: tabs; signalName: "closeRequested" }
    SignalSpy { id: detachSpy; target: tabs; signalName: "detachRequested" }
    SignalSpy { id: tabCtxSpy; target: tabs; signalName: "contextRequested" }
    SignalSpy { id: addSpy; target: tabs; signalName: "addRequested" }
    SignalSpy { id: btnSpy; target: btn; signalName: "clicked" }
    SignalSpy { id: dlgAccepted; target: dlg; signalName: "accepted" }
    SignalSpy { id: dlgRejected; target: dlg; signalName: "rejected" }
    SignalSpy { id: menuSpy; target: menu; signalName: "activated" }
    SignalSpy { id: gearSpy; target: panel; signalName: "settingsRequested" }
    SignalSpy { id: settingsClosed; target: settings; signalName: "closed" }
    SignalSpy { id: viewSpy; target: vs; signalName: "chose" }

    TestCase {
        name: "kit"
        when: windowShown

        function init() {
            swSpy.clear(); swOffSpy.clear(); cbSpy.clear(); rbSpy.clear(); movedSpy.clear(); stepsSpy.clear();
            clearedSpy.clear(); viewSpy.clear(); dlgAccepted.clear(); dlgRejected.clear(); menuSpy.clear(); dlg.close(); menu.close(); gearSpy.clear(); settingsClosed.clear(); tooltip.hide(); tooltip.blocked = false; panel.close(); settings.close(); aboutCard.close(); shortcutsCard.close(); pickedSpy.clear(); rowSpy.clear(); tabSpy.clear(); orderSpy.clear(); closeSpy.clear(); detachSpy.clear(); tabCtxSpy.clear(); addSpy.clear(); tabs.closable = true; tabs.detachable = true; btnSpy.clear();
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
        function test_layer_row_selects_and_its_eye_only_toggles() {
            layerSpy.clear();
            layerRow.layerVisible = true;
            const p = layerRow.mapToItem(root, layerRow.width / 2, layerRow.height / 2);
            mouseClick(root, p.x, p.y);
            compare(layerSpy.count, 1, "a click on the row selects");
            const e = layerRow.mapToItem(root, FiliTheme.margin + 8, layerRow.height / 2);
            mouseClick(root, e.x, e.y);
            compare(layerRow.layerVisible, false, "the eye hides the layer");
            compare(layerSpy.count, 1, "the eye does not select");
        }
        function test_tool_strip_picks_a_tool_and_ignores_separators() {
            toolSpy.clear();
            const cell = i => toolStrip.children[1].children[i];   // children[0] is the border line, [1] the column of tools
            const c = cell(2).mapToItem(root, 16, 16);
            mouseClick(root, c.x, c.y);
            compare(toolSpy.count, 1);
            compare(toolSpy.signalArguments[0][0], "brush");
            const s = cell(1).mapToItem(root, 16, 4);
            mouseClick(root, s.x, s.y);
            compare(toolSpy.count, 1, "a separator picks nothing");
        }
        function test_options_bar_closes_and_lays_out_its_options() {
            optionsCloseSpy.clear();
            const p = optionsBar.mapToItem(root, optionsBar.width - 14 - (optionsBar.height - 24) / 2, optionsBar.height / 2);
            mouseClick(root, p.x, p.y);
            compare(optionsCloseSpy.count, 1);
            verify(optionsCheck.mapToItem(optionsBar, 0, 0).x >= FiliTheme.margin, "options start at the margin");
        }
        function test_dock_group_shows_only_the_current_panel_and_fills() {
            compare(panelOne.visible, true);
            compare(panelTwo.visible, false);
            compare(panelThree.visible, false);
            dockGroup.currentIndex = 2;
            compare(panelOne.visible, false);
            compare(panelThree.visible, true);
            verify(panelThree.width === dockGroup.width && panelThree.height > 0, "the panel fills the group");
            dockGroup.currentIndex = 0;
        }
        function test_dock_is_resized_by_its_edge_within_its_limits() {
            const w0 = dock.width;
            const e = dock.mapToItem(root, 2, 100);
            mousePress(root, e.x, e.y);
            mouseMove(root, e.x - 60, e.y);
            mouseRelease(root, e.x - 60, e.y);
            compare(dock.dockWidth, Math.min(dock.maxWidth, w0 + 60));
            const e2 = dock.mapToItem(root, 2, 100);   // the edge has moved with the new width
            mousePress(root, e2.x, e2.y);
            mouseMove(root, e2.x + 1000, e2.y);
            mouseRelease(root, e2.x + 1000, e2.y);
            compare(dock.dockWidth, dock.minWidth);
        }
        // The tabs are the Repeater's items in the strip (the first child of the bar)
        function tabItem(i) { return tabs.children[0].children[i]; }
        function tabCenter(i) { const t = tabItem(i); return t.mapToItem(root, t.width / 2, t.height / 2); }
        function test_tabs_click() {
            const c = tabCenter(1);
            mouseClick(root, c.x, c.y);
            compare(tabSpy.count, 1);
            compare(tabSpy.signalArguments[0][0], 1);
        }
        function test_tabs_reorder_with_the_others_making_room() {
            const c0 = tabCenter(0), c2 = tabCenter(2);
            mousePress(root, c0.x, c0.y);
            mouseMove(root, c0.x + 10, c0.y);
            mouseMove(root, c2.x, c2.y);
            compare(tabs.dragFrom, 0);
            compare(tabs.dragTo, 2);
            compare(tabs.shiftOf(1), -tabs.slot, "the tabs it passes shift to make room");
            compare(tabs.shiftOf(2), -tabs.slot);
            mouseRelease(root, c2.x, c2.y);
            compare(orderSpy.count, 1);
            compare(orderSpy.signalArguments[0][0], 0);
            compare(orderSpy.signalArguments[0][1], 2);
            compare(tabSpy.count, 0, "the release of a drag is not a click");
            compare(detachSpy.count, 0);
            compare(tabs.dragFrom, -1);
        }
        function test_tab_dragged_far_from_the_bar_is_detached() {
            const c1 = tabCenter(1);
            mousePress(root, c1.x, c1.y);
            mouseMove(root, c1.x + 5, c1.y);
            mouseMove(root, c1.x + 5, -60);
            compare(tabs.leaving, true, "half transparent: it will become a window");
            mouseRelease(root, c1.x + 5, -60);
            compare(detachSpy.count, 1);
            compare(detachSpy.signalArguments[0][0], 1);
            compare(orderSpy.count, 0, "a detached tab is not reordered");
            compare(tabSpy.count, 0);
        }
        function test_a_tab_that_cannot_be_detached_stays() {
            tabs.detachable = false;
            const c1 = tabCenter(1);
            mousePress(root, c1.x, c1.y);
            mouseMove(root, c1.x + 5, c1.y);
            mouseMove(root, c1.x + 5, -60);
            mouseRelease(root, c1.x + 5, -60);
            compare(detachSpy.count, 0);
        }
        function test_tab_close_button_middle_click_and_delete() {
            // The × shows on the current tab, at its right edge
            tabs.currentIndex = 0;
            const t = tabItem(0), x = t.mapToItem(root, t.width - 12, t.height / 2);
            mouseClick(root, x.x, x.y);
            compare(closeSpy.count, 1);
            compare(closeSpy.signalArguments[0][0], 0);
            const c1 = tabCenter(1);
            mouseClick(root, c1.x, c1.y, Qt.MiddleButton);
            compare(closeSpy.count, 2);
            compare(closeSpy.signalArguments[1][0], 1);
            tabItem(2).forceActiveFocus();
            keyClick(Qt.Key_Delete);
            compare(closeSpy.count, 3);
            compare(closeSpy.signalArguments[2][0], 2);
            tabs.closable = false;
            mouseClick(root, c1.x, c1.y, Qt.MiddleButton);
            keyClick(Qt.Key_Delete);
            compare(closeSpy.count, 3, "nothing closes when tabs are not closable");
        }
        function test_tab_context_menu_and_add_button() {
            const c0 = tabCenter(0);
            mouseClick(root, c0.x, c0.y, Qt.RightButton);
            compare(tabCtxSpy.count, 1);
            compare(tabCtxSpy.signalArguments[0][0], 0);
            const add = tabs.children[0].children[tabs.count + 1];
            const a = add.mapToItem(root, add.width / 2, add.height / 2);
            mouseClick(root, a.x, a.y);
            compare(addSpy.count, 1);
        }
        function test_tab_keyboard_moves_chooses_and_reorders() {
            tabItem(1).forceActiveFocus();
            keyClick(Qt.Key_Right);
            compare(tabSpy.signalArguments[tabSpy.count - 1][0], 2);
            keyClick(Qt.Key_Left);
            compare(tabSpy.signalArguments[tabSpy.count - 1][0], 0);
            keyClick(Qt.Key_Right, Qt.ControlModifier | Qt.ShiftModifier);
            compare(orderSpy.count, 1);
            compare(orderSpy.signalArguments[0][0], 1);
            compare(orderSpy.signalArguments[0][1], 2);
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
        // The bug that was seen: a capsule of 30 beside buttons of 24 must share one centre line, not one top edge
        function test_header_tools_share_a_centre_line() {
            const mid = item => item.mapToItem(root, 0, item.height / 2).y;
            const ref = mid(hdrView);
            verify(Math.abs(mid(hdrIcon) - ref) < 1, "icon button centre " + mid(hdrIcon) + " vs " + ref);
            verify(Math.abs(mid(hdrSearch) - ref) < 1, "search field centre");
            verify(Math.abs(mid(hdrNav) - ref) < 1, "back/forward capsule centre");
            verify(hdrSearch.mapToItem(root, hdrSearch.width, 0).x <= hdr.mapToItem(root, hdr.width - FiliTheme.space3 - 20, 0).x, "room before the close button");
        }
        // The two lines are one block centred in the header: as much room above the capitals of the title as below the baseline of the second line
        function test_header_text_block_is_centred() {
            const above = hdr.titleBaseline - hdr.capHeight, below = hdr.height - hdr.subtitleBaseline;
            verify(Math.abs(above - below) < 1.5, "room above " + above + " vs below " + below);
            verify(hdr.subtitleBaseline - hdr.titleBaseline < 2 * FiliTheme.sizeList, "the lines are close together");
        }
        function test_dialog_buttons_keys_and_scrim() {
            dlg.open();
            compare(dlg.visible, true);
            keyClick(Qt.Key_Escape);
            compare(dlg.visible, false);
            compare(dlgRejected.count, 1);
            dlg.open();
            keyClick(Qt.Key_Return);
            compare(dlgAccepted.count, 1);
            compare(dlg.visible, false);
            dlg.confirmEnabled = false;
            dlg.open();
            keyClick(Qt.Key_Return);
            compare(dlgAccepted.count, 1, "Enter does nothing while the main action is unavailable");
            compare(dlg.visible, true);
            dlg.confirmEnabled = true;
            mouseClick(root, 2, root.height - 2);
            compare(dlg.visible, false);
            compare(dlgRejected.count, 2, "a click on the scrim rejects");
        }
        function test_information_cards_close_with_the_keys_they_name() {
            aboutCard.show();
            compare(aboutCard.visible, true);
            keyClick(Qt.Key_Return);
            compare(aboutCard.visible, false);
            compare(dlgAccepted.count, 0);
            shortcutsCard.show();
            keyClick(Qt.Key_F1);
            compare(shortcutsCard.visible, false);
        }
        function test_menu_skips_separators_and_unavailable_entries() {
            menu.open(20, 20, [{ id: "a", label: "A" }, { separator: true }, { id: "b", label: "B", enabled: false }, { id: "c", label: "C", danger: true }]);
            compare(menu.visible, true);
            keyClick(Qt.Key_Down);
            compare(menu.current, 0);
            keyClick(Qt.Key_Down);
            compare(menu.current, 3, "the separator and the unavailable B are skipped");
            keyClick(Qt.Key_Return);
            compare(menuSpy.count, 1);
            compare(menuSpy.signalArguments[0][0], "c");
            compare(menu.visible, false);
        }
        function test_menu_submenu_and_escape() {
            menu.openAt(20, 20, [{ id: "m", label: "More", children: [{ id: "x", label: "X" }, { id: "y", label: "Y" }] }]);
            keyClick(Qt.Key_Down);
            keyClick(Qt.Key_Right);
            compare(menu.subOpen, true);
            keyClick(Qt.Key_Down);
            keyClick(Qt.Key_Return);
            compare(menuSpy.signalArguments[0][0], "y");
            menu.openAt(20, 20, [{ id: "z", label: "Z" }]);
            keyClick(Qt.Key_Escape);
            compare(menu.visible, false);
            compare(menuSpy.count, 1, "Esc chooses nothing");
        }
        // Drawn by Shapes: it must show under the software renderer of the Filigrane session too
        function test_icon_is_drawn() {
            wait(100);
            const g = grabImage(ico);
            let lit = 0;
            for (let x = 0; x < 24; ++x) for (let y = 0; y < 24; ++y) { const c = g.pixel(x, y); if (c.a > 0.3) lit++; }
            verify(lit > 10, "the x icon has pixels: " + lit);
        }
        function test_avatar_without_a_picture_shows_the_initial() {
            compare(avatar.loaded, false);
        }
        function test_tooltip_opens_after_a_delay_and_not_when_blocked() {
            tooltip.show(anchorItem, { title: "T", text: "x" });
            compare(tooltip.shown, false, "not at once");
            tryCompare(tooltip, "shown", true, 1500);
            tooltip.hide(anchorItem);
            compare(tooltip.shown, false);
            tooltip.blocked = true;
            tooltip.show(anchorItem, { title: "T", text: "x" });
            wait(550);
            compare(tooltip.shown, false, "nothing while a panel is open");
            tooltip.blocked = false;
            tooltip.show(anchorItem, {});
            wait(550);
            compare(tooltip.shown, false, "an empty card is never shown");
        }
        function test_panel_toggles_and_closes_with_esc() {
            panel.toggle(anchorItem);
            compare(panel.opened, true);
            panel.toggle(anchorItem);
            compare(panel.opened, false, "the same item again closes it");
            panel.openAt(anchorItem);
            keyClick(Qt.Key_Escape);
            compare(panel.opened, false);
        }
        function test_panel_gear_opens_the_settings_page() {
            panel.openAt(anchorItem);
            const card = panel.children[1];
            const g = card.mapToItem(root, card.width - 14, 14);
            mouseClick(root, g.x, g.y);
            compare(gearSpy.count, 1);
            compare(gearSpy.signalArguments[0][0], "sound");
            compare(panel.opened, false, "the panel closes first");
        }
        function test_panel_click_elsewhere_closes() {
            panel.openAt(anchorItem);
            mouseClick(root, 2, root.height - 2);
            compare(panel.opened, false);
        }
        function test_settings_pages_and_esc() {
            settings.open("b");
            compare(settings.opened, true);
            compare(settings.page, "b");
            settings.open("unknown");
            compare(settings.page, "b", "an unknown page keeps the current one");
            keyClick(Qt.Key_Escape);
            compare(settings.opened, false);
            compare(settingsClosed.count, 1);
        }
        function test_button_keyboard() {
            btn.forceActiveFocus();
            keyClick(Qt.Key_Return);
            compare(btnSpy.count, 1);
        }
    }
}

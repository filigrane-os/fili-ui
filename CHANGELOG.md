# Changelog

## Unreleased

- `FiliTabBar` items take `closable: false` (a fixed tab, such as the categories of a mailbox: no ×, no middle click, no Delete).

- `FiliTextField.secret`: dots instead of the text (passwords), no ×; `readOnly`, `inputMethodHints` and `tabNext` (the field Tab goes to), for the account forms of Facteur.

- `FiliTabBar` scrolls with the wheel when the tabs do not fit (each keeps 80 at least) and keeps the current tab in view (`overflows`, `scrollX`): Facteur's many pinned folders.

- `FiliAvatar` shows its picture: the Canvas never said `imageLoaded` for a picture already read by the probe image, so it stayed hidden behind the initial. Tested with a real picture (`tests/avatar.png`).

- `FiliShortcutsCard`: a long description (or key combination) wraps onto several lines instead of being cut with an ellipsis.

- `FiliTabBar` items take `dots` (colours of small discs before the label, such as the platforms of a conversation); `FiliTextField.selectAll()` and `blurField()`.

- `FiliDebugPanel`: the header goes on two lines when the panel is narrow (a drawer): title and filters, then the actions; one line as before when it fits.

- `FiliIconButton` draws a line icon of the kit when `name` is set (`filled`, `iconSize`, 16 by default), the font glyph otherwise: the toolbar buttons of Facteur, Conversations and Aeroport.
- `FiliTabBar` items take an `icon` (a FiliIcon name before the label), an `iconColor` and `spin` (the icon turns while the window is active): a command running, a check, a bell.

## 0.3.0

- `FiliTabBar` is the one tab row of every application and a tab can always be moved, closed and detached, the same way everywhere
  (it merges what Casier, Facteur and Conversations each wrote): drag a tab sideways, it follows the pointer and the others make room
  (`reordered(from, to)`; Ctrl+Shift+Left / Right on the keyboard); the × on hover and on the current tab, a middle click or Delete
  closes it (`closeRequested`); dragged far from the bar it turns half transparent and becomes a window (`detachRequested`);
  right click `contextRequested`; the + button (`addable`, `addRequested`); files dragged over a tab (`tabDropped`, resting on one
  for `springDelay` selects it); a muted `count` after the label; `closable` and `detachable` to switch a behaviour off.
- The demo's tab row shows all of it (close, add, detach, move, menu).

## 0.2.0

The controls and the window anatomy the applications were still writing by hand, from the Filigrane HIG and the application
window page (`agents/skills/filigrane-ui/references/app-window.md`).

- Controls: `FiliSwitch`, `FiliCheckBox`, `FiliRadioButton`, `FiliSlider` (0..1, steps, keyboard), `FiliTextField` (placeholder,
  accent border on focus, × and Esc clear it when `clearable`), `FiliSelect` (list drawn over the whole window, keyboard,
  unavailable choices), `FiliProgressBar` (determinate or indeterminate).
- Window anatomy: `FiliHeader` (44, title and second line, `leading` / `tools`, close button), `FiliNavCapsule`, `FiliViewSwitch` (the list / icons capsule),
  `FiliSidebar` with `FiliSidebarSection` (foldable header) and `FiliSidebarRow` (glyph or icon, count, selected), `FiliFooter`
  (28, left and right text, error), `FiliTabBar` (40 band, 28 tabs, drag to reorder: `reordered(from, to)`).
- From the other applications (Facteur, Conversations, Aeroport, Baladeur, Cassette, Lia), where each kept its own copy:
  `FiliDialog` (the modal card: title, content, Cancel and the main action), `FiliMenu` (context menu: separators, shortcuts, check
  marks, submenus, unavailable and `danger` entries, width fitted to the longest label), `FiliAboutCard`, `FiliShortcutsCard`,
  `FiliWindowPanel` (niri's window actions), `FiliLiaButton`, `FiliDebugPanel` (the log panel), `FiliIcon` (the 49 line icons of the
  three apps that had one), `FiliSpinner` (the logo's veils), `FiliAvatar` (round picture drawn without a shader mask).
- The three cards of the fili-shell, so that the bar, the panel and the settings are defined once: `FiliTooltip` / `FiliTooltipCard`
  (under the hovered item after 400 ms, read-only: title, label / value rows with a gauge that turns `warning` from 80 % and `danger` from
  95 %, hint line), `FiliPanel` (340 wide, sections, buttons, sliders, switches, a gear to the matching settings page,
  `FiliPanelSection`, `FiliPanelButton`), `FiliSettings` (640 wide: list of pages, the chosen page, close button). The demo's "Fili-bar"
  tab is a bar whose icons show them: hover, click, gear.
- The two lines of a header are one block centred vertically (title `sizeList` over a `sizeSmall` line, baselines `sizeList + 2` apart), measured with the font so it holds for any theme font; a test covers it.
- What an application gives these components is listed in `docs/host-contract.md`; `FiliHost.tr()` translates.
- Components have implicit sizes, and the header lays its tools out in a `RowLayout`: a 30 high capsule and 24 high buttons share one
  centre line, and the tools keep `space3` from the close button (they were top-aligned and 4 px from it). A test covers it.
- `FiliHost.keyboard()`: the controls tell the application that the keyboard was used, so the focus ring shows.
- Demo (`make demo`) is now a whole window with every part and control, a Colors page (the tokens) and a Type page, with the
  Jost and Fili Icons fonts it ships (licenses next to them).
- Behaviour tests (`scripts/run-tests.sh`, run by `make check`): 26 headless tests of the controls, the sidebar and the tabs, and
  a guard against shader effects (the Filigrane session renders in software, where they draw nothing).

## 0.1.0

First version: the QML module `Fili.UI` as a crate (cxx-qt-build interface).

- `FiliHost` (the link with the application's theme object) and `FiliTheme` (tokens of the fili-shell).
- `FocusRing`, `KineticScroll`, `FiliScrollBar`, `FiliButton`, `FiliIconButton`, `WindowGlyph`, taken from the copies of
  the fili-* applications (see `docs/inventory.md`).
- The build exports the path of `FiliTheme.qml` to dependents (`DEP_FILI_UI_THEME_QML`) so each application can check the
  `FiliTheme.*` names its QML uses.

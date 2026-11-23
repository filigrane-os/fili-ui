# Changelog

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
- The title of a two-line header has fixed line heights, so it keeps its air above and below.
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

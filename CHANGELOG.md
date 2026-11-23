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
- `FiliHost.keyboard()`: the controls tell the application that the keyboard was used, so the focus ring shows.
- Demo (`make demo`) is now a whole window with every part and control, a Colors page (the tokens) and a Type page, with the
  Jost and Fili Icons fonts it ships (licenses next to them).
- Behaviour tests (`scripts/run-tests.sh`, run by `make check`): 12 headless tests of the controls, the sidebar and the tabs, and
  a guard against shader effects (the Filigrane session renders in software, where they draw nothing).

## 0.1.0

First version: the QML module `Fili.UI` as a crate (cxx-qt-build interface).

- `FiliHost` (the link with the application's theme object) and `FiliTheme` (tokens of the fili-shell).
- `FocusRing`, `KineticScroll`, `FiliScrollBar`, `FiliButton`, `FiliIconButton`, `WindowGlyph`, taken from the copies of
  the fili-* applications (see `docs/inventory.md`).
- The build exports the path of `FiliTheme.qml` to dependents (`DEP_FILI_UI_THEME_QML`) so each application can check the
  `FiliTheme.*` names its QML uses.

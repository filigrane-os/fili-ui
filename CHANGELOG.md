# Changelog

## 0.1.0

First version: the QML module `Fili.UI` as a crate (cxx-qt-build interface).

- `FiliHost` (the link with the application's theme object) and `FiliTheme` (tokens of the fili-shell).
- `FocusRing`, `KineticScroll`, `FiliScrollBar`, `FiliButton`, `FiliIconButton`, `WindowGlyph`, taken from the copies of
  the fili-* applications (see `docs/inventory.md`).
- The build exports the path of `FiliTheme.qml` to dependents (`DEP_FILI_UI_THEME_QML`) so each application can check the
  `FiliTheme.*` names its QML uses.

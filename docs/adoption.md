# Adopting Fili.UI in an application

Done for Casier (fili-file) on its branch `try-fili-ui`; the same five edits for every fili-* application.

1. `Cargo.toml`: `fili-ui = { git = "https://github.com/filigrane-os/fili-ui", tag = "vX.Y.Z" }` (a `path` while developing
   both). Never a branch.
2. `build.rs`: `.depend("Fili.UI")` on the application's QML module; delete the local copies from its file list and from
   `qml/` (`FocusRing`, `KineticScroll`, `FiliScrollBar`, `WindowGlyph`, `TextButton` → `FiliButton`, `IconButton` →
   `FiliIconButton`, `FiliTheme`). Forward the token file to the tests:
   `if let Ok(p) = env::var("DEP_FILI_UI_THEME_QML") { println!("cargo::rustc-env=FILI_UI_THEME_QML={p}") }`, and let the
   test that checks the `FiliTheme.*` names read `env!("FILI_UI_THEME_QML")`.
3. `src/main.rs`: `use fili_ui as _;`. Without a reference Rust does not link the crate, and the link fails on
   `cxx_qt_init_crate_fili_ui`.
4. QML: `import Fili.UI` in every file that uses a kit type, and in the root item, as its FIRST property:
   `readonly property bool kitReady: { FiliHost.backend = Fili; return true; }` (the application's own object; it needs
   `light`, `accent`, `settingsRev`, `keyNav`, `themeJson()`). Anything later (a `Binding` child, `onCompleted`) lets the
   first tokens be 0 and shifts every `ListView` whose margin depends on them.
5. Compare before and after at the pixel level in several states (list, grid, panels) with the application's `ctl`
   commands, each run with its own `XDG_STATE_HOME` and a short `XDG_RUNTIME_DIR` (the `ctl` socket path must stay under
   108 bytes). Two builds in one `CARGO_TARGET_DIR` share `qml_modules/`: run `cargo clean -p <app>` between them.

Specifics left in the application: tokens that only it uses (`terminalColors` in fili-term), the line icons until
`Icon.qml` is in the kit, fili-ai's `Theme.qml` (to be replaced by `FiliTheme`).

## In the Filigrane repository, when an application is pinned to a kit version

- `tests/fili-shell/check-app-shell-parity.py`: it compares the application's `qml/KineticScroll.qml` with the shell's;
  compare the kit's file instead, and read the tokens from the kit's `FiliTheme.qml`.
- `tests/fili-shell/check-app-window.py`: `SHARED` lists `FiliScrollBar`, `KineticScroll` and `WindowGlyph` as files of the
  application; they come from the kit now.
- Document the kit in the `filigrane-ui` skill (components and how to get them) so no agent writes a new button again.

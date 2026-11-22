# Inventory of the shared QML components (2026-11-22)

Compared across fili-file, fili-term, fili-mail, fili-im, fili-music, fili-recorder and fili-ai (window).

## What the copies really differ by

Byte hashes differ everywhere, but for most files only two things change: the QML module line (`import Fili.Files`,
`Fili.Term`…) and the name of the per-app Rust singleton (`Fili`, `Aeroport`, `Facteur`, `Conversations`) used for
`light`, `accent`, `settingsRev`, `themeJson()` and `keyNav`. That coupling is why the files were copied instead of
shared. The kit removes it with `FiliHost.backend`.

| Component | Copies | Real divergence | Kit |
|---|---|---|---|
| KineticScroll | 7 | none (identical bytes) | as is |
| WindowGlyph | 6 | none beyond the import | as is |
| FiliScrollBar | 7 | none; fili-ai calls its theme `Theme` instead of `FiliTheme` | as is |
| FocusRing | 6 | reads the app singleton's `keyNav` | reads `FiliHost.backend.keyNav` |
| FiliTheme | 6 (+ `Theme` in fili-ai, 52 lines) | term has no `settingsRev` (no live reload) and adds `terminalColors`; fili-ai's is a smaller, separate file | one file, host-driven; `terminalColors` stays in fili-term |
| TextButton | 7 | mail and im add Tab focus, Return/Enter/Space, `FocusRing`; the others cannot be reached by keyboard | `FiliButton` = superset, plus `enabledState` |
| IconButton | 7, four variants | file/recorder: font glyph, 32 lines; music: + `size`; mail/im: + line `Icon`, `toggled`, `accented`, `ToolTip`; term: + `hint`, accessible name, tip drawn by the window; fili-ai: 28px square, own colours | `FiliIconButton` = glyph + toggle + accent band + window-drawn tip |

Consequence: the keyboard-access fix exists only in two of seven apps, and the tip cost (Qt Quick Controls `ToolTip`,
about 3 MB per window process, measured by fili-term) is paid by mail and im.

## Not in the kit yet (next batch)

- `Icon.qml` (line icons, in mail/im/term), needed to complete `FiliIconButton`.
- Text input, switch, slider, select, checkbox. The apps hand-roll these in their own `Main.qml`; the fili-shell has
  `controls/Panel*.qml` with the reference look. Inventory them app by app before porting.
- Anatomy: header (44), sidebar (200, collapsible sections), footer (28), tabs, `DebugPanel`, `LiaButton`,
  `ContextMenu`, About card. These are large and bound to app logic; port them after the controls.
- fili-ai's `Theme.qml`: migrate to `FiliTheme` (its tokens are a subset).

## Distribution (open question)

The applications embed their QML in the binary (cxx-qt, `qrc:/qt/qml/Fili/<App>/`) and are installed without root.
A system-wide QML import path would break that, so the options are:

1. A Rust crate `fili-ui` that exposes the QML files and the helper to register the module in each app's `build.rs`
   (pinned by tag like the other dependencies; binaries stay self-contained). Recommended; to be prototyped in
   fili-file against the cxx-qt-build 0.10 API.
2. A sync script that copies the files into each repository, with a parity test. Simple but it is today's problem again.
3. A system package under `/usr/share/filigrane/qml`. Rejected: not self-contained.

The fili-shell (Quickshell) shares tokens, not components: its `controls/Panel*.qml` stay, and a test keeps the token
names and default values equal (already done for `theme.toml`).

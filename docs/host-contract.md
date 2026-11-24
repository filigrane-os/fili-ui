# What an application gives the kit (`FiliHost.backend`)

The kit imports nothing from an application. At startup the application sets, in the first binding of its root item,
`FiliHost.backend = <its Rust object>` (README). The components only call the members below; a component that needs none of
them works with a bare backend.

| Needed by | Members of the backend |
|---|---|
| `FiliTheme`, `FocusRing` and every control | `light`, `accent`, `settingsRev`, `keyNav` (writable), `themeJson()` |
| Everything with a text of its own (`FiliDialog`, `FiliDebugPanel`, `FiliWindowPanel`…) | `tr(text)`: the application's translation (the text itself when absent) |
| `FiliWindowPanel` | `windowControl()` (true under niri), `windowState()` (comma separated names), `windowAction(name)` |
| `FiliLiaButton` | `askLia()` |
| `FiliDebugPanel` | `logs(since)` → `{seq, entries: [[level, text], …]}`, `logFile()`, `clearLogs()`, `openPath(path)`, `copyText(text)`, `reportProblem(text)`, `uiState(key)`, `setUiState(key, value)` |
| `FiliAboutCard` (`show()`) | `aboutRows()` → JSON `[[label, value], …]` (or set `rows` yourself) |

These are the functions every fili-* application already exposes the same way (`agents/skills/filigrane-ui/references/app-window.md`).

## Button labels

`FiliIconButton` and `FiliViewSwitch` do not draw their hover label (a Qt Quick Controls `ToolTip` costs about 3 MB per window
process): they call `showTip(item, text)` and `hideTip(item)` on their **window**. The window defines both over a `FiliTooltip`:

```qml
function showTip(owner, text) { tooltip.show(owner, { text: text }); }
function hideTip(owner) { tooltip.hide(owner); }
FiliTooltip { id: tooltip }
```

Without them the buttons work but show no label.

## Layouts and sizes

Components give an `implicitWidth` / `implicitHeight`, so they sit in a layout. The header and its `leading` / `tools` are
`RowLayout`s: each tool is centred vertically on the header's centre line whatever its height (a 30 high capsule beside 24 high
buttons). Size a tool in a header with `implicitWidth` or `Layout.preferredWidth`, not `width` (a layout ignores it).

## No shader effects

The Filigrane session renders Qt Quick in software (`QT_QUICK_BACKEND=software`). `MultiEffect`, `ShaderEffect`, `ColorOverlay`,
`DropShadow` and `layer.effect` draw nothing there. The kit tints icons in the file (Casier's sidebar glyphs), masks a round
picture with a Canvas (`FiliAvatar`) and uses Shapes and Canvas for pictograms; `scripts/run-tests.sh` refuses the others.

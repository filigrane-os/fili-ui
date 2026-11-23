# Fili UI

Shared QML controls and tokens for the Filigrane applications (`fili-*`), following the Filigrane desktop HIG
(`agents/skills/filigrane-ui/` in the Filigrane repository).

Status: 0.2.0. See `docs/inventory.md` for what the applications copied by hand and `docs/adoption.md` to use the kit.

| Part | Components |
|---|---|
| Tokens, link with the application | `FiliTheme`, `FiliHost` |
| Buttons | `FiliButton`, `FiliIconButton` |
| Choices | `FiliSwitch`, `FiliCheckBox`, `FiliRadioButton`, `FiliSelect` |
| Values and fields | `FiliSlider`, `FiliTextField`, `FiliProgressBar` |
| Window anatomy | `FiliHeader`, `FiliNavCapsule`, `FiliSidebar`, `FiliSidebarSection`, `FiliSidebarRow`, `FiliTabBar`, `FiliFooter` |
| Scrolling, focus, window actions | `KineticScroll`, `FiliScrollBar`, `FocusRing`, `WindowGlyph` |

```qml
import Fili.UI

// the application's own object that reads the theme files, set in the FIRST binding of the root item (see below)
readonly property bool kitReady: { FiliHost.backend = Fili; return true; }

FiliButton { label: qsTr("Save"); primary: true; onClicked: save() }
```

`FiliHost.backend` needs `light`, `accent`, `settingsRev`, `keyNav` and `themeJson()`. The kit imports nothing from an
application.

The backend must be set before anything reads `FiliTheme`: a `Component.onCompleted` or a `Binding` child is too late, the
first tokens are 0 and a `ListView` does not move again when its `leftMargin` changes after creation (the sidebar and
list of Casier shifted by a few pixels). Declare the assignment as the first property of the root item.

- `make check`: lint, demo theme in sync with `demo/theme.toml`, the headless behaviour tests (`scripts/run-tests.sh`).
- `make demo`: the kit as a whole window (`demo/Demo.qml`): header, sidebar, tabs, footer, every control, the tokens and the type scale.

No component uses a shader effect (`MultiEffect`, `ShaderEffect`…): the Filigrane session renders Qt Quick in software, where they draw
nothing. The tests refuse them.

License: GPL-3.0-or-later.

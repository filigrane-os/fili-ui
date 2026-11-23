# Fili UI

Shared QML controls and tokens for the Filigrane applications (`fili-*`), following the Filigrane desktop HIG
(`agents/skills/filigrane-ui/` in the Filigrane repository).

Status: skeleton. See `docs/inventory.md` for what exists, what differs across the apps today and what comes next.

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

- `make check`: lint and demo theme in sync with `demo/theme.toml`.
- `make demo`: gallery of the controls (`demo/Demo.qml`).

License: GPL-3.0-or-later.

# Fili UI

Shared QML controls and tokens for the Filigrane applications (`fili-*`), following the Filigrane desktop HIG
(`agents/skills/filigrane-ui/` in the Filigrane repository).

Status: skeleton. See `docs/inventory.md` for what exists, what differs across the apps today and what comes next.

```qml
import Fili.UI

// once, at startup: the application's own object that reads the theme files
Component.onCompleted: FiliHost.backend = Fili

FiliButton { label: qsTr("Save"); primary: true; onClicked: save() }
```

`FiliHost.backend` needs `light`, `accent`, `settingsRev`, `keyNav` and `themeJson()`. The kit imports nothing from an
application.

- `make check`: lint and demo theme in sync with `demo/theme.toml`.
- `make demo`: gallery of the controls (`demo/Demo.qml`).

License: GPL-3.0-or-later.

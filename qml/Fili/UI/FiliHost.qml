pragma Singleton
// The one link between the kit and an application. Each fili-* application has its own Rust object (Fili, Aeroport,
// Facteur, Conversations…) that reads the theme files; the kit never imports it. At startup the application does
//     FiliHost.backend = Fili      // any object with: light, accent, settingsRev, keyNav, themeJson()
// and, for the components that need them (docs/host-contract.md): tr(text), windowAction/windowControl/windowState, askLia(),
// logs/logFile/clearLogs/openPath/copyText/reportProblem, uiState/setUiState
import QtQuick

QtObject {
    property var backend: null
    readonly property bool keyNav: backend ? backend.keyNav : false
    // The text of the user's language: the application's own translation (backend.tr), the text as it is without one
    function tr(text) {
        return backend && backend.tr ? backend.tr(text) : text;
    }
    // The keyboard was used: the focus ring shows (backend.keyNav), like in the fili-shell
    function keyboard() {
        if (backend)
            backend.keyNav = true;
    }
}

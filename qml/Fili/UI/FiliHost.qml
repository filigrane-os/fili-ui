pragma Singleton
// The one link between the kit and an application. Each fili-* application has its own Rust object (Fili, Aeroport,
// Facteur, Conversations…) that reads the theme files; the kit never imports it. At startup the application does
//     FiliHost.backend = Fili      // any object with: light, accent, settingsRev, keyNav, themeJson()
import QtQuick

QtObject {
    property var backend: null
}

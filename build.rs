// QML module Fili.UI compiled into the crate (qrc:/qt/qml/Fili/UI/qml/Fili/UI/). The applications that depend on the crate
// get the module and its initializer through cxx-qt-build's Interface, and `import Fili.UI` works in their QML.
use cxx_qt_build::{CxxQtBuilder, QmlFile, QmlModule};

fn main() {
    // The token list lives here: dependents read it (DEP_FILI_UI_THEME_QML in their build script) to check their QML
    println!("cargo::metadata=theme_qml={}/qml/Fili/UI/FiliTheme.qml", env!("CARGO_MANIFEST_DIR"));
    let plain = [
        "FocusRing",
        "KineticScroll",
        "FiliScrollBar",
        "FiliButton",
        "FiliIconButton",
        "WindowGlyph",
        "FiliSwitch",
        "FiliCheckBox",
        "FiliRadioButton",
        "FiliSlider",
        "FiliProgressBar",
        "FiliTextField",
        "FiliSelect",
        "FiliNavCapsule",
        "FiliHeader",
        "FiliFooter",
        "FiliSidebar",
        "FiliSidebarSection",
        "FiliSidebarRow",
        "FiliTabBar",
        "FiliViewSwitch",
    ];
    let mut module = QmlModule::new("Fili.UI")
        .qml_file(QmlFile::from("qml/Fili/UI/FiliHost.qml").singleton(true))
        .qml_file(QmlFile::from("qml/Fili/UI/FiliTheme.qml").singleton(true))
        .depend("QtQuick");
    for name in plain {
        module = module.qml_file(format!("qml/Fili/UI/{name}.qml"));
    }
    CxxQtBuilder::new_qml_module(module).qt_module("Quick").build().export();
}

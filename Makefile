QT = $(firstword $(wildcard /usr/lib/qt6/bin /usr/lib64/qt6/bin))
QML = qml/Fili/UI
.PHONY: check demo build
export QMAKE ?= $(firstword $(wildcard /usr/lib/qt6/bin/qmake6 /usr/lib64/qt6/bin/qmake6))
build:
	cargo build
check:
	python3 -I scripts/check-module.py
	cargo check --locked
	scripts/run-tests.sh
	python3 -I scripts/theme-json demo/theme.toml | cmp - demo/theme.json
	$(QT)/qmllint --max-warnings 100 -I qml $(QML)/*.qml demo/Demo.qml
demo:
	QML_XHR_ALLOW_FILE_READ=1 $(QT)/qml -I qml demo/Demo.qml $(TAB)

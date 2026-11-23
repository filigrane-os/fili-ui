#!/bin/bash
# Behaviour tests of the kit, headless. Needs qmltestrunner (Void: qt6-quick-test).
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RUNNER="$(command -v qmltestrunner || ls /usr/lib/qt6/bin/qmltestrunner /usr/lib64/qt6/bin/qmltestrunner 2>/dev/null | head -1)"
[ -n "$RUNNER" ] || { echo "not ok - qmltestrunner not found (package qt6-quick-test)" >&2; exit 1; }
# The Filigrane session renders Qt Quick in software (QT_QUICK_BACKEND=software): a shader effect draws nothing there.
if grep -nE "MultiEffect|ShaderEffect|ColorOverlay|DropShadow|layer\.effect" "$ROOT"/qml/Fili/UI/*.qml; then
  echo "not ok - a component uses a shader effect: invisible with software rendering" >&2; exit 1
fi
OUT="$(mktemp)"; trap 'rm -f "$OUT"' EXIT
cd "$ROOT/tests" && QML_XHR_ALLOW_FILE_READ=1 QT_QPA_PLATFORM=offscreen "$RUNNER" -import "$ROOT/qml" -input tst_kit.qml 2>&1 | grep -vE "Unable to assign" | tee "$OUT"
grep -q "^Totals: .* 0 failed" "$OUT"

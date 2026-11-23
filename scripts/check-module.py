#!/usr/bin/env python3
"""The QML files of the module are the same in qmldir (demo, qmllint) and in build.rs (the crate): one list drifting from the
other leaves a component that works in the demo and is missing in the applications, or the reverse."""
import pathlib, re, sys

root = pathlib.Path(__file__).resolve().parent.parent
ui = root / "qml/Fili/UI"
qmldir = {m.group(1) for l in (ui / "qmldir").read_text().splitlines() if (m := re.match(r"(?:singleton )?(\w+) \d", l))}
build = (root / "build.rs").read_text()
built = set(re.findall(r'qml/Fili/UI/(\w+)\.qml', build)) | set(re.findall(r'^\s+"(\w+)",$', build, re.M))
files = {p.stem for p in ui.glob("*.qml")}
bad = []
for name, a, b in (("qmldir", qmldir, files), ("build.rs", built, files)):
    for x in sorted(a ^ b):
        bad.append(f"{x}: {'missing from' if x in b else 'listed in'} {name} but {'present' if x in b else 'absent'} on disk")
print("\n".join(bad) if bad else "ok - qmldir and build.rs list every component")
sys.exit(1 if bad else 0)

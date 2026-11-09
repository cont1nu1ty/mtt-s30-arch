#!/usr/bin/env python3
"""Compile the actual KWin EglDisplay code against bounded CPU query fixtures.

Uses the supplied KWin build configuration. In source mode, the actual
refreshed EglDisplay is compiled directly and linked with libkwin's original
format-map implementation; library mode exercises libkwin itself. Only EGL/GL
query functions and DRM device identity are fixtures. No display server, EGL
context, GPU node or driver is initialized.
"""
import argparse
import hashlib
import json
from pathlib import Path
import resource
import shlex
import subprocess

FIXTURE = Path(__file__).resolve().parent / "tests/kwin-format-context-test.cpp"
CASES = (
    "intersection", "implicit-modifiers", "other-driver", "no-drm-device", "other-model",
    "wrong-display", "no-context", "null-renderer", "format-count-failure",
    "format-list-failure", "format-count-overflow", "format-list-overflow", "format-list-zero",
    "modifier-count-failure", "modifier-list-failure", "modifier-count-overflow",
    "modifier-list-overflow", "modifier-list-zero", "no-formats", "empty-intersection", "only-external",
    "mixed-modifier-count-failure", "mixed-modifier-list-failure", "no-modifier-callback",
    "format-count-negative", "format-list-negative", "modifier-count-negative", "modifier-list-negative",
    "newly-external",
)
SUCCESS_CASES = {"intersection", "implicit-modifiers", "newly-external",
                 "mixed-modifier-count-failure", "mixed-modifier-list-failure"}
BYPASS_CASES = {"other-driver", "no-drm-device", "other-model"}
LOG_MARKER = "MTT compatibility: context import formats"


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--build", type=Path, required=True)
    parser.add_argument("--source", type=Path, help="Override source root, e.g. a freshly patched copy")
    parser.add_argument("--subject", choices=("source", "library"), default="source",
                        help="Exercise recompiled actual source or the built libkwin itself")
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    if args.subject == "library" and args.source:
        parser.error("Library mode uses only its own build's source; do not pass --source")
    build = args.build.resolve(strict=True)
    records_path = build / "compile_commands.json"
    if records_path.exists():
        record, = [r for r in json.loads(records_path.read_text()) if r["file"].endswith("/egldisplay.cpp")]
        command = record.get("arguments") or shlex.split(record["command"])
        directory = Path(record.get("directory", build)).resolve(strict=True)
        original_source = (directory / record["file"]).resolve(strict=True)
    else:
        text = subprocess.check_output(["ninja", "-C", str(build), "-t", "commands",
                                        "src/CMakeFiles/kwin.dir/opengl/egldisplay.cpp.o"], text=True)
        line, = [line for line in text.splitlines() if " -c " in line and line.endswith("/egldisplay.cpp")]
        command = shlex.split(line)
        directory = build
        original_source = Path(command[-1]).resolve(strict=True)
    source_root = args.source.resolve(strict=True) if args.source else original_source.parents[2]
    source = source_root / "src/opengl/egldisplay.cpp"
    header = source.with_suffix(".h")
    if "restrictMtgpuFormatsToCurrentContext" not in source.read_text():
        raise ValueError("Source must include the reviewed format-context patch")
    flags, i = [], 1
    while i < len(command):
        arg = command[i]
        if arg in ("-o", "-MT", "-MQ", "-MF"):
            i += 2
            continue
        if arg in ("-MD", "-c", str(original_source)):
            i += 1
            continue
        flags.append(arg)
        i += 1
    libraries = sorted((build / "bin").glob("libkwin.so.*"))
    library = next(p for p in libraries if p.is_file() and not p.is_symlink())
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    commands = []

    def run(argv):
        commands.append(argv)
        proc = subprocess.run(argv, cwd=directory, text=True, capture_output=True)
        with (output / "build.log").open("a") as stream:
            stream.write(proc.stdout + proc.stderr)
        proc.check_returncode()

    include = ["-I" + str(output), "-I" + str(source_root / "src")]
    display_obj = output / "egldisplay.o"
    fixture_obj = output / "fixture.o"
    if args.subject == "source":
        # A source override has a different header inode from the build tree.
        # Generate its metaobject against the actual subject header too.
        autogen = json.loads((build / "src/CMakeFiles/kwin_autogen.dir/AutogenInfo.json").read_text())
        run([autogen["QT_MOC_EXECUTABLE"], str(header), "-o", str(output / "moc_egldisplay.cpp")])
        run([command[0], *include, *flags, "-ffunction-sections", "-fdata-sections", "-c", str(source), "-o", str(display_obj)])
    run([command[0], *include, *flags, "-UNDEBUG", "-c", str(FIXTURE), "-o", str(fixture_obj)])
    qt = shlex.split(subprocess.check_output(["pkg-config", "--libs", "Qt6Core", "Qt6Gui", "Qt6OpenGL", "epoxy"], text=True))
    binary = output / "kwin-format-context-test"
    subject_objects = [str(display_obj)] if args.subject == "source" else []
    run([command[0], "-Wl,--gc-sections", str(fixture_obj), *subject_objects, str(library), *qt, "-o", str(binary)])
    resource.setrlimit(resource.RLIMIT_CORE, (0, 0))
    env = {"PATH": "/usr/bin:/usr/sbin", "LC_ALL": "C", "LD_LIBRARY_PATH": str(library.parent),
           "QT_LOGGING_RULES": "kwin_scene_opengl.info=true;kwin_wayland_drm.info=true",
           "QT_FORCE_STDERR_LOGGING": "1"}
    results = []
    for case in CASES:
        proc = subprocess.run([str(binary), case], env=env, text=True, capture_output=True, timeout=10)
        (output / (case + ".stdout")).write_text(proc.stdout)
        (output / (case + ".stderr")).write_text(proc.stderr)
        if case in SUCCESS_CASES:
            log_ok = (LOG_MARKER + " before" in proc.stderr and " accepted " in proc.stderr
                      and " removed " in proc.stderr and "XB24" in proc.stderr.split(" removed ")[-1]
                      and LOG_MARKER + " rejected:" not in proc.stderr)
        elif case in BYPASS_CASES:
            log_ok = LOG_MARKER not in proc.stderr
        else:
            log_ok = LOG_MARKER + " rejected:" in proc.stderr
        results.append(dict(case=case, exit=proc.returncode, log_marker_passed=log_ok,
                            stdout=proc.stdout, stderr=proc.stderr))
    passed = all(case["exit"] == 0 and case["log_marker_passed"] for case in results)
    result = dict(passed=passed, cases=results, case_count=len(results), subject=args.subject,
                  scope="Actual EglDisplay constructor/query/refresh; EGL/GL queries and DRM identity stubbed",
                  gpu_or_display_server_initialized=False, source=str(source), source_sha256=digest(source),
                  header_sha256=digest(header), library=str(library), library_sha256=digest(library),
                  fixture_sha256=digest(FIXTURE), tool_sha256=digest(Path(__file__)),
                  commands=commands, compile_cwd=str(directory), runtime_environment=env)
    (output / "results.json").write_text(json.dumps(result, indent=2) + "\n")
    if not passed:
        failed = [case["case"] for case in results if case["exit"] or not case["log_marker_passed"]]
        raise RuntimeError(f"Format context cases failed: {failed}; see {output}")
    print(f"{len(results)} actual-{args.subject} KWin format cases passed without GPU. Results: {output / 'results.json'}")


if __name__ == "__main__":
    main()

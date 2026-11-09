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
import re
import struct
import shlex
import subprocess

FIXTURE = Path(__file__).resolve().parent / "tests/kwin-format-context-test.cpp"
ROOT = Path(__file__).resolve().parents[2]
VENDOR = ROOT / "official/driver-3.1.0/usr/lib/x86_64-linux-gnu/dri/mtgpu_dri.so"
VENDOR_SHA = "2583b5c4e793389e0d130bfb8895884dfdee358ac70d63195deeba1eb0d1a07c"
V7_LIBRARY_SHA = "ea8d20cbb50430ddbd2d480afc2eb9b90f8eb1a43634025e342f00076ca8e9c2"
V7_TRACE = ROOT / "maintenance/validation/runtime-20261104-200750/desktop-session-result.json"
V7_TRACE_SHA = "c81e1019c9c74ea766a0ece94308389e731621d24cd785f83f6a9b78decb0d93"
TABLE_MARKER = "MTT compatibility: fixed-driver import formats"
CASES = (
    "intersection", "implicit-modifiers", "other-driver", "no-drm-device", "other-model",
    "wrong-display", "no-context", "null-renderer", "format-count-failure",
    "format-list-failure", "format-count-overflow", "format-list-overflow", "format-list-zero",
    "modifier-count-failure", "modifier-list-failure", "modifier-count-overflow",
    "modifier-list-overflow", "modifier-list-zero", "no-formats", "empty-intersection", "only-external",
    "mixed-modifier-count-failure", "mixed-modifier-list-failure", "no-modifier-callback",
    "format-count-negative", "format-list-negative", "modifier-count-negative", "modifier-list-negative",
    "newly-external", "v7-real-formats", "only-unimportable", "all-import-formats",
    "v7-real-other-driver", "v7-real-other-model", "v7-real-no-drm-device",
)
SUCCESS_CASES = {"intersection", "implicit-modifiers", "newly-external",
                 "mixed-modifier-count-failure", "mixed-modifier-list-failure",
                 "v7-real-formats", "all-import-formats"}
BYPASS_CASES = {"other-driver", "no-drm-device", "other-model",
                "v7-real-other-driver", "v7-real-other-model", "v7-real-no-drm-device"}
LOG_MARKER = "MTT compatibility: context import formats"


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def verified_inputs():
    """Read immutable vendor data and the archived counterexample, never load ELF."""
    data = VENDOR.read_bytes()
    if hashlib.sha256(data).hexdigest() != VENDOR_SHA:
        raise ValueError("Vendor binary changed; review the table address before using this fixture")
    if data[:6] != b"\x7fELF\x02\x01":
        raise ValueError("Expected a little-endian ELF64 vendor file")
    table_va, count, stride = 0xc1c420, 18, 12
    phoff = struct.unpack_from("<Q", data, 32)[0]
    phentsize, phnum = struct.unpack_from("<HH", data, 54)
    table_offset = None
    for index in range(phnum):
        entry = struct.unpack_from("<IIQQQQQQ", data, phoff + index * phentsize)
        kind, _, offset, vaddr, _, filesz, _, _ = entry
        if kind == 1 and vaddr <= table_va and table_va + count * stride <= vaddr + filesz:
            table_offset = offset + table_va - vaddr
            break
    if table_offset is None:
        raise ValueError("Primary import table is outside a file-backed load segment")
    primary = [struct.unpack_from("<I", data, table_offset + i * stride)[0] for i in range(count)]
    if len(set(primary)) != count:
        raise ValueError("Unexpected primary import table shape")
    trace_bytes = V7_TRACE.read_bytes()
    if hashlib.sha256(trace_bytes).hexdigest() != V7_TRACE_SHA:
        raise ValueError("The archived v7 hardware counterexample changed")
    trace = json.loads(trace_bytes)
    line = trace["context_import_formats_evidence"][0]
    match = re.search(r" before (.*?) current (.*?) accepted ", line)
    if not match or trace["renderer"] != "MTT S30":
        raise ValueError("Unexpected v7 format trace")
    before, current = ([int(value, 16) for value in re.findall(r"0x([0-9a-f]{8})", section)]
                       for section in match.groups())
    if len(before) != 22 or len(current) != 8:
        raise ValueError("Unexpected v7 query cardinalities")
    fourcc = lambda value: value.to_bytes(4, "little").decode("ascii")
    expected = set(before) & set(current) & set(primary)
    if set(map(fourcc, expected)) != {"R8  ", "GR88", "RG16", "AR24", "AB24", "XR24"}:
        raise ValueError("Vendor table no longer explains the physical counterexample")
    return dict(vendor=str(VENDOR), vendor_sha256=VENDOR_SHA, table_va=hex(table_va),
                table_file_offset=hex(table_offset), table_stride=stride, primary=primary,
                physical_trace=str(V7_TRACE), physical_trace_sha256=V7_TRACE_SHA,
                before=before, current=current, expected=sorted(expected),
                rejected=sorted(set(current) - set(primary)))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--build", type=Path, required=True)
    parser.add_argument("--source", type=Path, help="Override source root, e.g. a freshly patched copy")
    parser.add_argument("--subject", choices=("source", "library"), default="source",
                        help="Exercise recompiled actual source or the built libkwin itself")
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--baseline-v7-library", type=Path,
                        help="Prove the physical-counterexample case rejects the pinned old v7 library")
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
    inputs = verified_inputs()
    declarations = ["#pragma once", "#include <array>", "#include <cstdint>"]
    for variable, key in (("verifiedPrimaryImportFormats", "primary"),
                          ("verifiedV7BeforeFormats", "before"), ("verifiedV7CurrentFormats", "current")):
        values = inputs[key]
        declarations.append("constexpr std::array<uint32_t, " + str(len(values)) + "> " + variable +
                            " = {" + ", ".join(hex(value) + "u" for value in values) + "};")
    (output / "verified-vendor-formats.h").write_text("\n".join(declarations) + "\n")
    (output / "verified-inputs.json").write_text(json.dumps(inputs, indent=2) + "\n")
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
                      and LOG_MARKER + " rejected:" not in proc.stderr
                      and TABLE_MARKER in proc.stderr and VENDOR_SHA in proc.stderr)
        elif case in BYPASS_CASES:
            log_ok = LOG_MARKER not in proc.stderr and TABLE_MARKER not in proc.stderr
        else:
            log_ok = LOG_MARKER + " rejected:" in proc.stderr
        results.append(dict(case=case, exit=proc.returncode, log_marker_passed=log_ok,
                            stdout=proc.stdout, stderr=proc.stderr))
    passed = all(case["exit"] == 0 and case["log_marker_passed"] for case in results)
    baseline_result = None
    if args.baseline_v7_library:
        baseline = args.baseline_v7_library.resolve(strict=True)
        if digest(baseline) != V7_LIBRARY_SHA:
            raise ValueError("Baseline must be the pinned old v7 library")
        baseline_binary = output / "v7-counterexample"
        run([command[0], "-Wl,--gc-sections", str(fixture_obj), str(baseline), *qt, "-o", str(baseline_binary)])
        baseline_env = dict(env, LD_LIBRARY_PATH=str(baseline.parent))
        proc = subprocess.run([str(baseline_binary), "v7-real-formats"], env=baseline_env,
                              text=True, capture_output=True, timeout=10)
        (output / "baseline-v7.stdout").write_text(proc.stdout)
        (output / "baseline-v7.stderr").write_text(proc.stderr)
        rejected = proc.returncode == 42 and "V7_REAL_FORMATS_REGRESSION" in proc.stderr
        baseline_result = dict(library=str(baseline), sha256=digest(baseline), exit=proc.returncode,
                               rejected_by_new_case=rejected, stdout=proc.stdout, stderr=proc.stderr)
        passed = passed and rejected
    result = dict(passed=passed, cases=results, case_count=len(results), subject=args.subject,
                  scope="Actual EglDisplay constructor/query/refresh; EGL/GL queries and DRM identity stubbed",
                  gpu_or_display_server_initialized=False, source=str(source), source_sha256=digest(source),
                  header_sha256=digest(header), library=str(library), library_sha256=digest(library),
                  fixture_sha256=digest(FIXTURE), tool_sha256=digest(Path(__file__)),
                  commands=commands, compile_cwd=str(directory), runtime_environment=env,
                  vendor_table_and_trace_inputs=inputs, baseline_counterexample=baseline_result)
    (output / "results.json").write_text(json.dumps(result, indent=2) + "\n")
    if not passed:
        failed = [case["case"] for case in results if case["exit"] or not case["log_marker_passed"]]
        raise RuntimeError(f"Format context cases failed: {failed}; see {output}")
    print(f"{len(results)} actual-{args.subject} KWin format cases passed without GPU. Results: {output / 'results.json'}")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Exercise the actual Mesa code before/after the mtgpu opaque ABI patch.

Use a Mesa build tree from BEFORE mesa-23.2.1-mtgpu-screen-abi.patch. The
compiler configuration and headers come from that exact tree. The selected
source files are copied, the current maintained patch is applied with zero
fuzz, and tests compile those actual source functions. No driver is loaded,
no device is opened, and neither the supplied source nor build tree changes.
"""
import argparse
import hashlib
import json
import resource
import shlex
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
FIXTURES = Path(__file__).resolve().parent / "tests"
PATCH = ROOT / "patches/mesa-23.2.1-mtgpu-screen-abi.patch"
RELATIVE_SOURCE = Path("src/egl/drivers/dri2/egl_dri2.c")


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--build", required=True, type=Path,
                        help="Existing Mesa build with compile_commands.json, before this patch")
    parser.add_argument("--output", required=True, type=Path,
                        help="New directory for copies, binaries, commands, and results")
    args = parser.parse_args()
    build = args.build.resolve(strict=True)
    output = args.output.resolve()
    records = json.loads((build / "compile_commands.json").read_text())
    matches = [c for c in records if c["file"].endswith("/egl_dri2.c")]
    if len(matches) != 1:
        raise SystemExit("Expected exactly one egl_dri2.c compilation record")
    record = matches[0]
    directory = Path(record.get("directory", build)).resolve(strict=True)
    source = (directory / record["file"]).resolve(strict=True)
    if "MTT compatibility: opaque DRI screen callbacks" in source.read_text():
        raise SystemExit("Use a source/build tree before the screen ABI patch for a valid negative control")
    original = record.get("arguments") or shlex.split(record["command"])
    flags = []
    i = 1
    while i < len(original):
        arg = original[i]
        if arg in ("-o", "-MQ", "-MF"):
            i += 2
            continue
        if arg in ("-MD", "-c", record["file"]):
            i += 1
            continue
        flags.append(arg)
        i += 1
    output.mkdir(parents=True, exist_ok=False)
    commands = []

    def run(command, cwd=directory):
        commands.append({"argv": [str(a) for a in command], "cwd": str(cwd)})
        proc = subprocess.run(command, cwd=cwd, text=True, capture_output=True)
        with (output / "build.log").open("a") as log:
            log.write(proc.stdout + proc.stderr)
        if proc.returncode:
            raise RuntimeError(f"Command failed ({proc.returncode}); see {output / 'build.log'}")

    for kind in ("original", "patched"):
        target = output / kind / RELATIVE_SOURCE
        target.parent.mkdir(parents=True)
        shutil.copy2(source, target)
        shutil.copy2(source.with_suffix(".h"), target.with_suffix(".h"))
    run(["patch", "--batch", "--fuzz=0", "-p1", "-i", str(PATCH)], output / "patched")
    # Both expected SIGSEGV negative controls must not emit system coredumps.
    resource.setrlimit(resource.RLIMIT_CORE, (0, 0))
    results = []
    for kind in ("original", "patched"):
        target = output / kind / RELATIVE_SOURCE
        include = ["-I" + str(target.parent), "-I" + str(source.parent)]
        obj = output / (kind + ".o")
        fixture_obj = output / (kind + "-fixture.o")
        binary = output / ("screen-abi-" + kind)
        run([original[0], *include, *flags, "-c", str(target), "-o", str(obj)])
        run([original[0], *include, *flags, "-c", str(FIXTURES / "screen-abi-test.c"), "-o", str(fixture_obj)])
        run([original[0], "-Wl,--gc-sections", str(fixture_obj), str(obj), "-o", str(binary)])
        for case in ([0] if kind == "original" else range(13)):
            proc = subprocess.run([str(binary), str(case)], capture_output=True, text=True)
            expected = -11 if kind == "original" or case == 4 else 0
            result = dict(implementation=kind, case=case, exit=proc.returncode,
                          expected_exit=expected, stdout=proc.stdout, stderr=proc.stderr)
            results.append(result)
            if proc.returncode != expected:
                raise RuntimeError(f"Screen ABI regression failed: {result}")
    target = output / "patched" / RELATIVE_SOURCE
    context_binary = output / "context-abi-test"
    run([original[0], "-I" + str(target.parent), "-I" + str(source.parent), *flags,
         "-Wl,--gc-sections", str(FIXTURES / "context-abi-test.c"), "-o", str(context_binary)])
    context = subprocess.run([str(context_binary)], capture_output=True, text=True, check=True)
    (output / "context-abi-results.log").write_text(context.stdout + context.stderr)
    if len(context.stdout.splitlines()) != 8:
        raise RuntimeError("Expected eight context ABI cases")
    evidence = {
        "passed": True, "cases": 22, "screen_cases": results,
        "context_cases": 8, "context_stdout": context.stdout,
        "gpu_or_driver_initialized": False,
        "build": str(build), "base_source": str(source),
        "base_source_sha256": sha256(source),
        "base_header_sha256": sha256(source.with_suffix('.h')),
        "patch_sha256": sha256(PATCH),
        "patched_source_sha256": sha256(target),
        "patched_header_sha256": sha256(target.with_suffix('.h')),
        "test_tool_sha256": sha256(Path(__file__)),
        "fixtures": {p.name: sha256(p) for p in FIXTURES.glob('*-abi-test.c')},
        "commands": commands,
    }
    (output / "results.json").write_text(json.dumps(evidence, indent=2) + "\n")
    print(f"22 actual-source ABI cases passed; no GPU initialized. Results: {output / 'results.json'}")


if __name__ == "__main__":
    main()

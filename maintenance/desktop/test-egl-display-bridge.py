#!/usr/bin/env python3
"""Check actual EGL display bridging, image validation and teardown without GPU.

The before/after libraries' real EGL display/resource functions are used. Only
the DRI screen create/destroy callbacks are inert fixtures, and both fds are -1.
This is independent of the vendor binary's separate offline branch replay.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import resource
import shlex
import subprocess

FIXTURE = Path(__file__).resolve().parent / "tests/display-bridge-test.c"
SYMBOLS = ("_eglFindDisplay", "dri2_create_screen", "dri2_display_destroy",
           "_eglInitResource", "_eglLinkResource", "_eglUnlinkResource",
           "_eglLockDisplay", "_eglUnlockDisplay", "mtgpu_image_lookup_v1", "eglGetError")


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def symbols(library):
    rows = subprocess.check_output(["nm", "-an", "--defined-only", str(library)], text=True).splitlines()
    result = {}
    for name in SYMBOLS:
        matches = [row.split()[0] for row in rows if row.split()[-1] == name]
        if len(matches) != 1:
            raise ValueError(f"Expected exactly one symbol {name} in {library}")
        result[name] = matches[0]
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("build", "baseline", "candidate", "output"):
        parser.add_argument("--" + name, required=True, type=Path)
    args = parser.parse_args()
    build, baseline, candidate = (getattr(args, name).resolve(strict=True)
                                  for name in ("build", "baseline", "candidate"))
    output = args.output.resolve()
    records = json.loads((build / "compile_commands.json").read_text())
    record, = [r for r in records if r["file"].endswith("/egl_dri2.c")]
    directory = Path(record.get("directory", build)).resolve(strict=True)
    source = (directory / record["file"]).resolve(strict=True)
    command = record.get("arguments") or shlex.split(record["command"])
    flags, i = [], 1
    while i < len(command):
        arg = command[i]
        if arg in ("-o", "-MQ", "-MF"):
            i += 2
            continue
        if arg in ("-MD", "-c", record["file"]):
            i += 1
            continue
        flags.append(arg)
        i += 1
    output.mkdir(parents=True, exist_ok=False)
    binary = output / "display-bridge-test"
    compile_command = [command[0], *flags, "-I" + str(source.parent), str(FIXTURE),
                       "-ldl", "-o", str(binary)]
    compile_result = subprocess.run(compile_command, cwd=directory, text=True, capture_output=True)
    (output / "build.log").write_text(compile_result.stdout + compile_result.stderr)
    compile_result.check_returncode()
    resource.setrlimit(resource.RLIMIT_CORE, (0, 0))
    cases = [("baseline", baseline, "baseline")]
    cases.extend(("candidate", candidate, mode) for mode in (
        "wayland", "other-driver", "other-platform", "null-driver",
        "create-failure", "cross-display", "invalid-bridge"))
    result = []
    for label, library, mode in cases:
        addresses = symbols(library)
        env = {"PATH": "/usr/bin:/usr/sbin", "LC_ALL": "C",
               "LD_LIBRARY_PATH": str(library.parent), "EGL_LOG_LEVEL": "debug"}
        argv = [str(binary), str(library), mode, *(addresses[name] for name in SYMBOLS)]
        run = subprocess.run(argv, env=env, text=True, capture_output=True, timeout=15)
        stem = label + "-" + mode
        (output / (stem + ".stdout")).write_text(run.stdout)
        (output / (stem + ".stderr")).write_text(run.stderr)
        result.append(dict(library=label, mode=mode, exit=run.returncode,
                           argv=argv, stdout=run.stdout, stderr=run.stderr))
        if run.returncode:
            raise RuntimeError(f"Display bridge regression failed; see {output / stem}")
    evidence = dict(passed=True, case_count=len(result), cases=result,
                    no_real_driver_or_gpu_initialized=True,
                    baseline_sha256=digest(baseline), candidate_sha256=digest(candidate),
                    fixture_sha256=digest(FIXTURE), tool_sha256=digest(Path(__file__)),
                    build=str(build), header_sha256=digest(source.with_suffix('.h')),
                    compile_command=compile_command, compile_cwd=str(directory))
    (output / "results.json").write_text(json.dumps(evidence, indent=2) + "\n")
    print(f"{len(result)} actual-library display bridge cases passed; no GPU initialized. Results: {output / 'results.json'}")


if __name__ == "__main__":
    main()

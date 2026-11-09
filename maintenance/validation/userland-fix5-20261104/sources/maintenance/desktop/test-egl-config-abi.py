#!/usr/bin/env python3
"""Replay real opaque config objects against actual before/after EGL binaries.

Input JSON is exported from an identified hardware crash core, with one
212-byte vendor config per entry. The helper calls only public scalar config
getters and the EGL library's actual config conversion/validation function.
It never creates a screen, context, surface, or GPU command stream.
"""
import argparse
import hashlib
import json
import os
import resource
import shlex
import struct
import subprocess
from pathlib import Path

FIXTURE = Path(__file__).resolve().parent / "tests/config-abi-test.c"


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def symbol(path, name):
    lines = subprocess.check_output(["nm", "-an", "--defined-only", str(path)], text=True).splitlines()
    found = [line.split()[0] for line in lines if line.split()[-1] == name]
    if len(found) != 1:
        raise ValueError(f"Expected one local symbol {name} in {path}")
    return found[0]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for arg in ("build", "baseline", "candidate", "vendor", "configs", "output"):
        parser.add_argument("--" + arg, type=Path, required=True)
    args = parser.parse_args()
    build, baseline, candidate, vendor, configs_path = (
        getattr(args, key).resolve(strict=True)
        for key in ("build", "baseline", "candidate", "vendor", "configs"))
    output = args.output.resolve()
    configs = json.loads(configs_path.read_text())
    assert configs["vendor_allocation_bytes"] == 212
    records = configs["configs"]
    assert len(records) == configs["config_count"] and 0 < len(records) <= 512
    config_bytes = [bytes.fromhex(row["bytes"]) for row in records]
    assert all(len(blob) == 212 for blob in config_bytes)
    commands = json.loads((build / "compile_commands.json").read_text())
    record, = [r for r in commands if r["file"].endswith("/egl_dri2.c")]
    directory = Path(record.get("directory", build)).resolve(strict=True)
    source = (directory / record["file"]).resolve(strict=True)
    command = record.get("arguments") or shlex.split(record["command"])
    flags = []
    i = 1
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
    blob = output / "configs.bin"
    blob.write_bytes(struct.pack("<II", len(records), 212) + b"".join(config_bytes))
    binary = output / "config-abi-test"
    compile_command = [command[0], *flags, "-I" + str(source.parent),
                       str(FIXTURE), "-ldl", "-o", str(binary)]
    compiled = subprocess.run(compile_command, cwd=directory, text=True, capture_output=True)
    (output / "build.log").write_text(compiled.stdout + compiled.stderr)
    compiled.check_returncode()
    resource.setrlimit(resource.RLIMIT_CORE, (0, 0))
    results = []
    cases = [("baseline", baseline, "raw", -6),
             ("baseline", baseline, "filtered", 0),
             ("candidate", candidate, "raw", 0),
             ("candidate", candidate, "max", 0),
             ("candidate", candidate, "invalid-render", 0),
             ("candidate", candidate, "invalid-depth", 0),
             ("candidate", candidate, "invalid-key", -6)]
    for label, library, mode, expected in cases:
        env = os.environ.copy()
        env.pop("LD_PRELOAD", None)
        env["LD_LIBRARY_PATH"] = str(library.parent) + ":" + str(vendor.parent.parent)
        env["LIBGL_DRIVERS_PATH"] = str(vendor.parent)
        env["EGL_LOG_LEVEL"] = "debug"
        argv = [str(binary), str(library), symbol(library, "dri2_add_config"),
                str(vendor), str(blob), mode]
        run = subprocess.run(argv, env=env, text=True, capture_output=True, timeout=15)
        stem = label + "-" + mode
        (output / (stem + ".stdout")).write_text(run.stdout)
        (output / (stem + ".stderr")).write_text(run.stderr)
        results.append(dict(library=label, mode=mode, exit=run.returncode,
                            expected_exit=expected, argv=argv, stdout=run.stdout))
        assert run.returncode == expected, results[-1]
        if expected == -6:
            assert "offset >= 0" in run.stderr, run.stderr
    control = results[1]["stdout"]
    assert control == results[2]["stdout"] == results[3]["stdout"]
    assert "accepted=15 total=54" in control
    assert all("accepted=0 total=54" in results[i]["stdout"] for i in (4, 5))
    evidence = dict(passed=True, cases=results,
                    no_screen_context_surface_created=True,
                    baseline_sha256=digest(baseline), candidate_sha256=digest(candidate),
                    vendor_sha256=digest(vendor), core_config_json_sha256=digest(configs_path),
                    config_binary_sha256=digest(blob), fixture_sha256=digest(FIXTURE),
                    tool_sha256=digest(Path(__file__)), build=str(build),
                    header_sha256=digest(source.with_suffix('.h')),
                    compile_command=compile_command, compile_cwd=str(directory))
    (output / "results.json").write_text(json.dumps(evidence, indent=2) + "\n")
    print(f"7 actual-library cases passed: 54 real configs; 15 valid window configs preserved. Results: {output / 'results.json'}")


if __name__ == "__main__":
    main()

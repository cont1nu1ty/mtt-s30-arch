#!/usr/bin/env python3
"""Stop exact vendor dispatch before device access, comparing real EGL displays.

This is a CPU-only branch probe, not successful screen/drawable creation. After
library/extension loading, the tested constructor is killed at a reviewed
pre-device instruction. A seccomp denylist and GDB syscall catchpoints forbid
device opening, ioctls and socket access during the tested constructor calls.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import resource
import shlex
import signal
import subprocess

FIXTURE = Path(__file__).resolve().parent / "tests/display-abi-test.c"
VENDOR_SHA = "2583b5c4e793389e0d130bfb8895884dfdee358ac70d63195deeba1eb0d1a07c"


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def symbol(path, name):
    lines = subprocess.check_output(["nm", "-an", "--defined-only", str(path)], text=True).splitlines()
    found = [line.split()[0] for line in lines if line.split()[-1] == name]
    if len(found) != 1:
        raise ValueError(f"Expected one local symbol {name} in {path}")
    return found[0]


def compile_fixture(build, output):
    commands = json.loads((build / "compile_commands.json").read_text())
    record, = [r for r in commands if r["file"].endswith("/egl_dri2.c")]
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
    binary = output / "display-abi-test"
    argv = [command[0], *flags, "-O0", "-g", "-I" + str(source.parent),
            str(FIXTURE), "-ldl", "-o", str(binary)]
    run = subprocess.run(argv, cwd=directory, text=True, capture_output=True)
    (output / "build.log").write_text(run.stdout + run.stderr)
    run.check_returncode()
    return binary, argv, directory


def script(phase):
    lines = ["set pagination off", "set confirm off", "set auto-load off",
             "set debuginfod enabled off", "set disable-randomization off",
             "handle SIGSYS stop print nopass", "break probe_ready", "run",
             'printf "GUARD=%d\\n", probe_guard_enabled',
             "set $base = vendor_base",
             "catch syscall ioctl open openat openat2 socket socketpair connect io_uring_setup io_uring_enter",
             "commands", "silent", 'echo FORBIDDEN_SYSCALL\\n', "kill", "quit 3", "end"]
    if phase == "screen":
        # 6e572e is immediately before the first native device helper call.
        stops = [(0x6E572E, 'printf "DISPATCH_TYPE=%u FD=%d\\n", $edi, $esi')]
        # Alternative branches must never reach a device helper either.
        for offset in (0x6E54B2, 0x6E5E95, 0x6E5EC5, 0x6E5EF4):
            lines += [f"break *($base + {offset})", "commands", "silent",
                      'echo UNEXPECTED_DEVICE_BRANCH\\n', "kill", "quit 4", "end"]
    elif phase == "drawable":
        stops = [(0x6EA133, 'echo DRAWABLE_BRANCH=image\\n'),
                 (0x6EA2F0, 'echo DRAWABLE_BRANCH=xcb\\n')]
    else:
        stops = []
    for offset, observe in stops:
        lines += [f"break *($base + {offset})", "commands", "silent", observe,
                  'printf "STUB_DELEGATE_CALLS=%d\\n", probe_delegate_calls',
                  'echo STOPPED_BEFORE_DEVICE_WORK\\n', "kill", "quit 0", "end"]
    lines += ["continue", 'echo UNEXPECTED_STOP_OR_RETURN\\n', "kill", "quit 5"]
    return "\n".join(lines) + "\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("build", "baseline", "candidate", "vendor", "output"):
        parser.add_argument("--" + name, type=Path, required=True)
    parser.add_argument("--create-screen-symbol", default="dri2_create_screen")
    args = parser.parse_args()
    build, baseline, candidate, vendor = (getattr(args, key).resolve(strict=True)
                                        for key in ("build", "baseline", "candidate", "vendor"))
    if digest(vendor) != VENDOR_SHA:
        raise ValueError("Vendor binary differs: instruction boundaries must be reviewed again")
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    binary, compile_command, compile_cwd = compile_fixture(build, output)
    resource.setrlimit(resource.RLIMIT_CORE, (0, 0))
    results = []
    for mode, library, expected_type, expected_branch in (
        ("baseline", baseline, 0, "xcb"), ("candidate", candidate, 4, "image")
    ):
        create_screen = symbol(library, args.create_screen_symbol)
        native_type = -1
        for phase in ("screen", "drawable"):
            stem = mode + "-" + phase
            debugger_script = output / (stem + ".gdb")
            debugger_script.write_text(script(phase))
            argv = ["gdb", "-q", "-nx", "-batch", "-x", str(debugger_script), "--args",
                    str(binary), phase, mode, str(library), create_screen, str(vendor), str(native_type)]
            env = os.environ.copy()
            env.pop("LD_PRELOAD", None)
            env["LD_LIBRARY_PATH"] = str(library.parent) + ":" + str(vendor.parent.parent)
            env["LIBGL_DRIVERS_PATH"] = str(vendor.parent)
            env["EGL_LOG_LEVEL"] = "debug"
            run = subprocess.run(argv, env=env, text=True, capture_output=True, timeout=20)
            (output / (stem + ".stdout")).write_text(run.stdout)
            (output / (stem + ".stderr")).write_text(run.stderr)
            assert run.returncode == 0, (stem, run.returncode, run.stdout, run.stderr)
            assert "GUARD=1" in run.stdout and "STOPPED_BEFORE_DEVICE_WORK" in run.stdout, stem
            assert not any(marker in run.stdout for marker in (
                "FORBIDDEN_SYSCALL", "UNEXPECTED_DEVICE_BRANCH", "UNEXPECTED_STOP_OR_RETURN")), stem
            result = dict(mode=mode, phase=phase, exit=run.returncode, argv=argv)
            if phase == "screen":
                assert "STUB_DELEGATE_CALLS=0" in run.stdout, stem
                match = re.search(r"DISPATCH_TYPE=(\d+) FD=(-?\d+)", run.stdout)
                assert match and tuple(map(int, match.groups())) == (expected_type, -1), stem
                native_type = int(match[1])
                result["observed_native_type"] = native_type
                result["fd"] = -1
            else:
                assert "STUB_DELEGATE_CALLS=1" in run.stdout, stem
                assert "DRAWABLE_BRANCH=" + expected_branch in run.stdout, stem
                result["observed_branch"] = expected_branch
                result["native_type_from_screen_probe"] = native_type
                result["nested_musa_constructor_stubbed"] = True
            results.append(result)
    guard_results = []
    for phase in ("guard-ioctl", "guard-open"):
        argv = [str(binary), phase, "baseline", str(baseline),
                symbol(baseline, args.create_screen_symbol), str(vendor), "-1"]
        env["LD_LIBRARY_PATH"] = str(baseline.parent) + ":" + str(vendor.parent.parent)
        for mechanism in ("seccomp", "gdb"):
            stem = mechanism + "-" + phase
            command = argv
            if mechanism == "gdb":
                debugger_script = output / (stem + ".gdb")
                debugger_script.write_text(script(phase))
                command = ["gdb", "-q", "-nx", "-batch", "-x", str(debugger_script), "--args", *argv]
            run = subprocess.run(command, env=env, text=True, capture_output=True, timeout=20)
            (output / (stem + ".stdout")).write_text(run.stdout)
            (output / (stem + ".stderr")).write_text(run.stderr)
            expected = -signal.SIGSYS if mechanism == "seccomp" else 3
            assert run.returncode == expected, (stem, run.returncode, run.stdout, run.stderr)
            if mechanism == "gdb":
                assert "GUARD=1" in run.stdout and "FORBIDDEN_SYSCALL" in run.stdout, stem
            guard_results.append(dict(phase=phase, mechanism=mechanism, exit=run.returncode,
                                      expected_exit=expected, argv=command))
    evidence = dict(passed=True, cases=results, guard_cases=guard_results,
                    screen_or_drawable_creation_completed=False,
                    device_helpers_executed=False, gpu_work_submitted=False,
                    drawable_probe_limitation="Only mtgpu dispatch is exercised; optional nested musa drawable constructor uses a recording stub in the throwaway process",
                    guards="seccomp denylist active before tested screen/drawable constructor entry; GDB syscall catchpoints; kill at pre-device branch",
                    setup_scope="dlopen and extension discovery happen before guards; open fds are then checked for GPU nodes before enabling seccomp. Guards cover the tested constructor calls, not library loading.",
                    baseline_sha256=digest(baseline), candidate_sha256=digest(candidate),
                    vendor_sha256=digest(vendor), fixture_sha256=digest(FIXTURE),
                    tool_sha256=digest(Path(__file__)), build=str(build),
                    compile_command=compile_command, compile_cwd=str(compile_cwd),
                    create_screen_symbol=args.create_screen_symbol)
    (output / "results.json").write_text(json.dumps(evidence, indent=2) + "\n")
    print(f"4 CPU-only vendor dispatch probes and 4 guard controls passed; no device helper executed. Results: {output / 'results.json'}")


if __name__ == "__main__":
    main()

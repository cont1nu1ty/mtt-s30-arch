#!/usr/bin/env python3
"""Reproduce pinned pure-CPU vendor queries; never initialize a GPU."""
from pathlib import Path
import hashlib
import json
import subprocess

here = Path(__file__).resolve().parent
root = here.parent.parent
vendor = root / "official/driver-3.1.0/usr/lib/x86_64-linux-gnu"
expected = {
    "dri/mtgpu_dri.so": "2583b5c4e793389e0d130bfb8895884dfdee358ac70d63195deeba1eb0d1a07c",
    "libmusa_dri_support.so.1.0.0": "bea665953469d99a2c15b72bb6a38724361d4d8bf311291c59f691c1bb500de1",
    "gbm/mtgpu_gbm.so": "e156b390ac850e55b62386163ce45422219948f1f880a7f8dcefa19f6da5cf14",
}
files = []
for relative, sha256 in expected.items():
    path = vendor / relative
    if hashlib.sha256(path.read_bytes()).hexdigest() != sha256:
        raise SystemExit(f"Refusing changed binary: {path}")
    files.append(path)
subprocess.run(["cc", "-O2", "-Wall", "-Wextra", "-Werror",
                str(here / "pure-format-probe.c"), "-o", str(here / "pure-format-probe")], check=True)
result = subprocess.run([str(here / "pure-format-probe"), *map(str, files)],
                        capture_output=True, text=True, check=True)
output = json.loads(result.stdout)
assert output["guard_enabled"] is True
fourcc = lambda value: value.to_bytes(4, "little").decode("ascii")
primary = set(map(fourcc, output["primary_formats"]))
secondary = set(map(fourcc, output["musa_historical_mask_all_31_enabled_formats"]))
assert {"XR24", "AR24", "AB24"} <= primary and "XB24" not in primary
assert {"XR24", "AR24", "AB24", "XB24"} <= secondary
for query in output["modifier_queries"]:
    if fourcc(query["fourcc"]) == "XB24":
        assert query["count_ok"] == 1 and query["list_ok"] == 1
for query in output["gbm_format_support_query"]:
    if fourcc(query["fourcc"]) == "XB24":
        assert query["supported"] == 1
(here / "pure-format-probe.json").write_text(json.dumps(output, indent=2) + "\n")
print("CPU-only original-byte format/modifier/GBM queries passed; no GPU initialization.")
print(here / "pure-format-probe.json")

#!/usr/bin/env bash
# Read-only smoke checks. Run after a separately approved console-mode load.
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source_root="$root/official/driver-3.1.0"
gpu=0000:04:00.0
bound=$(readlink -f "/sys/bus/pci/devices/$gpu/driver" || true)
if [[ ${bound##*/} != mtgpu ]]; then
    echo "S30 is not bound to mtgpu; refusing to call software-rendering success GPU success." >&2
    exit 2
fi
export LD_LIBRARY_PATH="$source_root/usr/lib/x86_64-linux-gnu${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export LIBGL_DRIVERS_PATH="$source_root/usr/lib/x86_64-linux-gnu/dri"
export LIBVA_DRIVERS_PATH="$LIBGL_DRIVERS_PATH"
export LIBVA_DRIVER_NAME=mtgpu
export __GLX_VENDOR_LIBRARY_NAME=mtgpu
export __EGL_VENDOR_LIBRARY_FILENAMES="$source_root/usr/share/glvnd/egl_vendor.d/00_mtgpu.json"
export VK_DRIVER_FILES="$source_root/etc/vulkan/icd.d/musaicdconf.json"
export GBM_BACKENDS_PATH="$source_root/usr/lib/x86_64-linux-gnu/gbm"
printf 'Kernel driver: %s\n' "$bound"
"$source_root/usr/bin/mthreads-gmi"
vulkaninfo --summary
vainfo
if [[ -n ${DISPLAY:-} ]]; then
    result=$(glxinfo -B)
    printf '%s\n' "$result"
    if grep -Eiq 'llvmpipe|softpipe|Accelerated: no' <<< "$result"; then
        echo 'OpenGL is still software-rendered.' >&2
        exit 1
    fi
else
    echo 'No X display: OpenGL desktop acceleration was NOT tested.'
fi

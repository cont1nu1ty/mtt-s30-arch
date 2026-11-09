# Real DRI loader routing for the isolated Wayland client

Four fresh, unprivileged processes used the accepted private Mesa EGL ELF and its actual loader_open_driver function, reached by its local symbol address from the matching binary. Each invocation supplied the driver's real name and the LIBGL_DRIVERS_PATH search variable used by dri2_open_driver in the built Mesa source. The loader invoked the public __driDriverGetExtensions_mtgpu accessor. dl_iterate_phdr recorded canonical paths for the mapped DRI libraries after discovery. A seccomp filter made any ioctl or socket connect fatal. This covers production binary discovery, with no EGL context creation or cleanup, GPU ioctl or presentation.

| LIBGL_DRIVERS_PATH contents | Primary extensions | Mapped DRI objects |
| --- | --- | --- |
| Private client directory with the repaired primary and vendor secondary | yes | both private, independently SHA-256 checked |
| Original vendor directory | yes | both original |
| Private directory with only repaired primary | yes | only primary, vendor printed secondary lookup failure |
| Private directory with only secondary | no | neither, Mesa printed primary lookup failure |

Disassembly of mtgpu_dri.so shows that __driDriverGetExtensions_mtgpu calls +0x88f1c0 at +0x6ea800. When real and effective UIDs agree, the vendor helper checks a table whose first entry names LIBGL_DRIVERS_PATH. It splits paths on colons, constructs each secondary filename with the literal format %.*s/%s%s.so using musa and _dri, and calls dlopen at +0x88f270. Its error path leaves the primary extension table available. Requiring the exact secondary mapping in the hardware test catches this case.

The results.json file records canonical paths, SHA-256 digests, effective search directories and the tester UID. Each case log preserves stdout and stderr. The repaired primary SHA-256 is 05cd2ddd3dcb2c0a77994d52b959548babcf912027b550efb9a45aeb6201fc23. The secondary SHA-256 is 0c8ddef50a68b20db4fcb1b5e91a5c74075fa0c5527b3a9b45cd93aeaec3532b.

To repeat from the project root with this evidence directory present:

```sh
cc -std=c11 -O2 -Wall -Wextra -Werror -o work/v9-loader-routing-20261109/route work/v9-loader-routing-20261109/route.c -ldl
python3 work/v9-loader-routing-20261109/check.py
```

The original test prepared the isolated desktop subdirectory via the project builder:

```sh
python3 maintenance/desktop/build-drawable-compat.py --output work/v9-loader-routing-20261109/desktop
```

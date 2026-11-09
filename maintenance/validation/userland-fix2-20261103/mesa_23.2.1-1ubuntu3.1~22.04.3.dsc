-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

Format: 1.0
Source: mesa
Binary: libxatracker2, libxatracker-dev, libd3dadapter9-mesa, libd3dadapter9-mesa-dev, libgbm1, libgbm-dev, libegl-mesa0, libegl1-mesa-dev, libgles2-mesa-dev, libglapi-mesa, libglx-mesa0, libgl1-mesa-dri, libgl1-mesa-dev, mesa-common-dev, libosmesa6, libosmesa6-dev, mesa-va-drivers, mesa-vdpau-drivers, mesa-vulkan-drivers, mesa-opencl-icd, mesa-drm-shim
Architecture: any
Version: 23.2.1-1ubuntu3.1~22.04.3
Maintainer: Ubuntu Developers <ubuntu-devel-discuss@lists.ubuntu.com>
Uploaders: Andreas Boll <aboll@debian.org>
Homepage: https://mesa3d.org/
Standards-Version: 4.1.4
Vcs-Browser: https://salsa.debian.org/xorg-team/lib/mesa
Vcs-Git: https://salsa.debian.org/xorg-team/lib/mesa.git
Testsuite: autopkgtest
Testsuite-Triggers: build-essential, pkg-config
Build-Depends: debhelper-compat (= 12), directx-headers-dev (>= 1.610.0) [linux-amd64 linux-arm64], glslang-tools [amd64 arm64 armel armhf i386 mips64el powerpc ppc64 ppc64el riscv64 s390x sparc64 x32], meson (>= 0.45), quilt (>= 0.63-8.2~), pkg-config, libdrm-dev (>= 2.4.107-4), libx11-dev, libxxf86vm-dev, libexpat1-dev, libsensors-dev [!hurd-any], libxfixes-dev, libxext-dev, libva-dev (>= 1.6.0) [linux-any kfreebsd-any] <!pkg.mesa.nolibva>, libvdpau-dev (>= 1.1.1) [linux-any kfreebsd-any], libvulkan-dev [amd64 arm64 armel armhf i386 mips64el powerpc ppc64 ppc64el riscv64 s390x sparc64 x32], x11proto-dev, linux-libc-dev (>= 2.6.31) [linux-any], libx11-xcb-dev, libxcb-dri2-0-dev (>= 1.8), libxcb-glx0-dev (>= 1.8.1), libxcb-xfixes0-dev, libxcb-dri3-dev, libxcb-present-dev, libxcb-randr0-dev, libxcb-shm0-dev, libxcb-sync-dev, libxrandr-dev, libxshmfence-dev (>= 1.1), libzstd-dev, python3, python3-mako, python3-ply, python3-setuptools, flex, bison, libelf-dev [amd64 arm64 armel armhf i386 mips64el powerpc ppc64 ppc64el riscv64 s390x sparc64 x32], libwayland-dev (>= 1.15.0) [linux-any], libwayland-egl-backend-dev (>= 1.15.0) [linux-any], llvm-15-dev [amd64 arm64 armel armhf i386 mips64el powerpc ppc64 ppc64el riscv64 s390x sparc64 x32], libclang-15-dev [amd64 arm64 armel armhf i386 mips64el powerpc ppc64 ppc64el riscv64 s390x sparc64 x32], libclang-cpp15-dev [amd64 arm64 armel armhf i386 mips64el powerpc ppc64 ppc64el riscv64 s390x sparc64 x32], libclc-15-dev [amd64 arm64 armel armhf i386 mips64el powerpc ppc64 ppc64el riscv64 s390x sparc64 x32], wayland-protocols (>= 1.24), zlib1g-dev, libglvnd-core-dev (>= 1.3.2), valgrind [amd64 arm64 armhf i386 mips64el powerpc ppc64 ppc64el s390x], rustc [amd64 arm64 armel armhf mips64el powerpc ppc64 ppc64el riscv64 s390x x32], bindgen [amd64 arm64 armel armhf mips64el powerpc ppc64 ppc64el riscv64 s390x x32], llvm-spirv-15 [amd64 arm64 armel armhf mips64el powerpc ppc64 ppc64el riscv64 s390x x32], libclc-15 [amd64 arm64 armel armhf mips64el powerpc ppc64 ppc64el riscv64 s390x x32], libllvmspirvlib-15-dev [amd64 arm64 armel armhf mips64el powerpc ppc64 ppc64el riscv64 s390x x32]
Package-List:
 libd3dadapter9-mesa deb libs optional arch=amd64,arm64,armel,armhf,i386,powerpc
 libd3dadapter9-mesa-dev deb libdevel optional arch=amd64,arm64,armel,armhf,i386,powerpc
 libegl-mesa0 deb libs optional arch=any
 libegl1-mesa-dev deb libdevel optional arch=any
 libgbm-dev deb libdevel optional arch=linux-any,kfreebsd-any
 libgbm1 deb libs optional arch=linux-any,kfreebsd-any
 libgl1-mesa-dev deb oldlibs optional arch=any
 libgl1-mesa-dri deb libs optional arch=any
 libglapi-mesa deb libs optional arch=any
 libgles2-mesa-dev deb oldlibs optional arch=any
 libglx-mesa0 deb libs optional arch=any
 libosmesa6 deb libs optional arch=any
 libosmesa6-dev deb libdevel optional arch=any
 libxatracker-dev deb libdevel optional arch=amd64,i386,x32
 libxatracker2 deb libs optional arch=amd64,i386,x32
 mesa-common-dev deb libdevel optional arch=any
 mesa-drm-shim deb libs optional arch=amd64,arm64,armel,armhf,i386,mips64el,powerpc,ppc64,ppc64el,s390x,sparc64
 mesa-opencl-icd deb libs optional arch=amd64,arm64,armel,armhf,i386,mips64el,powerpc,ppc64,ppc64el,riscv64,s390x,sparc64,x32
 mesa-va-drivers deb libs optional arch=linux-any,kfreebsd-any profile=!pkg.mesa.nolibva
 mesa-vdpau-drivers deb libs optional arch=linux-any,kfreebsd-any
 mesa-vulkan-drivers deb libs optional arch=amd64,arm64,armel,armhf,i386,mips64el,powerpc,ppc64,ppc64el,riscv64,s390x,sparc64,x32
Checksums-Sha1:
 065a9a2228fe0071c03a5d7d82517dc0f45f5c67 30631591 mesa_23.2.1.orig.tar.gz
 119dffc9a2c51889ecf1f21a602a7a19b350ce8f 225765 mesa_23.2.1-1ubuntu3.1~22.04.3.diff.gz
Checksums-Sha256:
 c1458ab511b87d60644b2c46d67f7d9d5c0e3db691db6aae11762b1cc5b43ca0 30631591 mesa_23.2.1.orig.tar.gz
 f43f7e603db34bb4f8fd8b41be102d112c23042e769d94a0d78fee0ee6ee7fd2 225765 mesa_23.2.1-1ubuntu3.1~22.04.3.diff.gz
Files:
 454f066a275cbfe8e697ae0c2131a35e 30631591 mesa_23.2.1.orig.tar.gz
 ed012b8d6a4c96095cb4e0099edbe479 225765 mesa_23.2.1-1ubuntu3.1~22.04.3.diff.gz
Original-Maintainer: Debian X Strike Force <debian-x@lists.debian.org>

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEEdS3ifE3rFwGbS2Yjy3AxZaiJhNwFAmcHhnIACgkQy3AxZaiJ
hNw1AA//VL0JIyRDvbVXc1S7dH4C04TpIty7nMnohfK9cRHWnr3fsFy8NPB7lrrD
jtV4mqURxNLJguO8yndXoF+hiwx+S9Ruxta8vsDPYTt+G0daOk7zAo1+FgF65pEZ
cv6HYgz6yHut5X47ga5RX7VCwYiqHPyqSvWpp8ejzwyqRzLP9G5CF1jQ8KcNj/b7
o58/fdhu3Djb4AyzIx9oRBYjmVB/2494hJUMN+fLpFdL60tKCB+OWeTZBXSzOYQ4
YkTE06XOXeS4TDaeS98y/KLDGmLTVunZ9Mkgtt9cDagc/eu9zmo90EFxRJWU+Nwt
g7CEX74ImyFXIu3FQtsao7CRaNa6DHCJBDwYbvp0bDUL7Z03tM0Vp8AL09VRTkP9
CRCyLGiwDvwOqXguo4HQ/ZKy+kqzoTOpOV6T4TDEpllUq2czQkOxmULk9pjLWYRk
sODuPOdNxYHvIZ/B5Aj/fX3HFeuf9H8r60qgTFirmhSmhnKlTWI2UwAZze3RQDWF
2Wbe5/lMc74hNZON/4Z0qSrfB0Be3VGpyx/0P4cQuwxA4vzL3d+NBbBEdgk04GKl
REycDRNt1Y//5T2mZqXWJbMKYwpr6NH4tQ7KcTbgSSLMqEFze/9hWKx4fzn0z1Oe
rXhbw1a4byUMIUywBuKe9ZxRz9WnNGJcXo/TuslR2HXUpkrsE3k=
=DyLB
-----END PGP SIGNATURE-----

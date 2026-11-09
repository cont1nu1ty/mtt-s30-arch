#!/bin/bash

export LANG=en_US.UTF-8
export LANGUAGE=en_US:en

CC=""
CFLAGS=""
CPU_ARCH=""
KERNEL_ARCH=""
SOURCES=""
HEADERS=""
ARCH_HEADERS=""
SOURCES_SYM_FILE=""
SCRIPT_NAME="${0##*/}"
DBG_SEPARATOR="$(printf -- '%.s*' {1..120})"
BUILD_TYPE=release
SUPPORTED_ARCHS=("x86_64" "i386" "arm64" "arm" "loongarch")

# WIPT: -Wincompatible-pointer-types
CC_SUPPORT_OPT_WIPT=0

if [ $# = 0 ];then
    WORK_DIR="$(dirname "$(readlink -f $0)")"
else
    WORK_DIR=`pwd`
fi

CONFTEST_SYM="conftest"
CONFTEST_INC="${CONFTEST_SYM}.h"
CONFTEST_TGT="${WORK_DIR}/${CONFTEST_INC}"
CONFTEST_SRC_FILE="${WORK_DIR}/${CONFTEST_SYM}_src"
CONFTEST_COMPILE_PREAMBLE=""
CONFTEST_MACRO_PREFIX="OS_"
CONFTEST_DBG_LOCK="${WORK_DIR}/${CONFTEST_SYM}_dbg.lock"

conftest_make_exist_macro()
{
    local name="$1"
    echo "${CONFTEST_MACRO_PREFIX}${name}_EXIST" | tr ' /.-' '_' | tr '[:lower:]' '[:upper:]'
}

#
# conftest_include accepts only the header files listed in @TEST_HEADERS as arguments
#
conftest_include()
{
    local file="$1"
    local code="
    #if defined($(conftest_make_exist_macro "$file"))
    #include <$file>
    #endif
    "

    echo "$code"
}

declare -a TEST_HEADERS
declare -a TEST_SYMBOLS
declare -A TEST_FUNCS
declare -A TEST_TYPES
declare -A TEST_TYPE_FIELDS
declare -A TEST_ENUM_FIELDS
declare -A TEST_CUSTOMS
declare -A TEST_TEXT


#!/bin/bash

#
# TEST_HEADERS is a list that checks for the presence of header files.
#
# Each @file_name in the list below will generate a corresponding
# macro which is named with the prefix "OS_" followed by the uppercase of
# the @file_name and the suffix "_EXIST", the character "/", "." and "-"
# in @file_name will be replaced by "_".
#
# @file_name: header file relative path
#
# example:
#   if @file_name is foo/test-foo.h ==> #define OS_FOO_TEST_FOO_H_EXIST
#   if @file_name is foo/tests/test_foo.h ==> #define OS_FOO_TESTS_TEST_FOO_H_EXIST
#
TEST_HEADERS=(
    # OS_DRM_DRMP_H_EXIST
    drm/drmP.h

    # OS_DRM_DRM_APERTURE_H_EXIST
    drm/drm_aperture.h

    # OS_DRM_DRM_PROBE_HELPER_H_EXIST
    drm/drm_probe_helper.h

    # OS_DRM_DRM_DP_HELPER_H_EXIST
    drm/drm_dp_helper.h

    # OS_DRM_DP_DRM_DP_HELPER_H_EXIST
    drm/dp/drm_dp_helper.h

    # OS_DRM_DISPLAY_DRM_DP_HELPER_H_EXIST
    drm/display/drm_dp_helper.h

    # OS_DRM_DISPLAY_DRM_SCDC_HELPER_H_EXIST
    drm/display/drm_scdc_helper.h

    # OS_DRM_DRM_SCDC_HELPER_H_EXIST
    drm/drm_scdc_helper.h

    # OS_DRM_DRM_FBDEV_GENERIC_H_EXIST
    drm/drm_fbdev_generic.h

    # OS_DRM_DRM_DSC_H_EXIST
    drm/drm_dsc.h

    # OS_DRM_DISPLAY_DRM_DSC_HELPER_H_EXIST
    drm/display/drm_dsc_helper.h

    # OS_DRM_DRM_SELF_REFRESH_HELPER_H_EXIST
    drm/drm_self_refresh_helper.h

    # OS_LINUX_KCONFIG_H_EXIST
    linux/kconfig.h

    # OS_LINUX_COMPILER_ATTRIBUTES_H_EXIST
    linux/compiler_attributes.h

    # OS_LINUX_COMPILER_TYPES_H_EXIST
    linux/compiler_types.h

    # OS_LINUX_FIND_H_EXIST
    linux/find.h

    # OS_LINUX_DMA_RESV_H_EXIST
    linux/dma-resv.h

    # OS_LINUX_DMA_BUF_MAP_H_EXIST
    linux/dma-buf-map.h

    # OS_LINUX_DMA_MAP_OPS_H_EXIST
    linux/dma-map-ops.h

    # OS_LINUX_IOSYS_MAP_H_EXIST
    linux/iosys-map.h

    # OS_LINUX_PCI_P2PDMA_H_EXIST
    linux/pci-p2pdma.h

    # OS_LINUX_MODULE_SIGNATURE_H_EXIST
    linux/module_signature.h

   # OS_LINUX_NOSPEC_H_EXIST
    linux/nospec.h

    # OS_LINUX_MMAP_LOCK_H_EXIST
    linux/mmap_lock.h

    # OS_LINUX_RESERVATION_H_EXIST
    linux/reservation.h

    # OS_GENERATED_AUTOCONF_H_EXIST
    generated/autoconf.h

    # OS_LINUX_FENCE_H_EXIST
    linux/fence.h

    # OS_LINUX_RH_KABI_H_EXIST
    linux/rh_kabi.h

    # OS_LINUX_MAPLE_TREE_H_EXIST
    linux/maple_tree.h

    # OS_LINUX_TIME_H_EXIST
    linux/time.h

    # OS_LINUX_DEVICE_BUS_H_EXIT
    linux/device/bus.h

    # OS_LINUX_SVA_H_EXIST
    linux/sva.h

    # OS_LINUX_SCHED_CLOCK_H_EXIST
    linux/sched/clock.h

    # OS_LINUX_DMA_IOMMU_H_EXIST
    linux/dma-iommu.h
)

#
# TEST_SYMBOLS is a list that checks for the presence of symbols in Module.symvers.
#
# Each @sym_name in the list below will generate a corresponding
# macro which is named with the prefix "OS_IS_EXPORT_SYMBOL_" or
# "OS_IS_EXPORT_SYMBOL_GPL_" (if symbol is exported by EXPORT_SYMBOL_GPL)
# followed by the uppercase of the @sym_name.
#
# @sym_name: symbol_name
#
# example:
#   if @sym_name is test_foo ==> #define OS_IS_EXPORT_SYMBOL_TEST_FOO
#   if @sym_name is test_foo_g (exported by EXPORT_SYMBOL_GPL) ==> #define OS_IS_EXPORT_SYMBOL_GPL_TEST_FOO_G
#
TEST_SYMBOLS=(
    # OS_IS_EXPORT_SYMBOL_GPL_DRM_DISPLAY_MODE_FROM_VIDEOMODE
    drm_display_mode_from_videomode

    # OS_IS_EXPORT_SYMBOL_GPL_DRM_DISPLAY_MODE_TO_VIDEOMODE
    drm_display_mode_to_videomode

    # OS_IS_EXPORT_SYMBOL_GPL_MEMCPY_FROMIO
    memcpy_fromio

    # OS_IS_EXPORT_SYMBOL_GPL_MEMCPY_TOIO
    memcpy_toio

    # OS_IS_EXPORT_SYMBOL_FIND_MODULE
    find_module
)

#
# TEST_FUNCS is a hashmap that checks for the presence of functions
#
# Each @key in the list below will generate a corresponding macro
# which is named with the prefix "OS_FUNC_" followed by the uppercase
# of the @key and the suffix "_EXIST".
#
# @key: function name
# @value: the required header files include source code for @key
#
# example:
#   if @key is test_foo ==> #undef OS_FUNC_TEST_FOO_EXIST
#
TEST_FUNCS=(
    # OS_FUNC_STREAM_OPEN_EXIST
    [stream_open]="
    #include <linux/fs.h>
    "

    # OS_FUNC_DRM_GEM_OBJECT_PUT_UNLOCKED_EXIST
    [drm_gem_object_put_unlocked]="
    $(conftest_include drm/drmP.h)
    #include <drm/drm_gem.h>
    "

    # OS_FUNC_DRM_PLANE_CREATE_BLEND_MODE_PROPERTY_EXIST
    [drm_plane_create_blend_mode_property]="
    #include <drm/drm_blend.h>
    "

    # OS_FUNC_DRM_CONNECTOR_INIT_WITH_DDC_EXIST
    [drm_connector_init_with_ddc]="
    $(conftest_include drm/drmP.h)
    #include <drm/drm_crtc.h>
    "

    # OS_FUNC_DRM_ATOMIC_HELPER_FAKE_VBLANK_EXIST
    [drm_atomic_helper_fake_vblank]="
    #include <drm/drm_atomic_helper.h>
    "

    # OS_FUNC_PLATFORM_FIND_DEVICE_BY_DRIVER_EXIST
    [platform_find_device_by_driver]="
    #include <linux/platform_device.h>
    "

    # OS_FUNC_DMA_BUF_KMAP_EXIST
    [dma_buf_kmap]="
    #include <linux/dma-buf.h>
    "

    # OS_FUNC_VMF_INSERT_MIXED_EXIST
    [vmf_insert_mixed]="
    #include <linux/mm.h>
    "

    # OS_FUNC_DMA_RESV_RESERVE_FENCES_EXIST
    [dma_resv_reserve_fences]="
    $(conftest_include linux/dma-resv.h)
    "

    # OS_FUNC_DMA_RESV_ADD_FENCE_EXIST
    [dma_resv_add_fence]="
    $(conftest_include linux/dma-resv.h)
    "

    # OS_FUNC_DMA_RESV_GET_FENCES_EXIST
    [dma_resv_get_fences]="
    $(conftest_include linux/dma-resv.h)
    "

    # OS_FUNC_DRM_DEBUG_ENABLED_EXIST
    [drm_debug_enabled]="
    #include <drm/drm_print.h>
    "
    # OS_FUNC_GETRAWMONOTONIC_EXIST
    [getrawmonotonic]="
    #include <linux/ktime.h>
    #include <linux/time64.h>
    "

    # OS_FUNC_DMA_RESV_SHARED_LIST_EXIST
    [dma_resv_shared_list]="
    $(conftest_include linux/dma-resv.h)
    "

    # OS_FUNC_DRM_DEV_UNREF_EXIST
    [drm_dev_unref]="
    #include <drm/drm_drv.h>
    "

    # OS_FUNC_DRM_PLANE_HELPER_CHECK_STATE_EXIST
    [drm_plane_helper_check_state]="
    #include <linux/types.h>
    #include <drm/drm_plane_helper.h>
    "

    # OS_FUNC_DRM_CONNECTOR_ATTACH_ENCODER_EXIST
    [drm_connector_attach_encoder]="
    #include <drm/drm_connector.h>
    "

    # OS_FUNC_MMAP_WRITE_LOCK_EXIST
    [mmap_write_lock]="
    $(conftest_include linux/mmap_lock.h)
    "

    # OS_FUNC_MMAP_WRITE_LOCK_KILLABLE_EXIST
    [mmap_write_lock_killable]="
    $(conftest_include linux/mmap_lock.h)
    "

    # OS_FUNC_MMAP_WRITE_UNLOCK_EXIST
    [mmap_write_unlock]="
    $(conftest_include linux/mmap_lock.h)
    "

    # OS_FUNC_MMAP_READ_LOCK_EXIST
    [mmap_read_lock]="
    $(conftest_include linux/mmap_lock.h)
    "

    # OS_FUNC_MMAP_READ_UNLOCK_EXIST
    [mmap_read_unlock]="
    $(conftest_include linux/mmap_lock.h)
    "

    # OS_FUNC___ACCOUNT_LOCKED_VM_EXIST
    [__account_locked_vm]="
    #include <linux/mm.h>
    "

    # OS_FUNC_DRM_PRIME_SG_TO_PAGE_ADDR_ARRAYS_EXIST
    [drm_prime_sg_to_page_addr_arrays]="
    #include <drm/drm_prime.h>
    "

    # OS_FUNC_DRM_GEM_PRIME_FD_TO_HANDLE_EXIST
    [drm_gem_prime_fd_to_handle]="
    #include <drm/drm_prime.h>
    "

    # OS_FUNC_DRM_GEM_PRIME_HANDLE_TO_FD_EXIST
    [drm_gem_prime_handle_to_fd]="
    #include <drm/drm_prime.h>
    "

    # OS_FUNC_DRM_GEM_FB_PREPARE_FB_EXIST
    [drm_gem_fb_prepare_fb]="
    #include <drm/drm_gem_framebuffer_helper.h>
    "

    # OS_FUNC_UACCESS_ENABLE_EXIST
    [uaccess_enable]="
    #include <linux/uaccess.h>
    "

    # OS_FUNC_PDE_DATA_EXIST
    [PDE_DATA]="
    #include <linux/proc_fs.h>
    "

    # OS_FUNC_REMOVE_CONFLICTING_FRAMEBUFFERS_EXIST
    [remove_conflicting_framebuffers]="
    #include <linux/fb.h>
    "

    # OS_FUNC_TASK_SIGPENDING_EXIST
    [task_sigpending]="
    #include <linux/sched/signal.h>
    "

    # OS_FUNC_DMA_FENCE_GET_STUB_EXIST
    [dma_fence_get_stub]="
    #include <linux/dma-fence.h>
    "

    # OS_FUNC_DRM_DSC_COMPUTE_RC_PARAMETERS_EXIST
    [drm_dsc_compute_rc_parameters]="
    $(conftest_include drm/drm_dsc.h)
    $(conftest_include drm/display/drm_dsc_helper.h)
    "

    # OS_FUNC_DRM_DSC_PPS_PAYLOAD_PACK_EXIST
    [drm_dsc_pps_payload_pack]="
    $(conftest_include drm/drm_dsc.h)
    $(conftest_include drm/display/drm_dsc_helper.h)
    "

    # OS_FUNC_MDEV_UUID_EXIST
    [mdev_uuid]="
    #include <linux/pci.h>
    #include <linux/mdev.h>
    "

    # OS_FUNC_MDEV_GET_DRVDATA_EXIST
    [mdev_get_drvdata]="
    #include <linux/pci.h>
    #include <linux/mdev.h>
    "

    # OS_FUNC_MDEV_REGISTER_DEVICE_EXIST
    [mdev_register_device]="
    #include <linux/pci.h>
    #include <linux/mdev.h>
    "

    # OS_FUNC_MDEV_REGISTER_DRIVER
    [mdev_register_driver]="
    #include <linux/pci.h>
    #include <linux/mdev.h>
    "

    # OS_FUNC_MDEV_REGISTER_PARENT_EXIST
    [mdev_register_parent]="
    #include <linux/pci.h>
    #include <linux/mdev.h>
    "

    # OS_FUNC_MDEV_PARENT_DEV_EXIST
    [mdev_parent_dev]="
    #include <linux/pci.h>
    #include <linux/mdev.h>
    "

    # OS_FUNC_VFIO_REGISTER_NOTIFIER_EXIST
    [vfio_register_notifier]="
    #include <linux/vfio.h>
    "

    # OS_FUNC_PCI_STATUS_GET_AND_CLEAR_ERRORS_EXIST
    [pci_status_get_and_clear_errors]="
    #include <linux/pci.h>
    "

    # OS_FUNC_DRM_DEV_HAS_VBLANK_EXIST
    [drm_dev_has_vblank]="
    #include <drm/drm_vblank.h>
    "

    # OS_FUNC_DRM_ATOMIC_CRTC_EFFECTIVELY_ACTIVE_EXIST
    [drm_atomic_crtc_effectively_active]="
    #include <drm/drm_atomic.h>
    "
    # OS_FUNC_PCI_ENABLE_PCIE_ERROR_REPORTING_EXIST
    [pci_enable_pcie_error_reporting]="
    #include <linux/aer.h>
    "

    # OS_FUNC_PCI_DISABLE_PCIE_ERROR_REPORTING_EXIST
    [pci_disable_pcie_error_reporting]="
    #include <linux/aer.h>
    "

    # OS_FUNC_SHRINKER_REGISTER_EXIST
    [shrinker_register]='
    #include <linux/shrinker.h>
    '

    # OS_FUNC_ACPI_BUS_GET_DEVICE_EXIST
    [acpi_bus_get_device]="
    #include <acpi/acpi.h>
    #include <acpi/acpi_bus.h>
    "

    # OS_FUNC_ACPI_MATCH_ACPI_DEVICE_EXIST
    [acpi_match_acpi_device]="
    #include <linux/acpi.h>
    "

    # OS_FUNC_ARCH_LINEAR_MAP_ATTR_SET_CACHED_EXIST
    [arch_linear_map_attr_set_cached]="
    $(conftest_include linux/dma-map-ops.h)
    "
    # OS_FUNC_DEVICE_BYPASS_SMMU_EXIST
    [device_bypass_smmu]="
    $(conftest_include linux/sva.h)
    "

    # OS_FUNC_PIN_USER_PAGES_REMOTE_EXIST
    [pin_user_pages_remote]="
    #include <linux/mm.h>
    "

    # OS_FUNC_UNPIN_USER_PAGES_DIRTY_LOCK_EXIST
    [unpin_user_pages_dirty_lock]="
    #include <linux/mm.h>
    "

    # OS_FUNC_DMA_FENCE_TIMESTAMP_EXIST
    [dma_fence_timestamp]="
    #include <linux/dma-fence.h>
    "

    # OS_FUNC_SCHED_SET_FIFO_LOW_EXIST
    [sched_set_fifo_low]="
    #include <linux/sched.h>
    "
)

#
# TEST_TYPES is a hashmap that checks for the presence of types(struct, union, function).
#
# Each @key in the hashmap below will generate a corresponding macro
# which is named with the prefix "OS_" followed by the uppercase
# of the @key and the suffix "_EXIST", the character " "(space) in
# @key will be replaced by "_".
#
# @key: type name
# @value: the required header files include source code
#
# example:
#   if @key is struct test_foo ==> #define OS_STRUCT_TEST_FOO_EXIST
#   if @key is union test_foos ==> #undef OS_UNION_TEST_FOOS_EXIST
#
TEST_TYPES=(
    # OS_HDMI_CODEC_PLUGGED_CB_EXIST
    [hdmi_codec_plugged_cb]="
    #include <sound/hdmi-codec.h>
    "

    # OS_STRUCT_DMA_BUF_MAP_EXIST
    [struct dma_buf_map]="
    $(conftest_include linux/dma-buf-map.h)
    "

    # OS_STRUCT_IOSYS_MAP_EXIST
    [struct iosys_map]="
    $(conftest_include linux/iosys-map.h)
    "

    # OS_STRUCT_PROC_OPS_EXIST
    [struct proc_ops]="
    #include <linux/proc_fs.h>
    "

    # OS_STRUCT_TIMESPEC_EXIST
    [struct timespec]="
    $(conftest_include linux/time.h)
    "

    # OS_ENUM_DMA_RESV_USAGE_EXIST
    [enum dma_resv_usage]="
    $(conftest_include linux/dma-resv.h)
    "

    # OS_UNION_KTIME_EXIST
    [union ktime]="
    #include <linux/ktime.h>
    "

    # OS_STRUCT_XARRAY_EXIST
    [struct xarray]="
    #include <linux/xarray.h>
    "

    # OS_STRUCT_DMI_DEV_ONBOARD_EXIST
    [struct dmi_dev_onboard]="
    #include <linux/dmi.h>
    "

    # OS_STRUCT_MDEV_TYPE_ATTRIBUTE_EXIST
    [struct mdev_type_attribute]="
    #include <linux/pci.h>
    #include <linux/mdev.h>
    "

    # OS_STRUCT_DMA_RESV_ITER_EXIST
    [struct dma_resv_iter]="
    $(conftest_include linux/dma-resv.h)
    "
)

#
# TEST_TYPE_FIELDS is a hashmap that checks for the presence of type's field.
#
# Each @key in the hashmap below will generate a corresponding macro
# which is named with the prefix "OS_" followed by the uppercase
# of the @key, the character "." in @key will be replaced by "HAS".
#
# @key: type name.field name
# @value: the required header files include source code
#
# example:
#   if @key is struct test_foo.close ==> #define OS_STRUCT_TEST_FOO_HAS_CLOSE
#   if @key is union test_foo.open ==> #undef OS_UNION_TEST_FOO_HAS_OPEN
#
TEST_TYPE_FIELDS=(
    # OS_STRUCT_DRM_PLANE_STATE_HAS_PIXEL_BLEND_MODE
    [struct drm_plane_state.pixel_blend_mode]="
    $(conftest_include drm/drmP.h)
    #include <drm/drm_plane.h>
    "

    # OS_STRUCT_DRM_ENCODER_HELPER_FUNCS_HAS_ATOMIC_ENABLE
    [struct drm_encoder_helper_funcs.atomic_enable]="
    #include <drm/drm_modeset_helper_vtables.h>
    "

    # OS_STRUCT_DRM_ENCODER_HELPER_FUNCS_HAS_ATOMIC_DISABLE
    [struct drm_encoder_helper_funcs.atomic_disable]="
    #include <drm/drm_modeset_helper_vtables.h>
    "

    # OS_STRUCT_DRM_DEVICE_HAS_IRQ_ENABLED
    [struct drm_device.irq_enabled]="
    $(conftest_include drm/drmP.h)
    #include <drm/drm_device.h>
    "

    # OS_STRUCT_DRM_DRIVER_HAS_GEM_VM_OPS
    [struct drm_driver.gem_vm_ops]="
    $(conftest_include drm/drmP.h)
    #include <drm/drm_drv.h>
    "

    # OS_STRUCT_DRM_DRIVER_HAS_GEM_PRIME_MMAP
    [struct drm_driver.gem_prime_mmap]="
    $(conftest_include drm/drmP.h)
    #include <drm/drm_drv.h>
    "

    # OS_STRUCT_DRM_MODE_CONFIG_HAS_ALLOW_FB_MODIFIERS
    [struct drm_mode_config.allow_fb_modifiers]="
    $(conftest_include drm/drmP.h)
    #include <drm/drm_mode_config.h>
    "

    # OS_STRUCT_HDMI_CODEC_OPS_HAS_HOOK_PLUGGED_CB
    [struct hdmi_codec_ops.hook_plugged_cb]="
    #include <sound/hdmi-codec.h>
    "

    # OS_STRUCT_HDMI_CODEC_OPS_HAS_MUTE_STREAM
    [struct hdmi_codec_ops.mute_stream]="
    #include <sound/hdmi-codec.h>
    "

    # OS_STRUCT_DMA_BUF_OPS_HAS_MAP
    [struct dma_buf_ops.map]="
    #include <linux/dma-buf.h>
    "

    # OS_STRUCT_DMA_BUF_OPS_HAS_MAP_ATOMIC
    [struct dma_buf_ops.map_atomic]="
    #include <linux/dma-buf.h>
    "

    # OS_STRUCT_DMA_BUF_OPS_HAS_KMAP
    [struct dma_buf_ops.kmap]="
    #include <linux/dma-buf.h>
    "

    # OS_STRUCT_DMA_BUF_OPS_HAS_KMAP_ATOMIC
    [struct dma_buf_ops.kmap_atomic]="
    #include <linux/dma-buf.h>
    "

    # OS_STRUCT_DEVFREQ_HAS_MIN_FREQ
    [struct devfreq.min_freq]="
    #include <linux/devfreq.h>
    "

    # OS_STRUCT_DRM_DEVICE_HAS_PDEV
    [struct drm_device.pdev]="
    #include <drm/drm_device.h>
    "

    # OS_STRUCT_DRM_CRTC_STATE_HAS_SELF_REFRESH_ACTIVE
    [struct drm_crtc_state.self_refresh_active]="
    #include <drm/drm_crtc.h>
    "

    # OS_STRUCT_DRM_DP_AUX_HAS_DRM_DEV
    [struct drm_dp_aux.drm_dev]="
    $(conftest_include drm/drm_dp_helper.h)
    $(conftest_include drm/dp/drm_dp_helper.h)
    $(conftest_include drm/display/drm_dp_helper.h)
    "

    # OS_STRUCT_VFIO_MIGRATION_OPS_HAS_MIGRATION_GET_DATA_SIZE
    [struct vfio_migration_ops.migration_get_data_size]="
    #include <linux/vfio.h>
    "

    # OS_STRUCT_PCI_DEV_HAS_AER_STATS
    [struct pci_dev.aer_stats]="
    #include <linux/pci.h>
    "

    # OS_STRUCT_KVM_MEMSLOTS_HAS_MEMSLOTS
    [struct kvm_memslots.memslots]="
    #include <linux/kvm_host.h>
    "

    # OS_STRUCT_PCI_DEV_HAS_AER_CAP
    [struct pci_dev.aer_cap]="
    #include <linux/pci.h>
    "

    # OS_STRUCT_GEN_POOL_CHUNK_HAS_OWNER
    [struct gen_pool_chunk.owner]="
    #include <linux/genalloc.h>
    "

    # OS_STRUCT_MM_STRUCT_HAS_MMAP_SEM
    [struct mm_struct.mmap_sem]="
    #include <linux/mm.h>
    "

    # OS_STRUCT_MM_STRUCT_HAS_MMAP_LOCK
    [struct mm_struct.mmap_lock]="
    #include <linux/mm.h>
    "
)

#
# TEST_ENUM_FIELDS is a hashmap that checks for the presence of enum's field.
#
# Each @key in the hashmap below will generate a corresponding macro
# which is named with the prefix "OS_ENUM_" followed by the @key and the suffix "_EXIST".
#
# @key: enum field name
# @value: the required header files include source code
#
# example:
#   if @key is MY_FOO_TEST ==> #define OS_ENUM_MY_FOO_TEST_EXIST
#
TEST_ENUM_FIELDS=(
    # OS_ENUM_DRIVER_PRIME_EXIST
    [DRIVER_PRIME]="
    $(conftest_include drm/drmP.h)
    #include <drm/drm_drv.h>
    "

    # OS_ENUM_SNDRV_PCM_TRIGGER_SUSPEND_EXIST
    [SNDRV_PCM_TRIGGER_SUSPEND]="
    #include <sound/pcm.h>
    "
)

#
# TEST_CUSTOMS is a hashmap that checks for some more complex compatibility
# scenario, such as a function takes several arguments.
#
# Each @key in the hashmap below will generate a corresponding macro
# which is named with the prefix "OS_" followed by the uppercase of @key,
# the character " "(space) in @key will be replaced by "_".
#
# @key: a custom description (only letter and character " "(space) is allowed)
# @value: the full source code that matches this @key (description)
#
# example:
#   if @key is "foo_test has five args" ==> #define OS_FOO_TEST_HAS_FIVE_ARGS
#
TEST_CUSTOMS=(
    # OS_ACCESS_OK_HAS_TWO_ARGS
    [access_ok has two args]="
    #include <linux/uaccess.h>
    void conftest_access_ok_has_two_args(const void __user *ptr,
                                         unsigned long size)
    {
        access_ok(ptr, size);
    }
    "

    # OS_EVENTFD_SIGNAL_HAS_ONE_ARG
    [eventfd_signal has one arg]="
    #include <linux/eventfd.h>
    void conftest_eventfd_signal_has_one_arg(struct eventfd_ctx *ctx)
    {
        eventfd_signal(ctx);
    }
    "

    # OS_DRM_PLANE_HELPER_FUNCS_USE_DRM_ATOMIC_STATE
    [drm_plane_helper_funcs use drm_atomic_state]="
    #include <drm/drm_modeset_helper_vtables.h>
    static void conftest_atomic_update(struct drm_plane *plane,
                                       struct drm_atomic_state *state) {}

    static const struct drm_plane_helper_funcs conftest_funcs = {
        .atomic_update = conftest_atomic_update,
    };
    "

    # OS_DRM_CRTC_HELPER_FUNCS_USE_DRM_ATOMIC_STATE
    [drm_crtc_helper_funcs use drm_atomic_state]="
    #include <drm/drm_modeset_helper_vtables.h>
    static void conftest_atomic_enable(struct drm_crtc *crtc,
                                       struct drm_atomic_state *state) {}

    static const struct drm_crtc_helper_funcs conftest_funcs = {
        .atomic_enable = conftest_atomic_enable,
    };
    "

    # OS_DRM_CONNECTOR_HELPER_FUNCS_USE_DRM_ATOMIC_STATE
    [drm_connector_helper_funcs use drm_atomic_state]="
    #include <drm/drm_modeset_helper_vtables.h>
    static void conftest_atomic_commit(struct drm_connector *connector,
                                       struct drm_atomic_state *state) {}

    static const struct drm_connector_helper_funcs conftest_funcs = {
        .atomic_commit = conftest_atomic_commit,
    };
    "

    # OS_TTY_OPERATIONS_USE_INT_WRITE
    [tty_operations use int write]="
    #include <linux/tty_driver.h>
    static int conftest_write(struct tty_struct *tty,
                              const unsigned char *buf, int count)
    {
        return 0;
    }

    static struct tty_operations conftest_funcs = {
        .write = conftest_write,
    };
    "

    # OS_TTY_OPERATIONS_USE_INT_WRITE_ROOM
    [tty_operations use int write_room]="
    #include <linux/tty_driver.h>
    static int conftest_write_room(struct tty_struct *tty) { return 0; }

    static struct tty_operations conftest_funcs = {
        .write_room = conftest_write_room,
    };
    "

    # OS_DRM_DRIVER_USE_INT_DEBUGFS_INIT
    [drm_driver use int debugfs_init]="
    #include <drm/drm_drv.h>
    static int conftest_debugfs_init(struct drm_minor *minor) { return 0; }

    static struct drm_driver conftest_funcs = {
        .debugfs_init = conftest_debugfs_init,
    };
    "

    # OS_TTY_OPERATIONS_USE_INT_CHARS_IN_BUFFER
    [tty_operations use int chars_in_buffer]="
    #include <linux/tty_driver.h>
    static int conftest_chars_in_buffer(struct tty_struct *tty) { return 0; }

    static struct tty_operations conftest_funcs = {
        .chars_in_buffer = conftest_chars_in_buffer,
    };
    "

    # OS_DRM_DP_LINK_TRAIN_CLOCK_RECOVERY_DELAY_HAS_TWO_ARGS
    [drm_dp_link_train_clock_recovery_delay has two args]="
    $(conftest_include drm/drm_dp_helper.h)
    $(conftest_include drm/dp/drm_dp_helper.h)
    $(conftest_include drm/display/drm_dp_helper.h)
    void conftest_drm_dp_link_train_clock_recovery_delay_has_two_args(struct drm_dp_aux *aux)
    {
        u8 dpcd[DP_RECEIVER_CAP_SIZE];
        drm_dp_link_train_clock_recovery_delay(aux, dpcd);
    }
    "

    # OS_DRM_DP_LINK_TRAIN_CHANNEL_EQ_DELAY_HAS_TWO_ARGS
    [drm_dp_link_train_channel_eq_delay has two args]="
    $(conftest_include drm/drm_dp_helper.h)
    $(conftest_include drm/dp/drm_dp_helper.h)
    $(conftest_include drm/display/drm_dp_helper.h)
    void conftest_drm_dp_link_train_channel_eq_delay_has_two_args(struct drm_dp_aux *aux)
    {
        u8 dpcd[DP_RECEIVER_CAP_SIZE];
        drm_dp_link_train_channel_eq_delay(aux, dpcd);
    }
    "

    # OS_DRM_DRIVER_HAS_LEGACY_PRIME_CALLBACKS
    [drm_driver has legacy prime callbacks]="
    $(conftest_include drm/drmP.h)
    #include <drm/drm_drv.h>
    void conftest_drm_driver_has_gem_and_prime_callbacks(struct drm_driver *drv)
    {
        drv->gem_free_object_unlocked = NULL;
        drv->gem_prime_export = NULL;
        drv->gem_prime_vmap = NULL;
        drv->gem_prime_vunmap = NULL;
        drv->gem_prime_pin = NULL;
        drv->gem_prime_unpin = NULL;
        drv->gem_prime_get_sg_table = NULL;
    }
    "

    # OS_DRM_GEM_PRIME_EXPORT_HAS_TWO_ARGS
    [drm_gem_prime_export has two args]="
    #include <drm/drm_prime.h>
    void conftest_drm_gem_prime_export_has_two_args(struct drm_driver *drv,
                                                    struct drm_gem_object *obj,
                                                    int flags)
    {
        drm_gem_prime_export(obj, flags);
    }
    "

    # OS_DRM_HDMI_AVI_INFOFRAME_FROM_DISPLAY_MODE_HAS_BOOL_ARG
    [drm_hdmi_avi_infoframe_from_display_mode has bool arg]="
    #include <drm/drm_edid.h>
    void conftest_drm_hdmi_avi_infoframe_from_display_mode_has_bool_arg(struct hdmi_avi_infoframe *frame,
                                                                        struct drm_display_mode *mode,
                                                                        bool flag)
    {
        drm_hdmi_avi_infoframe_from_display_mode(frame, mode, flag);
    }
    "

    # OS_MDEV_UUID_RETURNS_GUID_PTR
    [mdev_uuid returns guid ptr]="
    #include <linux/pci.h>
    #include <linux/mdev.h>
    const guid_t *conftest_mdev_uuid_return_guid_ptr(struct mdev_device *mdev)
    {
        return mdev_uuid(mdev);
    }
    "

    # OS_MDEV_REGISTER_DRIVER_NOT_HAS_MODULE_ARG
    [mdev_register_driver not has module arg]="
    #include <linux/pci.h>
    #include <linux/mdev.h>
    const int conftest_mdev_register_driver(struct mdev_driver *drv)
    {
        return mdev_register_driver(drv);
    }
    "

    # OS_BUS_FIND_DEVICE_MATCH_USE_CONST_MODIFIER
    [bus_find_device match use const modifier]="
    #include <linux/device.h>
    int match_func(struct device *dev, const void *data)
    {
        return 0;
    }
    void conftest_bus_find_device_match_use_const_modifier(struct bus_type *bus,
                                                           struct device *start,
                                                           void *data)
    {
        bus_find_device(bus, start, data, match_func);
    }
    "

    # OS_DMA_BUF_OPS_ATTACH_HAS_DEVICE_ARG
    [dma_buf_ops attach has device arg]="
    #include <linux/dma-buf.h>
    void conftest_dma_buf_ops_has_device_arg(struct dma_buf_ops *ops,
                                             struct dma_buf *buf,
                                             struct device *dev,
                                             struct dma_buf_attachment *attachment)
    {
        ops->attach(buf, dev, attachment);
    }
    "

    # OS_RESERVATION_OBJECT_RESERVE_SHARED_HAS_NUM_FENCES_ARG
    [reservation_object_reserve_shared has num_fences arg]="
    $(conftest_include linux/reservation.h)
    void conftest_reservation_object_reserve_shared_has_num_fences_arg(struct reservation_object *obj,
                                                                       unsigned int num_fences)
    {
        reservation_object_reserve_shared(obj, num_fences);
    }
    "

    # OS_GLOBAL_VARIABLE_DRM_DEBUG_EXIST
    [global variable drm_debug exist]="
    $(conftest_include drm/drmP.h)
    #include <drm/drm_print.h>

    unsigned int conftest_global_var_drm_debug_exist(void)
    {
        return drm_debug;
    }
    "

    # OS_SECTION_ARG_TYPE_IS_NON_STRING
    [section arg type is non string]="
    $(conftest_include linux/compiler_attributes.h)
    $(conftest_include linux/compiler_types.h)
    #include <linux/compiler.h>

    static __section(.data.once) __conftest_once;
    "

    # OS_GLOBAL_VARIABLE_DMA_VIRT_OPS_EXIST
    [global variable dma_virt_ops exist]="
    #include <linux/dma-mapping.h>

    const struct dma_map_ops conftest_global_var_dma_virt_ops_exist(void)
    {
        return dma_virt_ops;
    }
    "

    # OS_VM_MAP_RAM_HAS_PGPROT_T_ARG
    [vm_map_ram has pgprot_t arg]="
    #include <linux/vmalloc.h>

    void conftest_vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t prot)
    {
        vm_map_ram(pages, count, node, prot);
    }
    "

    # OS_DRM_ATOMIC_HELPER_CHECK_PLANE_STATE_HAS_DRM_RECT_ARG
    [drm_atomic_helper_check_plane_state has drm_rect arg]="
    #include <drm/drm_atomic_helper.h>

    void conftest_drm_atomic_helper_check_plane_state(struct drm_plane_state *plane_state,
                                                      const struct drm_crtc_state *crtc_state,
                                                      const struct drm_rect *clip,
                                                      int min_scale,
                                                      int max_scale,
                                                      bool can_position,
                                                      bool can_update_disabled)
    {
        drm_atomic_helper_check_plane_state(plane_state, crtc_state, clip, min_scale,
                                            max_scale, can_position, can_update_disabled);
    }
    "

    # OS_DRM_PRIME_PAGES_TO_SG_HAS_TWO_ARG
    [drm_prime_pages_to_sg has two arg]="
    #include <drm/drm_prime.h>
    void conftest_drm_prime_pages_to_sg(struct page **pages, unsigned int nr_pages)
    {
        drm_prime_pages_to_sg(pages, nr_pages);
    }
    "

    # OS_REGISTER_SHRINKER_HAS_ONE_ARG
    [register_shrinker has one arg]="
    #include <linux/types.h>
    #include <linux/atomic.h>
    $(conftest_include linux/rh_kabi.h)
    #include <linux/shrinker.h>
    void conftest_register_shrinker(struct shrinker *shrinker)
    {
        register_shrinker(shrinker);
    }
    "

    # OS_DRM_APERTURE_REMOVE_CONFLICTING_FRAMEBUFFERS_HAS_FOUR_ARG
    [drm_aperture_remove_conflicting_framebuffers has four arg]="
    $(conftest_include drm/drm_aperture.h)
    int conftest_drm_aperture_remove_conflicting_framebuffers(resource_size_t base,
                                                              resource_size_t size,
                                                              bool primary,
                                                              const struct drm_driver *req_driver)
    {
        return drm_aperture_remove_conflicting_framebuffers(base, size, primary, req_driver);
    }
    "

    # OS_LIST_SORT_CMP_USE_CONST_MODIFIER
    [list_sort cmp use const modifier]="
    #include <linux/list_sort.h>

    static int sort_cmp(void *priv, const struct list_head *a, const struct list_head *b)
    {
        return 0;
    }
    void conftest_list_sort_test(void *priv, struct list_head *head)
    {
        list_sort(priv, head, sort_cmp);
    }
    "

    # OS_DRM_SCDC_SET_HIGH_TMDS_CLOCK_RATIO_USE_DRM_CONNECTOR_ARG
    [drm_scdc_set_high_tmds_clock_ratio use drm_connector arg]="
    $(conftest_include drm/display/drm_scdc_helper.h)
    $(conftest_include drm/drm_scdc_helper.h)

    void conftest_drm_scdc_set_high_tmds_clock_ratio(struct drm_connector *connector, bool set)
    {
        drm_scdc_set_high_tmds_clock_ratio(connector, set);
    }
    "

    # OS_DRM_SCDC_SET_SCRAMBLING_USE_DRM_CONNECTOR_ARG
    [drm_scdc_set_scrambling use drm_connector arg]="
    $(conftest_include drm/display/drm_scdc_helper.h)
    $(conftest_include drm/drm_scdc_helper.h)

    void conftest_drm_scdc_set_scrambling(struct drm_connector *connector, bool enable)
    {
        drm_scdc_set_scrambling(connector, enable);
    }
    "

    # OS_MDEV_TYPE_ATTRIBUTES_USE_MDEV_TYPE_ARG
    [mdev_type_attributes use mdev_type arg]="
    #include <linux/pci.h>
    #include <linux/mdev.h>
    static ssize_t conftest_name_show(struct mdev_type *mtype, struct mdev_type_attribute *attr, char *buf)
    {
        return 0;
    }
    static MDEV_TYPE_ATTR_RO(conftest_name);
    "

     # OS_BUS_TYPE_IS_NOT_CONST
    [bus_type is not const]="
    #include <linux/device.h>
    void conftest_bus_type_is_not_const(struct device *dev,
                                        struct bus_type *bus)
    {
        *dev->bus = *bus;
    }
    "

    # OS_VM_FLAGS_IS_NOT_CONST
    [vm_flags is not const]="
    #include <linux/mm_types.h>
    void conftest_vm_flags_is_not_const(struct vm_area_struct *vma,
                                         unsigned long flag)
    {
        vma->vm_flags = flag;
    }
    "

    # OS_IOMMU_MAP_USE_GFP_ARG
    [iommu_map use gfp arg]="
    #include <linux/iommu.h>
    void conftest_iommu_map_use_gfp_arg(struct iommu_domain *domain,
                                        unsigned long iova,
                                        phys_addr_t paddr,
                                        size_t size,
                                        int prot,
                                        gfp_t gfp)
    {
        iommu_map(domain, iova, paddr, size, prot, gfp);
    }
    "

    # OS_KVM_PHYS_ADDR_IOREMP_USE_WC_ARG
    [kvm_phys_addr_ioremap use wc arg]="
    #include <linux/kvm_host.h>
    #if defined(__aarch64__)
    #include <asm/kvm_mmu.h>
    static int conftest_kvm_phys_addr_ioremap(struct kvm *kvm, phys_addr_t guest_ipa,
			                                  phys_addr_t pa, unsigned long size,
                                              bool writable, bool writecombine)
    {
        return kvm_phys_addr_ioremap(kvm, guest_ipa, pa, size, writable, writecombine);
    }
    #endif
    "

    # OS_GET_USER_PAGES_REMOTE_ARGS_HAS_TASK
    [get_user_pages_remote args has task]="
    #include <linux/mm.h>
    static long conftest_get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
				unsigned long start, unsigned long nr_pages,
				unsigned int gup_flags, struct page **pages,
				struct vm_area_struct **vmas, int *locked)
    {
        return get_user_pages_remote(tsk, mm, start, nr_pages, gup_flags, pages, vmas, locked);
    }
    "

    # OS_PIN_USER_PAGES_REMOTE_ARGS_HAS_TASK
    [pin_user_pages_remote args has task]="
    #include <linux/mm.h>
    static long conftest_pin_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
				unsigned long start, unsigned long nr_pages,
				unsigned int gup_flags, struct page **pages,
				struct vm_area_struct **vmas, int *locked)
    {
	return pin_user_pages_remote(tsk, mm, start, nr_pages, gup_flags, pages, vmas, locked);
    }
    "

    # OS_PIN_USER_PAGES_REMOTE_USE_VM_AREA_STRUCT
    [pin_user_pages_remote use vm_area_struct]="
    #include <linux/mm.h>
    long conftest_pin_user_pages_remote(struct mm_struct *mm, unsigned long start,
    					unsigned long nr_pages, unsigned int gup_flags,
					struct page **pages, struct vm_area_struct **vmas, int *locked)
    {
        return pin_user_pages_remote(mm, start, nr_pages, gup_flags, pages, vmas, locked);
    }
    "

    # OS_GET_USER_PAGES_USE_VM_AREA_STRUCT
    [get_user_pages use vm_area_struct]="
    #include <linux/mm.h>
    long conftest_get_user_pages(unsigned long start, unsigned long nr_pages, unsigned int gup_flags,
                                 struct page **pages, struct vm_area_struct **vmas)
    {
        return get_user_pages(start, nr_pages, gup_flags, pages, vmas);
    }
    "

    # OS_GET_USER_PAGES_REMOTE_USE_VM_AREA_STRUCT
    [get_user_pages_remote use vm_area_struct]="
    #include <linux/mm.h>
    long conftest_get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm, unsigned long start,
                                        unsigned long nr_pages, unsigned int gup_flags, struct page **pages,
                                        struct vm_area_struct **vmas, int *locked)
    {
        return get_user_pages_remote(mm, start, nr_pages, gup_flags, pages, vmas, locked);
    }
    "

    # OS_FIXUP_USER_FAULT_ARGS_HAS_TASK
    [fixup_user_fault args has task]="
    #include <linux/mm.h>
    static long conftest_fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
				unsigned long address, unsigned int fault_flags, bool *unlocked)
    {
	return fixup_user_fault(tsk, mm, address, fault_flags, unlocked);
    }
    "

    # OS_MM_STRUCT_LOCKED_VM_IS_ATOMIC
    [mm_struct locked_vm is atomic]="
    #include <linux/mm.h>
    static void conftest_mm_struct_locked_vm_type_check(struct mm_struct *mm)
    {
	atomic_long_add_return(1, &mm->locked_vm);
    }
    "

    # OS_XA_ALLOC_USE_XA_LIMIT
    [xa_alloc use xa_limit]="
    #include <linux/xarray.h>
    static int conftest_xa_alloc_use_xa_limit_check(struct xarray *xa,
						    u32 *id,
						    void *entry,
						    struct xa_limit limit,
						    gfp_t gfp)
    {
	    return xa_alloc(xa, id, entry, limit, gfp);
    }
    "

    # OS_DRM_SYNCOBJ_FIND_FENCE_HAS_FIVE_ARGS
    [drm_syncobj_find_fence has five args]="
    #include <drm/drm_syncobj.h>
    #include <drm/drm_file.h>
    static int conftest_drm_syncobj_find_fence_has_five_args(struct drm_file *file_private,
    							     u32 handle,
							     u64 point,
							     u64 flags,
							     struct dma_fence **fence)
    {
            return drm_syncobj_find_fence(file_private, handle, point, flags, fence);
    }
    "

    # OS_VFS_MKDIR_USE_USER_NAMESPACE
    [vfs_mkdir use user_namespace]="
    #include <linux/fs.h>
    static int conftest_vfs_mkdir_use_user_namespace_check(struct user_namespace *mnt_userns,
							   struct inode *dir,
							   struct dentry *dentry,
							   umode_t mode)
    {
	return vfs_mkdir(mnt_userns, dir, dentry, mode);
    }
    "

    # OS_VFS_MKDIR_USE_MNT_IDMAP
    [vfs_mkdir use mnt_idmap]="
    #include <linux/fs.h>
    static int conftest_vfs_mkdir_use_mnt_idmap_check(struct mnt_idmap *idmap,
						      struct inode *dir,
						      struct dentry *dentry,
						      umode_t mode)
    {
	return vfs_mkdir(idmap, dir, dentry, mode);
    }
    "
)

#
# TEST_TEXT is a hashmap used to check whether the text exists in a header file.
#
# Each @key in the hashmap below will generate a corresponding macro
# which is named with the prefix "OS_" followed by the uppercase
# of the @key, the character " "(space) in @key will be replaced by "_".
#
# @key: macro to be defined.
# @value: header file relative path and text need to be quoted. path and text need
# to be separated by commas
#
# example:
#   if @key is "test foo" ==> #define OS_TEST_FOO
#
TEST_TEXT=(
    # OS_SWAP_FB_IN_LEAGACY_CURSOR
    [swap fb in leagacy cursor]="
    drm/drm_modeset_helper_vtables.h
    swap the framebuffers
    "
)
uppercase()
{
    echo "$1" | tr ' .' '_' | tr '[:lower:]' '[:upper:]'
}

conftest_log()
{
    local msg="$1"
    local level="$2"

    if [ -z "$level" ]; then
        level="INFO"
    fi

    echo -e "[$(uppercase "${CONFTEST_SYM}")][${level}] $msg"

    if [ "$level" == "ERROR" ]; then
        exit 1
    fi
}

conftest_log_err()
{
    conftest_log "$1" "ERROR"
}

conftest_dbg()
{
    if [ $BUILD_TYPE == "debug" ]; then
        return 0
    else
        return 1
    fi
}

conftest_log_dbg()
{
    conftest_log "$1" "DEBUG"
}

conftest_check_log()
{
    conftest_log "checking for $1 ... $2"
}

conftest_write_config_header()
{
    echo -e "$1" >> $CONFTEST_TGT
}

conftest_complete_config_header()
{
    local macro="__$(uppercase $CONFTEST_INC)__"
    local comment="/* This file is generated automatically by $SCRIPT_NAME for kernel \
$KERNELVER $CPU_ARCH from $KERNELDIR. */"
    sort $CONFTEST_TGT -o $CONFTEST_TGT
    sed -i "1i $comment\n\n#ifndef $macro\n#define $macro\n" $CONFTEST_TGT
    conftest_write_config_header "\n#endif /* $macro */"
}

conftest_test_targets_precheck()
{
    for check_item in "${!TEST_FUNCS[@]}"; do
        conftest_header_precheck "$check_item" "${TEST_FUNCS[$check_item]}"
    done

    for check_item in "${!TEST_TYPES[@]}"; do
        conftest_header_precheck "$check_item" "${TEST_TYPES[$check_item]}"
    done

    for check_item in "${!TEST_TYPE_FIELDS[@]}"; do
        conftest_header_precheck "$check_item" "${TEST_TYPE_FIELDS[$check_item]}"
    done

    for check_item in "${!TEST_ENUM_FIELDS[@]}"; do
        conftest_header_precheck "$check_item" "${TEST_ENUM_FIELDS[$check_item]}"
    done

    for check_item in "${!TEST_CUSTOMS[@]}"; do
        conftest_header_precheck "$check_item" "${TEST_CUSTOMS[$check_item]}"
    done
}

conftest_header_exists()
{
    local file="$1"

    if [[ -e ${HEADERS}/$file ]] || \
       [[ -e ${ARCH_HEADERS}/$file ]] || \
       [[ -e ${ARCH_HEADERS}/uapi/$file ]] || \
       [[ -e ${ARCH_HEADERS}/generated/$file ]] || \
       [[ -e ${ARCH_HEADERS}/generated/uapi/$file ]]; then
	return 0
    elif [[ -e ${EXTRA_SOURCES} ]]; then
	if [[ -e ${EXTRA_HEADERS}/$file ]] || \
           [[ -e ${EXTRA_ARCH_HEADERS}/$file ]] || \
           [[ -e ${EXTRA_ARCH_HEADERS}/uapi/$file ]] || \
           [[ -e ${EXTRA_ARCH_HEADERS}/generated/$file ]] || \
           [[ -e ${EXTRA_ARCH_HEADERS}/generated/uapi/$file ]]; then
            return 0
        else
	    return 1
	fi
    else
        return 1
    fi
}

#
# Do some precheck of header presence(code like '#include <xx/xx.h>' ) in TEST_TARGET,
# to avoid generating wrong result if we can't find the header file.
# If the check fails, the script exits with a log  indicating the error
# location, cause, and recommended solution.
#
conftest_header_precheck()
{
    local check_item="$1"
    local check_code="$2"
    local conftest_inc_scope=0
    local file=""

    while read -r header; do
        [[ -z "$header" ]] && continue
        [[ "$header" != "#"* ]] && continue
        [[ "$header" =~ "#if" ]] && conftest_inc_scope=1 && continue
        [[ "$header" =~ "#endif" ]] && conftest_inc_scope=0 && continue
        [[ $conftest_inc_scope -eq 1 ]] && continue

        file=$(echo "$header" | sed 's/#include[[:space:]]\+<\(.*\)>.*/\1/g')
        if ! conftest_header_exists "$file"; then
            rm -f $CONFTEST_TGT
            conftest_log_err "$file not found, failed to precheck [$check_item], consider \
using conftest_include and TEST_HEADERS API to handle this situation."
        fi
    done <<< "$check_code"
}

conftest_test_header_exist()
{
    local file="$1"
    local macro="$(conftest_make_exist_macro "$file")"
    local check_res="no"

    if conftest_header_exists "$file"; then
        conftest_write_config_header "#define $macro"
        check_res="yes"
    else
        conftest_write_config_header "#undef $macro"
    fi

    conftest_check_log "header $file" "$check_res"
}

conftest_test_func_exist()
{
    local func="$1"
    local header="$2"
    local macro="$(conftest_make_exist_macro "FUNC_$func")"
    local src_code="
    $header
    void ${CONFTEST_SYM}_${func}(void)
    {
        (void)${func}();
    }
    "

    conftest_compile_check "$src_code" "$macro" "function" "$func"
}

conftest_test_type_exist()
{
    local type="$1"
    local header="$2"
    local macro="$(conftest_make_exist_macro "$type")"
    local src_code="
    $header
    $type ${CONFTEST_SYM}_${type// /_};
    "

    conftest_compile_check "$src_code" "$macro" "type" "$type"
}

conftest_test_type_field_exist()
{
    local type="$1"
    local field="$2"
    local header="$3"
    local desc="$type has field $field"
    local macro="${CONFTEST_MACRO_PREFIX}$(uppercase "$type")_HAS_$(uppercase "$field")"
    local src_code="
    $header
    int ${CONFTEST_SYM}_${type// /_}_has_${field}(void)
    {
        return offsetof($type, $field);
    }
    "

    conftest_compile_check "$src_code" "$macro" "type" "$desc"
}

conftest_test_enum_field_exist()
{
    local enum_field="$1"
    local header="$2"
    local macro="$(conftest_make_exist_macro "ENUM_$enum_field")"
    local src_code="
    $header
    unsigned int ${CONFTEST_SYM}_enum_$enum_field(void)
    {
        return $enum_field;
    }
    "

    conftest_compile_check "$src_code" "$macro" "type enum" "$enum_field"
}

conftest_test_custom_check_item()
{
    local src_code="$1"
    local macro="${CONFTEST_MACRO_PREFIX}$2"
    local desc="$3"

    conftest_compile_check "$src_code" "$macro" "custom" "$desc"
}

conftest_test_text_exist()
{
    local arg1="$1"
    local arg2="$2"
    local i=0

    while read -r line; do
        [[ -z "$line" ]] && continue
        [[ $i -eq 0 ]] && local file=$line && ((i++))
        [[ $i -eq 1 ]] && local text=$line
    done <<< "$arg2"

    local header=${HEADERS}/$file
    local macro="$(uppercase "${CONFTEST_MACRO_PREFIX}$arg1")"
    local grep_res="$(grep "$text" $header)"

    conftest_text_check "$grep_res" "$macro"
}

conftest_text_check()
{
    local grep_res="$1"
    local macro="$2"

    if [ "$grep_res" == "" ]; then
        conftest_write_config_header "#undef $macro"
    else
        conftest_write_config_header "#define $macro"
    fi
}

#
# Add conftest_dbg_lock and conftest_dbg_unlock
# to ensure that debug logs are printed in the correct
# order under parallel compilation.
#
conftest_dbg_lock()
{
    while ! mkdir $CONFTEST_DBG_LOCK > /dev/null 2>&1; do
        sleep 1
    done
}

conftest_dbg_unlock()
{
    rmdir $CONFTEST_DBG_LOCK
}

conftest_compile_check()
{
    local src_code="$1"
    local macro="$2"
    local type="$3"
    local check_desc="$4"
    local check_res="no"
    local compile_res=""
    local cflags="$CFLAGS"

    CONFTEST_SRC_FILE="${WORK_DIR}/${CONFTEST_SYM}_src_$macro"
    echo "$CONFTEST_COMPILE_PREAMBLE
    $src_code" > ${CONFTEST_SRC_FILE}.c

    [[ "${type}" == "custom" ]] && cflags+=" -Werror=implicit-function-declaration"

    compile_res="$($CC $cflags -c ${CONFTEST_SRC_FILE}.c -o ${CONFTEST_SRC_FILE}.o 2>&1)"
    if conftest_dbg; then
        conftest_dbg_lock
        local line=1
        conftest_log_dbg ""
        conftest_log_dbg "$DBG_SEPARATOR"
        conftest_log_dbg "TEST $check_desc - $macro START"
        conftest_log_dbg "TEST CODE(${CONFTEST_SRC_FILE}.c):"
        while IFS= read -r code; do
            if [ $line -lt 10 ]; then
                conftest_log_dbg "$line $code"
            else
                conftest_log_dbg "$line$code"
            fi
            let line++
        done < ${CONFTEST_SRC_FILE}.c

        conftest_log_dbg "TEST COMPILE DETAILS:"
        while IFS= read -r compile_info; do
            conftest_log_dbg "$compile_info"
        done <<< "$compile_res"
    fi

    if [ "${type}" == "function" ]; then
        if [[ "$compile_res" =~ implicit\ declaration\ of\ function[\ \'\‘]+$check_desc ]]; then
            conftest_write_config_header "#undef $macro"
        else
            conftest_write_config_header "#define $macro"
            check_res="yes"
        fi
    else
        if [ -f ${CONFTEST_SRC_FILE}.o ]; then
            if [[ $CC_SUPPORT_OPT_WIPT -eq 0 ]] && \
               [[ "$compile_res" =~ "incompatible pointer type" ]]; then
                conftest_write_config_header "#undef $macro"
            else
                conftest_write_config_header "#define $macro"
                check_res="yes"
            fi
        else
            conftest_write_config_header "#undef $macro"
        fi
    fi

    conftest_check_log "$type $check_desc" "$check_res"
    rm -f ${CONFTEST_SRC_FILE}.*

    if conftest_dbg; then
        conftest_log_dbg "TEST $check_desc - $macro END"
        conftest_log_dbg "$DBG_SEPARATOR"
        conftest_log_dbg ""
        conftest_dbg_unlock
    fi
}

conftest_test_custom()
{
    for custom in "${!TEST_CUSTOMS[@]}"; do
    {
        local desc="$custom"
        local src_code="${TEST_CUSTOMS[$desc]}"
        local macro="$(uppercase "$desc")"

        conftest_test_custom_check_item "$src_code" "$macro" "$desc"
    }&
    done
}

conftest_test_things_exist()
{
    for header in "${TEST_HEADERS[@]}"; do
    {
        conftest_test_header_exist "$header"
    }&
    done
    # The header detection task must be completed first because
    # the rest of the compilation detection task depends on it.
    # So here we wait for the subprocess corresponding to the
    # detecting header file task to complete.
    wait

    for func in "${!TEST_FUNCS[@]}"; do
    {
        conftest_test_func_exist "$func" "${TEST_FUNCS[$func]}"
    }&
    done

    for type in "${!TEST_TYPES[@]}"; do
    {
        conftest_test_type_exist "$type" "${TEST_TYPES[$type]}"
    }&
    done

    for type_field in "${!TEST_TYPE_FIELDS[@]}"; do
    {
        local tmps=(${type_field//./ })
        local type="${tmps[0]} ${tmps[1]}"
        local field="${tmps[2]}"
        conftest_test_type_field_exist "$type" "$field" "${TEST_TYPE_FIELDS[$type_field]}"
    }&
    done

    for enum_field in "${!TEST_ENUM_FIELDS[@]}"; do
    {
        conftest_test_enum_field_exist "$enum_field" "${TEST_ENUM_FIELDS[$enum_field]}"
    }&
    done

    for text in "${!TEST_TEXT[@]}"; do
    {
        conftest_test_text_exist "$text" "${TEST_TEXT[$text]}"
    }&
    done
}

conftest_test_export_symbol_exist()
{
    local symbol="$1"
    local sym_res
    local tag="IS_EXPORT_SYMBOL"
    local check_res="no"

    local macro="${CONFTEST_MACRO_PREFIX}${tag}_$(uppercase "$symbol")"

    if [ -e "$SOURCES_SYM_FILE" ]; then
	    sym_res="$(grep -w "$symbol" "$SOURCES_SYM_FILE")"
    fi

    if [ -n "$sym_res" ]; then
        conftest_write_config_header "#define $macro"
        check_res="yes"
    else
        conftest_write_config_header "#undef $macro"
    fi

    conftest_check_log "symbol $symbol" "$check_res"
}

conftest_test_symbols()
{
    for symbol in "${TEST_SYMBOLS[@]}"; do
        conftest_test_export_symbol_exist "$symbol"
    done
}

build_cflags()
{
    local base_cflags="-O2 -D__KERNEL__"
    base_cflags+=" -DKBUILD_BASENAME=\"#${CONFTEST_SRC_FILE}\" -DKBUILD_MODNAME=\"#${CONFTEST_SRC_FILE}\""
    base_cflags+=" -nostdinc -isystem $($CC -print-file-name=include 2> /dev/null)"
    base_cflags+=" -fno-pie -fno-strict-aliasing -ffreestanding -MD"
    base_cflags+=" -Wall -Wno-cast-qual -Wno-error -Wno-format-extra-args -Wno-unused-function"
    base_cflags+=" -Wuninitialized -Wno-pointer-sign"
    base_cflags+=" -Werror=undef"
    base_cflags+=" -fshort-wchar"

    if [ $CC_SUPPORT_OPT_WIPT -eq 1 ]; then
        base_cflags+=" -Werror=incompatible-pointer-types"
    fi

    if [ "$CPU_ARCH" == "arm64" ]; then
        base_cflags+=" -mstrict-align -mgeneral-regs-only -march=armv8-a"
    fi

    if [ "$CPU_ARCH" == "x86_64" ]; then
        base_cflags+=" -mno-red-zone -mcmodel=kernel"
    fi

    if [ "$CPU_ARCH" == "loongarch" ]; then
        base_cflags+=" -D_LOONGARCH_ISA=_LOONGARCH_ISA_LOONGARCH64"
    fi

    local sys_autoconf_header
    if [ -f "$HEADERS/generated/autoconf.h" ]; then
        sys_autoconf_header="$HEADERS/generated/autoconf.h"
    else
        sys_autoconf_header="$HEADERS/linux/autoconf.h"
    fi

    CFLAGS="$base_cflags -include $sys_autoconf_header -I${WORK_DIR}"
    CFLAGS+=" -I${HEADERS}"
    CFLAGS+=" -I${HEADERS}/uapi"
    CFLAGS+=" -I${HEADERS}/generated/uapi"
    CFLAGS+=" -I${ARCH_HEADERS}"
    CFLAGS+=" -I${ARCH_HEADERS}/uapi"
    CFLAGS+=" -I${ARCH_HEADERS}/generated"
    CFLAGS+=" -I${ARCH_HEADERS}/generated/uapi"
    if [ -e "$EXTRA_SOURCES" ]; then
        CFLAGS+=" -I${EXTRA_HEADERS}"
        CFLAGS+=" -I${EXTRA_HEADERS}/uapi"
        CFLAGS+=" -I${EXTRA_HEADERS}/generated/uapi"
        CFLAGS+=" -I${EXTRA_ARCH_HEADERS}"
        CFLAGS+=" -I${EXTRA_ARCH_HEADERS}/uapi"
        CFLAGS+=" -I${EXTRA_ARCH_HEADERS}/generated"
        CFLAGS+=" -I${EXTRA_ARCH_HEADERS}/generated/uapi"
    fi

    #
    # If CONFIG_HAVE_FENTRY is enabled and gcc supports -mfentry flags then set
    # CC_USING_FENTRY and add -mfentry into cflags.
    #
    # linux/ftrace.h file indirectly gets included into the autoconf source and
    # fails to get compiled, because this scripts runs outside of Kbuild it ends
    # up building without -mfentry and CC_USING_FENTRY flags.
    #
    if grep "CONFIG_HAVE_FENTRY \+1" "$sys_autoconf_header" > /dev/null 2>&1; then
        touch $CONFTEST_SRC_FILE.c

        $CC -mfentry -c -x c ${CONFTEST_SRC_FILE}.c -o ${CONFTEST_SRC_FILE}.o > /dev/null 2>&1
        if [ -f ${CONFTEST_SRC_FILE}.o ]; then
            CFLAGS+=" -mfentry -DCC_USING_FENTRY"
        fi
        rm -f ${CONFTEST_SRC_FILE}*
    fi

    if conftest_dbg; then
        conftest_log_dbg "CFLAGS: $CFLAGS"
    fi
}

check_cmd()
{
    local cmd="$1"
    if ! which "$cmd" > /dev/null 2>&1; then
        conftest_log_err "$cmd not found which is needed by ${SCRIPT_NAME}!"
    fi
}

env_check_and_set()
{
    CC=${KERNEL_CC:-"cc"}
    local cmds=(
        tr
        $CC
        sort
    )
    for cmd in "${cmds[@]}"; do
        check_cmd "$cmd"
    done

    CPU_ARCH=${ARCH:-"x86_64"}
    KERNEL_ARCH=$CPU_ARCH

    if [[ -z "$KERNELDIR" || -z "$KERNELVER" ]]; then
        conftest_log_err "Env KERNELDIR and KERNELVER are essential to run $SCRIPT_NAME"
    fi

    if [ ! -d "$KERNELDIR" ]; then
        conftest_log_err "Env KERNELDIR $KERNELDIR not found!"
    fi

    SOURCES="$KERNELDIR"
    HEADERS="${SOURCES}/include"
    SOURCES_SYM_FILE="${SOURCES}/Module.symvers"
    if [ ! -e "$SOURCES_SYM_FILE" ]; then
        conftest_log "$SOURCES_SYM_FILE not found!"
    fi

    if [[ "$CPU_ARCH" == "x86_64" || "$CPU_ARCH" == "i386" ]]; then
        KERNEL_ARCH="x86"
    fi
    local knl_arch_path="$SOURCES/arch/$KERNEL_ARCH"

    if [ ! -d "$knl_arch_path" ]; then
        conftest_log_err "$knl_arch_path not found!"
    fi

    ARCH_HEADERS="${knl_arch_path}/include"

    # /lib/modules/xxx/build and /lib/modules/xxx/source both exist
    EXTRA_SOURCES="$KERNELSRC"
    if [ -e "$EXTRA_SOURCES" ]; then
	local extra_knl_arch_path="$EXTRA_SOURCES/arch/$KERNEL_ARCH"
	EXTRA_HEADERS="${EXTRA_SOURCES}/include"
	if [ ! -d "$extra_knl_arch_path" ]; then
	    conftest_log_err "$extra_knl_arch_path not found!"
	fi
	EXTRA_ARCH_HEADERS="${extra_knl_arch_path}/include"
    fi

    # clear file
    > $CONFTEST_TGT

    if $CC --help=warning | grep "incompatible-pointer-types" > /dev/null 2>&1; then
        CC_SUPPORT_OPT_WIPT=1
    fi

    build_cflags

    CONFTEST_COMPILE_PREAMBLE="
    #include \"$CONFTEST_INC\"
    $(conftest_include linux/kconfig.h)
    #if defined($(conftest_make_exist_macro generated/autoconf.h))
    #include <generated/autoconf.h>
    #else
    #include <linux/autoconf.h>
    #endif
    "
}

usage()
{
    cat <<EOF
Options:
    -v | --mode=<debug|release>
    -a | --arch=<${SUPPORTED_ARCHS[@]}>
    -k | --kernever=<conftest kernel version>
    -d | --kerneldir=<conftest kernel header dir>
    -e | --kernelsrc=<conftest kernel source dir>
    -c | --kernel_cc=<cross compile gcc>
    -h | --help
EOF
    exit 0
}

die()
{
    echo "$*" >&2;
    exit 2;
}

needs_arg()
{
    if [ -z "$OPTARG" ]; then
        usage
        die "No arg for --$OPT option";
    fi;
}

conftest_run()
{
    conftest_log "Start checking for kernel $KERNELVER $CPU_ARCH"
    conftest_test_targets_precheck
    conftest_test_things_exist
    conftest_test_custom
    conftest_test_symbols

    # Before completing the header file, it is necessary to wait for all
    # the subprocesses corresponding to the compile detection task to complete.
    wait
    conftest_complete_config_header
}

#
# Only when the macro is modified, conftest check and run need to be executed,
# and the macro modification generally occurs in the TEST_TARGET file,
# so we can compare the last modification time of these two files,
# which determine whether we need to execute the conftest check and run.
#
conftest_needs_to_run()
{
    if conftest_dbg; then
        return 0
    fi

    # dkms package combined $CONFTEST_TGT and $WORK_DIR/TEST_TARGET,
    # conftest run every time dkms building.
    if [[ ! -f "$CONFTEST_TGT" || ! -f "$WORK_DIR/TEST_TARGET" ]]; then
        return 0
    fi

    local comment="$(head -1 $CONFTEST_TGT)"
    if [[ "$comment" =~ "$KERNELDIR." ]]; then
        local last_time1=$(stat -c %Y $CONFTEST_TGT)
        local last_time2=$(stat -c %Y $WORK_DIR/TEST_TARGET)
        if [ $last_time2 -gt $last_time1 ]; then
            return 0
        else
            return 1
        fi
    else
        return 0
    fi
}

set_opts()
{
    while getopts a:k:d:e:v:c:h-: OPT; do
        if [ "$OPT" = "-" ]; then   # long option: reformulate OPT and OPTARG
            OPT="${OPTARG%%=*}"       # extract long option name
            OPTARG="${OPTARG#$OPT}"   # extract long option argument (may be empty)
            OPTARG="${OPTARG#=}"      # if long option argument, remove assigning `=`
        fi
        case "$OPT" in
            a | arch )      needs_arg; ARCH="$OPTARG" ;;
            k | kernelver ) needs_arg; KERNELVER="$OPTARG" ;;
            d | kerneldir ) needs_arg; KERNELDIR="$OPTARG" ;;
            e | kernelsrc ) needs_arg; KERNELSRC="$OPTARG" ;;
            v | mode )      needs_arg; BUILD_TYPE="$OPTARG" ;;
            c | kernel_cc ) needs_arg; KERNEL_CC="$OPTARG" ;;
            h | help )      usage; exit 2;;
            ??* )           die "Illegal option --$OPT" ;;  # bad long option
            ? )             exit 2 ;;  # bad short option (error reported via getopts)
        esac
    done
}

main()
{
    set_opts $@
    if conftest_needs_to_run; then
        env_check_and_set
        conftest_run
    else
        conftest_log "No KAPI check item change detected, check ignored"
    fi
}

main $@

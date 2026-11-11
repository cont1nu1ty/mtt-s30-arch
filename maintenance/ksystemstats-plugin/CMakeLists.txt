cmake_minimum_required(VERSION 3.20)
project(ksystemstats_plugin_gpu LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(ECM REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

find_package(Qt6 REQUIRED COMPONENTS Core)
find_package(KF6 REQUIRED COMPONENTS CoreAddons I18n Service)
find_package(KSysGuard REQUIRED COMPONENTS SystemStats ProcessCore)
find_package(PkgConfig REQUIRED)
pkg_check_modules(UDev REQUIRED libudev)
find_path(SENSORS_INCLUDE_DIR sensors/sensors.h)
find_library(SENSORS_LIBRARIES sensors)

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMQtDeclareLoggingCategory)



configure_file(IntelHelperLocation.h.cmake IntelHelperLocation.h)
add_library(ksystemstats_plugin_gpu MODULE
    GpuPlugin.cpp
    GpuBackend.cpp
    GpuDevice.cpp
    AllGpus.cpp
    LinuxBackend.cpp
    LinuxAmdGpu.cpp
    LinuxIntelGpu.cpp
    LinuxNvidiaGpu.cpp
    NvidiaGpu.cpp
    NvidiaSmiProcess.cpp
)

ecm_qt_declare_logging_category(ksystemstats_plugin_gpu HEADER debug.h
    IDENTIFIER KSYSTEMSTATS_GPU
    CATEGORY_NAME org.kde.ksystemstats.gpu
    DESCRIPTION "KSystemStats GPU Plugin"
)

target_include_directories(ksystemstats_plugin_gpu PRIVATE
    ${UDev_INCLUDE_DIRS}
    ${SENSORS_INCLUDE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
)

target_link_libraries(ksystemstats_plugin_gpu
    Qt6::Core
    KF6::CoreAddons
    KF6::I18n
    KSysGuard::SystemStats
    KSysGuard::ProcessCore
    ${UDev_LIBRARIES}
    ${SENSORS_LIBRARIES}
)

install(TARGETS ksystemstats_plugin_gpu DESTINATION /usr/lib/mtgpu/plugins/ksystemstats)

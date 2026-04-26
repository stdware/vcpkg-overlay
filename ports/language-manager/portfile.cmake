set(VCPKG_POLICY_ALLOW_DLLS_IN_LIB enabled)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
        FEATURES
        cuda11 WITH_CUDA11
        cuda12 WITH_CUDA12
        "install-ort" WITH_INSTALL_ORT
)

if (${WITH_CUDA11} AND ${WITH_CUDA12})
    message(FATAL_ERROR "Cannot enable both cuda11 and cuda12 at the same time")
endif ()

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO wolfgitpr/language-manager
        REF 706bed793288234d7f16548c01e645c4bcee243a
        SHA512 3c60c23c9b8fcf1c9c65901580a2e43aab9f2d7ac2e0f5ca4e42e30eefe1d10fdd9b8c022d4adda64d78a5670930208a92ef2ad2090784d4b0e37a2a8684d521
        HEAD_REF plugin
)

# Download ONNX Runtime
include("${CMAKE_CURRENT_LIST_DIR}/setup-onnxruntime/setup.cmake")
set(_ort_deploy_prefix "${SOURCE_PATH}/third-party/onnxruntime")
message(STATUS "OS: ${_os_display_name}")
if (VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Downloading DirectML version of ONNX Runtime...")
    set(_ort_deploy_suffix "default")
    set(_deploy_dst_dir "${_ort_deploy_prefix}/${_ort_deploy_suffix}")
    download_onnxruntime_from_nuget("${_deploy_dst_dir}")
    download_dml_from_nuget("${_deploy_dst_dir}")
else ()
    message(STATUS "Downloading CPU version of ONNX Runtime...")
    set(_ort_deploy_suffix "default")
    set(_deploy_dst_dir "${_ort_deploy_prefix}/${_ort_deploy_suffix}")
    download_onnxruntime_from_github("cpu" "${_deploy_dst_dir}")
endif ()

# Optional GPU (CUDA) version download
if (${WITH_CUDA12})
    message(STATUS "Downloading GPU (CUDA 12.x) version of ONNX Runtime...")
    set(_ort_deploy_suffix "cuda")
    set(_deploy_dst_dir "${_ort_deploy_prefix}/${_ort_deploy_suffix}")
    download_onnxruntime_from_github("cuda12" "${_deploy_dst_dir}")
elseif (${WITH_CUDA11})
    message(STATUS "Downloading GPU (CUDA 11.x) version of ONNX Runtime...")
    set(_ort_deploy_suffix "cuda")
    set(_deploy_dst_dir "${_ort_deploy_prefix}/${_ort_deploy_suffix}")
    download_onnxruntime_from_github("cuda11" "${_deploy_dst_dir}")
endif ()

# Configure language manager
vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
        -DLANGMGR_BUILD_PLUGINS:BOOL=ON
        -DLANGPLUGINS_INSTALL_ORT:BOOL=${WITH_INSTALL_ORT}
        -DLANGMGR_VCPKG_DIR=${CURRENT_PACKAGES_DIR}/share/LangCore
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
        PACKAGE_NAME
        LangCore
        CONFIG_PATH
        lib/cmake/LangCore
        # DO NOT omit `DO_NOT_DELETE_PARENT_CONFIG_PATH` option!
        # Otherwise dsinfer config will be also deleted,
        # failing the next command (fix up dsinfer config).
        DO_NOT_DELETE_PARENT_CONFIG_PATH
)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

set(VCPKG_POLICY_ALLOW_DLLS_IN_LIB enabled)
set(VCPKG_POLICY_SKIP_LIB_CMAKE_MERGE_CHECK enabled)
set(VCPKG_POLICY_SKIP_MISPLACED_CMAKE_FILES_CHECK enabled)
set(VCPKG_POLICY_ALLOW_EMPTY_FOLDERS enabled)
# Payload-only port: binaries/headers intentionally live under include/ lib/
# bin/ (see below), not in the conventional INTERFACE include layout.
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
# Release-only payload (downloaded binaries, no debug build follows the
# same ABI); suppress the mismatched debug/release count check.
set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cuda11 WITH_CUDA11
        cuda12 WITH_CUDA12
)

if(${WITH_CUDA11} AND ${WITH_CUDA12})
    message(FATAL_ERROR "Cannot enable both cuda11 and cuda12 at the same time")
endif()

# Download ONNX Runtime and deploy into the standard vcpkg layout:
#   include/   ONNX Runtime headers (DirectML/CUDA variants also land here)
#   bin/       default runtime DLLs (Windows; DirectML + provider)
#   lib/       import libraries (when the downloaded payload ships any) and,
#              on non-Windows, the shared objects (libonnxruntime.so/dylib)
#   lib/cuda/  CUDA runtime DLLs (only with a CUDA feature)
# Consumers find this package via find_package(onnxruntime-builds CONFIG) and
# read ONNXRUNTIME_BUILDS_INCLUDE_DIR / RUNTIME_DIR / CUDA_RUNTIME_DIR.
include("${CMAKE_CURRENT_LIST_DIR}/setup-onnxruntime/setup.cmake")
message(STATUS "OS: ${_os_display_name}")
if(VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Downloading DirectML version of ONNX Runtime...")
    download_onnxruntime_from_nuget("${CURRENT_PACKAGES_DIR}")
    download_dml_from_nuget("${CURRENT_PACKAGES_DIR}")

    # Move default runtime DLLs from lib/ (where setup.cmake puts them) to bin/
    # (vcpkg runtime convention) and mirror them into the port-private
    # share/onnxruntime-builds/runtime/ directory. bin/ is shared with other
    # packages, so consumers must glob the private directory instead.
    file(GLOB _ort_default_dlls "${CURRENT_PACKAGES_DIR}/lib/*.dll")
    if(_ort_default_dlls)
        set(_private_runtime_dir "${CURRENT_PACKAGES_DIR}/share/onnxruntime-builds/runtime")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin" "${_private_runtime_dir}")
        foreach(_dll IN LISTS _ort_default_dlls)
            get_filename_component(_dll_name "${_dll}" NAME)
            file(COPY "${_dll}" DESTINATION "${_private_runtime_dir}")
            file(RENAME "${_dll}" "${CURRENT_PACKAGES_DIR}/bin/${_dll_name}")
        endforeach()
    endif()
else()
    message(STATUS "Downloading CPU version of ONNX Runtime...")
    download_onnxruntime_from_github("cpu" "${CURRENT_PACKAGES_DIR}")
    # Same reasoning as the Windows branch: expose the default runtime from a
    # port-private directory instead of the shared lib/.
    file(GLOB _ort_default_libs "${CURRENT_PACKAGES_DIR}/lib/*.so"
         "${CURRENT_PACKAGES_DIR}/lib/*.so.*" "${CURRENT_PACKAGES_DIR}/lib/*.dylib")
    if(_ort_default_libs)
        set(_private_runtime_dir "${CURRENT_PACKAGES_DIR}/share/onnxruntime-builds/runtime")
        file(MAKE_DIRECTORY "${_private_runtime_dir}")
        foreach(_lib IN LISTS _ort_default_libs)
            file(COPY "${_lib}" DESTINATION "${_private_runtime_dir}")
        endforeach()
    endif()
endif()

# Optional GPU (CUDA) runtime deployment
if(${WITH_CUDA12})
    message(STATUS "Downloading GPU (CUDA 12.x) version of ONNX Runtime...")
    download_onnxruntime_from_github("cuda12" "${CURRENT_PACKAGES_DIR}")
elseif(${WITH_CUDA11})
    message(STATUS "Downloading GPU (CUDA 11.x) version of ONNX Runtime...")
    download_onnxruntime_from_github("cuda11" "${CURRENT_PACKAGES_DIR}")
endif()

if(WITH_CUDA11 OR WITH_CUDA12)
    # CUDA DLLs land in lib/ alongside the (possibly empty) default leftovers;
    # move them to lib/cuda so consumers can tell them apart.
    file(GLOB _ort_cuda_dlls "${CURRENT_PACKAGES_DIR}/lib/*.dll")
    if(_ort_cuda_dlls)
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/cuda")
        foreach(_dll IN LISTS _ort_cuda_dlls)
            get_filename_component(_dll_name "${_dll}" NAME)
            file(RENAME "${_dll}" "${CURRENT_PACKAGES_DIR}/lib/cuda/${_dll_name}")
        endforeach()
    endif()
endif()

# Provide a CMake package so synthrt (and other consumers) can use
# find_package(onnxruntime-builds) without the port passing any path.
# No edit needed for share directory creation (created by the mirror above on
# Windows / non-Windows default paths, and by CUDA handling when applicable).
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/onnxruntime-builds")
# Point consumers at the port-private runtime directory (never the shared
# bin/ or lib/, which contain other packages' binaries).
set(_ort_config_runtime_dir "share/onnxruntime-builds/runtime")
configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/onnxruntime-buildsConfig.cmake.in"
    "${CURRENT_PACKAGES_DIR}/share/onnxruntime-builds/onnxruntime-buildsConfig.cmake"
    @ONLY
)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/onnxruntime-builds/onnxruntime-buildsConfigVersion.cmake" [[
set(PACKAGE_VERSION "1.24.4")
if(PACKAGE_FIND_VERSION VERSION_GREATER PACKAGE_VERSION)
  set(PACKAGE_VERSION_COMPATIBLE FALSE)
else()
  set(PACKAGE_VERSION_COMPATIBLE TRUE)
  if(PACKAGE_FIND_VERSION VERSION_EQUAL PACKAGE_VERSION)
    set(PACKAGE_VERSION_EXACT TRUE)
  endif()
endif()
]])

vcpkg_install_copyright(FILE_LIST "${CMAKE_CURRENT_LIST_DIR}/LICENSE")

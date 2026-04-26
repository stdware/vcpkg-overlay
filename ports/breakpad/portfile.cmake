vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

string(REPLACE "-" "." BREAKPAD-VERSION "${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/breakpad
    REF afa2870e449ef33ad41545e7670c574cf70926a4
    SHA512 aa6f38635643af8e72b4c29905fb9cd7e9e46a4bd0047aeba13b7bb583d5599636c413ebe2990b9a7f0e0aee797562ac98cc23e4344c70244d6d461c37964171
    HEAD_REF master
)

vcpkg_replace_string("${SOURCE_PATH}/src/client/windows/crash_generation/minidump_generator.cc"
[[#if defined(_MSC_VER) && !defined(_LIBCPP_STD_VER)
            stdext::checked_array_iterator<AVRF_HANDLE_OPERATION*>(
                reinterpret_cast<AVRF_HANDLE_OPERATION*>(stream_data + 1),
                operations_.size())
#else
            reinterpret_cast<AVRF_HANDLE_OPERATION*>(stream_data + 1)
#endif]]
[[            reinterpret_cast<AVRF_HANDLE_OPERATION*>(stream_data + 1)]]
)

if(VCPKG_HOST_IS_LINUX OR VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_ANDROID)
    vcpkg_from_git(
        OUT_SOURCE_PATH LSS_SOURCE_PATH
        URL https://chromium.googlesource.com/linux-syscall-support
        REF 9719c1e1e676814c456b55f5f070eabad6709d31
    )

    file(RENAME "${LSS_SOURCE_PATH}" "${SOURCE_PATH}/src/third_party/lss")
endif()

file(COPY
        "${CMAKE_CURRENT_LIST_DIR}/check_getcontext.cc"
        "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt"
        "${CMAKE_CURRENT_LIST_DIR}/unofficial-breakpadConfig.cmake"
    DESTINATION
    "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "tools" INSTALL_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
    OPTIONS_RELEASE
        -DINSTALL_HEADERS=ON
)

vcpkg_cmake_install()
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/include/client/linux/data"
    "${CURRENT_PACKAGES_DIR}/include/client/linux/sender")

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES
            microdump_stackwalk
            minidump_dump
            minidump_stackwalk
            core2md
            pid2md
            dump_syms
            minidump-2-core
            minidump_upload
            sym_upload
            core_handler
        AUTO_CLEAN)
endif()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-breakpad)

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

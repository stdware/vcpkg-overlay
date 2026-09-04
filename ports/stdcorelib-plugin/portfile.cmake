vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/stdcorelib.plugin
    REF 9aac2e4b3b809a104ba7da51cd54d127d0b417af
    SHA512 8e9c65324341bbefd75e0251cf7a8483a226001d030d9feacede5b75d667d3f206933340e1374c4c22cf7b9d77cfa6801a29db952c5446778b8831cc1ec88a13
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSTDC_PLUGIN_BUILD_SHARED=TRUE
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT} CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
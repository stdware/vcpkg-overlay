vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/stdcorelib
    REF eb404c8e4ad92c2fc888c19cea59321a4e3d6094
    SHA512 c7767791b2244708ae644e7531555760cab3149183a68bfce2ea1a2b37b1323c7bf4d15919066a2d2ba413d435f81e5c7cb3694315fe720580c97c1d75ab8edf
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSTDC_BUILD_SHARED=TRUE
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT} CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

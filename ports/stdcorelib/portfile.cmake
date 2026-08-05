vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SineStriker/stdcorelib
    REF 1e0090a3752d4cd65b6155d62afdfa493b1cc2c7
    SHA512 d88a1b104c947f6234e3e07dec90f72b732781f6b5f8bac22f21eb0f0ad51be69a01e3e1b26c1569355d4a3b214b6b1de4e576aa644426e7f563c78fdfc06133
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSTDCORELIB_BUILD_SHARED=TRUE
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT} CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
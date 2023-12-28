vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/qBreakpad
    REF 0.0.0.0
    SHA512 177a8d33888dcb43e2e157d0ea4f5739df5be92eb769e04ca41929b29569d2f95bb995689df843145287a1ebc2e25d63620b1a9270cf178043d4505acf7d64b7
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DQBREAKPAD_BUILD_STATIC=TRUE
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME qBreakpad CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE.LGPL" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/" RENAME copyright)
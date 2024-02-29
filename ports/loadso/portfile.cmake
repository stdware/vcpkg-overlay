vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SineStriker/loadso
    REF fbaf8a65b8d887f7964c8f72651fb5368b59f21b
    SHA512 bdb580a6024b1b30a3020825ca353959e60e5118017de699c6c6e0507d87d562b3c3f8995e38a9297d98d90765c4cf9b0b660150be49afbbfbe6d49c6a5facf6
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT} CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
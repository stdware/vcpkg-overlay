vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SineStriker/loadso
    REF 7e890e0dcbceb22ec7bc5809fc9c3f55ebf78cc0
    SHA512 e8c0f688f48bbfd484306616e4660c320fe9da84f992c931516412b5db90dfb63fb8f79a3cb9493fb0520f441e27ba95b1589a9de4c1b92cfabc382f09f98086
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT} CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
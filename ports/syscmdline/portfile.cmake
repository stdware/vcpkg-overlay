vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SineStriker/syscmdline
    REF 869a7a864e3ef36b6e1f229bb1dd18f1c953f041
    SHA512 7c9327b5ee33211e2a0e1b42f6646e5d123be88815a2f99526759e2fe2856513a59401e44d9bd199accc83c7d5940619cdc6e8bac6dff5ebdfcd34d422baf568
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT} CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
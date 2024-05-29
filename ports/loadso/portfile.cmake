vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SineStriker/loadso
    REF 194477ee5a751a9c7477ea058a1f17c3523b39ce
    SHA512 007b58684dd3102d879b551b492c41d72f31a17bf73af5a716bfe4a720298e86761160c4b9d5b4ddc3c83d06b8bdcd41f9e5a220a09865ec748da257ae055742
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT} CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
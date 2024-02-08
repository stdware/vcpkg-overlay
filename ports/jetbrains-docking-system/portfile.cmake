vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/jetbrains-docking-system
    REF ef52c74f749baad4262c7698fcb191630b9f76a4
    SHA512 4178dc0486c8085711fcbb93b9e9fe128d3e0222abbdbe5a90b5accc47134741194e25de3428d87334340ca82ea9f32edcb2c38ec36f42c50d541d6ca8223809
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT} CONFIG_PATH lib/cmake/JetBrainsDockingSystem)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
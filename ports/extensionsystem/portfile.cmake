vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/ExtensionSystem
    REF acaab910d3385882c9544a242e6a1b9285f561df
    SHA512 af4ada296f4abac2f0d02f31f675d85d06fe023419d1604607a56383e872763e39b74d1275924b06b7c40bc9f9cfea67ccb8d5c390637b527c584c2ce8497ecc
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ExtensionSystem CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/" RENAME copyright)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/ExtensionSystem
    REF 65de3e4690da5577beb1e72c699407634bfe269f
    SHA512 463a4848e41aa1cae4557cd83b110e9d510dc4f87ae01d59280465bb59cb70ba08168e5aa5ce70840b5887fd4bccd38607a301e5d75e46ae45714f55cc4ba9dc
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT} CONFIG_PATH lib/cmake/ExtensionSystem)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/" RENAME copyright)
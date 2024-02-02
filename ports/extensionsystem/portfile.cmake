vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/ExtensionSystem
    REF 26f25ab12e58d326f09952a6dd4680a6ab57409f
    SHA512 51022c0d3aee53cf4cd615297bfc279a647243b95d352dc322a648b5fe6827dc58d2a8a10d687550a827a0544e97565a5ba36c9628e413c2d34a47864f3698bb
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
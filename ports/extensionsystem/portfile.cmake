vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/ExtensionSystem
    REF 4f6ec9b23bc7babddf92f57c92da67f9887afbe1
    SHA512 e796b978293712f1cc06e1aeb7959b1bbbd97c9141f2ceb0fc30c04eef7f13041a0ff139274d4f788834dbf5a6e85f36a4922d995654771c06720d8d98de4090
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
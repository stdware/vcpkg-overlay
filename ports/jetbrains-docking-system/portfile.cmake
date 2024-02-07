vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/jetbrains-docking-system
    REF cbd6080c4af5e76e77b81e071564b8fdfce63679
    SHA512 23f4f5bf822d4088fbde55a227e77b37212fa1ccc91dbcf275a51cb4b3ecf7e0700fdda53c0540a6f70942bd7f6e7ad508f5a12a8cf01b5190a3c154b0dc1c49
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
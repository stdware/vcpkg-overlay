vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/ExtensionSystem
    REF e71c82ad3cf1762a2f18ddc52c3580ec5cb075c9
    SHA512 8ac77f906a4c39c48e7f0a0d311ea54d555d12e26fc33f0db837652054bf0ad33e7ba5ac749ecd379f52ff45857ad4d7b10d098d66d3c048cdac41fd02fb3ad6
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
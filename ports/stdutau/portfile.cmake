vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO diffscope/stdutau
    REF f79b52e5ae1b8d79bc304bc439cf340f9384d604
    SHA512 6841b45da9740f2bc4bf7b66eb578f93c8b95d9e6cff1320d541932e714eee57dcf1472e89e2ec54c7f515a4e1dff2f5ae7d7c0dd99aae7250f74425f4f6fcdd
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSTDUTAU_BUILD_STATIC=FALSE
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT} CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SineStriker/stdcorelib
    REF 4e5ce9d8949936bc1dcc26193d3b13746b9216c6
    SHA512 64d548348936c5ac5f52c92c775a0c758177a4743e6ad27b2e37541449342311e7e32a7c2ecb3e114463e7dce5c061bda5ec7b48e4de9a206069296fecd2e0fd
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSTDCORELIB_BUILD_STATIC=FALSE
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT} CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
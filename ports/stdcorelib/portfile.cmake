vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SineStriker/stdcorelib
    REF 45c82427ade92b6c2cfa80a9362ab436105b87fe
    SHA512 ad6de8f28c1b3c46e283c215f7809a09fdafdbbb3f4f7a8a012a7f53ea1697a234272aa9b87839f57d04c7bede25553350efc964240b81448554525aeb0b454b
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
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/stdcorelib.plugin
    REF ff959c61f469b0e9848efbb573be78c22e276868
    SHA512 dcb831f4e3bd2feb63734d0999d713dc196bc80a03fd10a8cc76764e70b048a3343152afba4888e80935e3bea1383c4f1cff3a9b8dd210d70baf5a9549aa7525
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSTDC_PLUGIN_BUILD_SHARED=TRUE
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT} CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
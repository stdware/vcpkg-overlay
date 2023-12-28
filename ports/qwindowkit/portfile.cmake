vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/qwindowkit
    REF 5bfd136473edc506b860177bf88626e35a5a1ba4
    SHA512 d66551f2a5587992e397bcb5efc509dc54fb826a2c1a174ed8eebe489abf82088911cd81996608554b235f0277043f1b8ab47c24bed62578d3eac5f27a120253
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DQWINDOWKIT_BUILD_STATIC=ON
        -DQWINDOWKIT_BUILD_WIDGETS=ON
        -DQWINDOWKIT_BUILD_QUICK=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME QWindowKit CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/" RENAME copyright)
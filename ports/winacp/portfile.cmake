vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO QSynthesis/winacp
    REF 199258cf9ae09d946a1b2e98840d5bc9431d1924
    SHA512 857e16445dc1306b1c480a1ab84d20c9d70c0a413f69912dd2291c2cea2e24698486205e6101d45ceee0c809c2912798d8f202060d5f04f55fa06531c29e4c48
)

# The linkage follows BUILD_SHARED_LIBS, which vcpkg sets from the triplet.
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWINACP_BUILD_TESTS=OFF
        -DWINACP_BUILD_GENERATOR=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT} CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

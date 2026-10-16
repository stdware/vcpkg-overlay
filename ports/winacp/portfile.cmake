vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO QSynthesis/winacp
    REF 5c3301be6ac7cb9d402f5a9ffa9d14f885292a21
    SHA512 c26337afc7fc883708265cd07024f67a7de9f78a433176c8d4de0712cbc17f992867913370729efb99c6b98ca914a6bf0e8896fb2082275ad1d0405b7791af73
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

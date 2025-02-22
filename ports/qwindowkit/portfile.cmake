vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/qwindowkit
    REF ${VERSION}
    SHA512 91136125eb35ebfddd76f5ac6b83d82ec0abafd7a9ff02c9d58ae5216f6d5e34a1a9374cf4222e5295fe2a91093ab5fa636f5f10e9f010c2c7d568b8c0697fc5
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DQWINDOWKIT_BUILD_STATIC=OFF
        -DQWINDOWKIT_BUILD_WIDGETS=ON
        -DQWINDOWKIT_BUILD_QUICK=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT} CONFIG_PATH lib/cmake/QWindowKit)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/" RENAME copyright)
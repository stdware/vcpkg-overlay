vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SineStriker/syscmdline
    REF 07137f00d1a018d7ca004431517872ffa58b8ce5
    SHA512 d93804f7f70bf0105a96fc53ef0524f8f3bddd8d4b75dbf3cabd17fb945b2e6027053e10344a2cf857c1bbadca186f269801ce62c9c77b7241a3feb9924ffca3
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT} CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
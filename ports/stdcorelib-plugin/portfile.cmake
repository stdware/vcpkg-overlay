vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/stdcorelib.plugin
    REF 5b5a71d28e47422ecf8066a5b4f50f770d53a6e3
    SHA512 b1c6414a6141df9c24f3d494077a444748d1be86a885533a7ed875797b816e890e8d8544d8935eb68fd7bdefbbf60c38f6494120725af467768756740118ec39
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
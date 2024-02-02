vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO diffscope/stdutau
    REF 2648731413105615392a38bfbd8f60361b3d4a75
    SHA512 05650b21f3291e80bd6f0351ae16c8602527ae2b6d1b8b94f862e7322be5bd1431c04182e0c483371fafb542dcd444561c6a6927131ca8d7d28fb5c0fe463c4f
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
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO VocaValley/stdutau
    REF 3831faab2966de3042fef10e3570598f4512de89
    SHA512 820f058cd10d6055711a2ca75abcdfd6a6b78862bcd309d9f14b05b2336b7b39190d5220354050a220446873e5c7a189312affe8512879590902e01deabe5152
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
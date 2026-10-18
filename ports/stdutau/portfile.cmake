vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO diffscope/stdutau
    REF 073f4748cf2ef75f79885d9237f20c748b66e6d7
    SHA512 253b25e53b6b885d01097dfbe30468cd5167845e174d18777bae06911e07927cf84df94a21de9da549363ca8e7a7abadf69330e5feca1d4a27ec77637ab55ca5
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
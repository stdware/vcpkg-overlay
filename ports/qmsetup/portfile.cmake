vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/qmsetup
    REF 74d2fdb0ad04510ff1dcbd28260e1873dd400d1b
    SHA512 49da43aecda8651d8562cf5bb1e1a6101e16df2d71f7348e752730f2e6f0bbde8e3ea508c1511aaf4fcd75b50cbb8bcbc86a9aa819d0c9077786e18bced2a36a
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DQMSETUP_VCPKG_TOOLS_HINT=ON
        -DQMSETUP_STATIC_RUNTIME=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT}
    CONFIG_PATH lib/cmake/${PORT}
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug")
file(COPY "${CURRENT_PACKAGES_DIR}/tools" DESTINATION "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/" RENAME copyright)
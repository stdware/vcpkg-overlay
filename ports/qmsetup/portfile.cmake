vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/qmsetup
    REF e7063a32cddae1d173d97e379df4a5baaec9f034
    SHA512 996f0ce531eec7a65167b0fd8d2271e63a0e8b17c65482c3a7acdbdd1ea09ac9ef4360e9d7f33e05a3180d33c1eec57993ac020acbbd3eea016362f224432fef
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
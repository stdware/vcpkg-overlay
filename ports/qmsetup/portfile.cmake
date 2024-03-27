vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/qmsetup
    REF 4bdc73271a9e3b6d8cc0a0affda18ff008c901d2
    SHA512 627bfa8b66a311e6ae4ed9d03c2ce67885495bc9ada7015d7a8cf14bfe4a524ebaf575bfbea51d14f245a6d6b897502ba8a3249d69db76a741b8537dbc4e6026
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
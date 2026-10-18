# substate builds two libraries: substate, and qsubstate on Qt 6 Core. Qt is not a vcpkg package
# here, so the Qt installation that the environment points at is found, as for qactionkit.

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/substate
    REF 161f6fc252e526bc730971d1f8db6d160363bde5
    SHA512 7b7dec6b3f51cf18f19c8dfe34152af0c9fcdd0cbd58115a00ad709852fc5327a919dc7dc49309d3b2e1d957e7ebb53b50cbef89639213893774f940343cc517
)

# The triplet decides the linkage, rather than leaving the project's own default to decide it.
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SUBSTATE_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SUBSTATE_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSUBSTATE_BUILD_STATIC=${SUBSTATE_BUILD_STATIC}
        -DSUBSTATE_BUILD_SHARED=${SUBSTATE_BUILD_SHARED}
        -DSUBSTATE_BUILD_TESTS=OFF
        -DSUBSTATE_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT} CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

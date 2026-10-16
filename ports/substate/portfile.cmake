# substate builds two libraries: substate, and qsubstate on Qt 6 Core. Qt is not a vcpkg package
# here, so the Qt installation that the environment points at is found, as for qactionkit.

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/substate
    REF 6dd5f8e52f5ae033d820cc239dd900c269f379aa
    SHA512 c81c5a9052abe489f6b7b05a2d40264454883fc8997194e567fd1d9e28ae6621ec8cab99b58672dca11b29d0bf84bc054cb60874f936c30a5af190e36274a582
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

# substate builds two libraries: substate, and qsubstate on Qt 6 Core. Qt is not a vcpkg package
# here, so the Qt installation that the environment points at is found, as for qactionkit.

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/substate
    REF b3a20855ff04121b9f53eb2d9adda1ad1ae53611
    SHA512 184f2b04ebd3058a19ca086a23179040179a448ac4ac51b7dac97ad54d0680b8857fa01763a9e5d6bf39f60d43b4a37b2ee3e1054755d19973b11d93f6eab996
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

# qmsetup is a set of CMake modules and one tool, qmcorecmd, that the modules shell out to.
# There is no library to link, so nothing here needs a debug build.
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/qmsetup
    REF 5b83fa78c0ae7d86055ea0a1a057247b8dabb036
    SHA512 0764a3018428890fd2745d86728937bf3638b4b7d78416f935bc3c9cb960215942a8cb3b0e9bc1f946f3c754b5e76f3039c1b6fd8266df07119354add2e5ce72
)

# The triplet decides how the runtime is linked, so qmsetup is told what the triplet said rather
# than being left to choose for itself.
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" QMSETUP_STATIC_RUNTIME)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DQMSETUP_STATIC_RUNTIME=${QMSETUP_STATIC_RUNTIME}
)

vcpkg_cmake_install()

# qmcorecmd goes where every vcpkg tool goes, and what it loads goes with it. That second half is
# the point: a dynamic stdcorelib leaves the tool installed beside nothing it can load, and
# running it is the first thing a CMake module does.
vcpkg_copy_tools(TOOL_NAMES qmcorecmd AUTO_CLEAN)

vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT}
    CONFIG_PATH lib/cmake/${PORT}
)

# The configuration and the modules beside it have gone to share, and the headers are carried by
# an interface target, so nothing is left under lib.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Points the ports that depend on qmsetup at this installation, see the file itself.
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

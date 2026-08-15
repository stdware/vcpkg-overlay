# qmsetup is a set of CMake modules and one tool, qmcorecmd, that the modules shell out to.
# There is no library to link, so nothing here needs a debug build.
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/qmsetup
    REF 5b78a8cc6b59b0081921bfb9400791c8a4382881
    SHA512 3dc76601030c75224924904b4ea942c591177e3706f6d1f1d195b21ba0194e7324f14ed24fbd780f7c2be3bf7bc8f1fded8b482b1c8c3348443655bc6c1219af
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

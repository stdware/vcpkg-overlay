# qmsetup is a set of CMake modules and one tool, qmcorecmd, that the modules shell out to.
# There is no library to link, so nothing here needs a debug build.
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/qmsetup
    REF 0bd29c49804e450657cb3b5b2a1c1704bca3f5ec
    SHA512 f58a1757c3ea11177c75443c92972a1e7e6eaddaa2e0e99f773515c60b1329730111948a68629f51aa005dce2c4a26a662a0863f66aace34d1ece667df393988
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

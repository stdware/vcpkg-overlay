# QActionKit builds one tool, qak_aec, that compiles action manifests into C++ at build time.
# QActionKitMacros.cmake resolves it through the imported target QActionKit::qak_aec, so where the
# tool is installed has to agree with what the exported config says. vcpkg_copy_tools moves it
# under tools/ and vcpkg_cmake_config_fixup rewrites the exported path to follow, which is why the
# copy has to come first.

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/qactionkit
    REF ba3c2767b96d2a4999f0cf018ff5034bc9515e83
    SHA512 1d1086c219ba0bdc0fdd7b603a74fb1700f2acb89cdac3054004950d78cd5bddc270d3943711a58ec3d07005102584a4d833246a3b4e52fc0382dc3e3608707b
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        widgets QACTIONKIT_BUILD_WIDGETS
        quick QACTIONKIT_BUILD_QUICK
)

# The triplet decides the linkage, rather than leaving the project's own default to decide it.
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" QACTIONKIT_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DQACTIONKIT_BUILD_STATIC=${QACTIONKIT_BUILD_STATIC}
        -DQACTIONKIT_BUILD_EXAMPLES=OFF
        -DQACTIONKIT_BUILD_TESTS=OFF
        -DQACTIONKIT_BUILD_DOCUMENTATIONS=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

# This carries the libraries the tool loads along with it. Qt is not one of them: it is not a
# vcpkg package here, so applocal cannot see it and leaves its libraries where they are.
# QActionKitMacros.cmake gives the dynamic loader the directory of Qt Core when it runs the tool.
# An rpath to Qt added here does not survive, because vcpkg replaces the run paths of the tool
# after this script with one to its own library directory.
vcpkg_copy_tools(TOOL_NAMES qak_aec AUTO_CLEAN)

vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT}
    CONFIG_PATH lib/cmake/QActionKit
)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

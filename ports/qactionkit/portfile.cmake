# QActionKit builds one tool, qak_aec, that compiles action manifests into C++ at build time.
# QActionKitMacros.cmake resolves it through the imported target QActionKit::qak_aec, so where the
# tool is installed has to agree with what the exported config says. vcpkg_copy_tools moves it
# under tools/ and vcpkg_cmake_config_fixup rewrites the exported path to follow, which is why the
# copy has to come first.

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/qactionkit
    REF d80b87f00d4f31ea0600d631b1bac6cdddc307ed
    SHA512 b2daa6761cf5af2eabff229512931dc6fd781f0e43ac3405bf0fc1c8b7c1f220afd88c57bfa5829b24d01d770177962ba9230e3b6ae812951551a2cbbde1d3d6
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

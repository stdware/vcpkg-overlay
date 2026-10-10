# QActionKit builds one tool, qak_aec, that compiles action manifests into C++ at build time.
# QActionKitMacros.cmake resolves it through the imported target QActionKit::qak_aec, so where the
# tool is installed has to agree with what the exported config says. vcpkg_copy_tools moves it
# under tools/ and vcpkg_cmake_config_fixup rewrites the exported path to follow, which is why the
# copy has to come first.

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/qactionkit
    REF fa7ffba53346319f9f8d8d6cbb2f678b0805f7a1
    SHA512 720360d2e70bf315b80601fd2ebd01f7c8566ec64565a633d0d0f1bddc4e755b9cd46b6718128d0e830e9c5cfa25b4a116d191a1685b9f998320350f22c14399
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
# vcpkg package here, so applocal cannot see it and leaves its libraries where they are. The tool
# finds them the way qasc does, from the Qt installation the environment already points at.
vcpkg_copy_tools(TOOL_NAMES qak_aec AUTO_CLEAN)

vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT}
    CONFIG_PATH lib/cmake/QActionKit
)

# A tool linked against a Qt outside the install tree carries no rpath to it, and macOS has no
# search path to fall back on. Same fix as qastool.
if(VCPKG_TARGET_IS_OSX AND DEFINED ENV{QT_DIR})
    get_filename_component(qt_lib_dir "$ENV{QT_DIR}/../.." REALPATH)
    execute_process(COMMAND install_name_tool -add_rpath "${qt_lib_dir}"
                            "${CURRENT_PACKAGES_DIR}/tools/${PORT}/qak_aec")
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

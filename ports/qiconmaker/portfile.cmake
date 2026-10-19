# qiconmaker writes .ico and .icns files from SVG and PNG drawings. The port installs the static
# library QIconMaker and the tool qiconmaker, which a project runs at build time. Qt is not a
# vcpkg package here, and the configuration finds it through QT_DIR, as for qactionkit.

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/qiconmaker
    REF 296ef489f35c9b501c4b63c8943ed0da558a8703
    SHA512 0677e89e37f86a0658c1b7d585d163369de6ec51fad5c1f12be6bc4941124a79c3900612a2d38d4b03cfd1724391282ed3ba7ed641874f0c243d0a975ca85865
)

# The installed tool keeps the run paths of the build to the libraries outside the project, the
# library directory of Qt, so that it runs without an environment of its own. vcpkg replaces the
# run paths of the tools after this script with one to its own library directory, which holds no
# Qt, so the replacement is turned off. The tool loads no library of a port.
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DQICONMAKER_BUILD_TESTS=OFF
        -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON
)
set(VCPKG_FIXUP_MACHO_RPATH OFF)
set(VCPKG_FIXUP_ELF_RPATH OFF)

vcpkg_cmake_install()

# The tool goes under tools before the configuration is fixed up, so that the exported path of
# the imported target qiconmaker::qiconmaker follows it.
vcpkg_copy_tools(TOOL_NAMES qiconmaker AUTO_CLEAN)

vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT}
    CONFIG_PATH lib/cmake/${PORT}
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# qmsetup is a set of CMake modules and one tool, qmcorecmd, that the modules shell out to.
# There is no library to link, so nothing here needs a debug build.
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/qmsetup
    REF d6cde8a8db1f355eb805589fee307e2d18801455
    SHA512 6df14eaa33a8311f79fc517188c8c55e3a4c9d133d197c218e5638ae9d59c0bc8fbe8daaea9252e245ea6c056268467377b2bfc13741b4bde374f4c3ba8428e6
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

# qmcorecmd goes where every vcpkg tool goes, and the libraries that it loads go with it, because
# running it is the first thing a CMake module does. On Windows vcpkg_copy_tools() copies the
# DLLs beside the tool.
vcpkg_copy_tools(TOOL_NAMES qmcorecmd AUTO_CLEAN)

# On macOS the libraries of the ports are copied beside the tool as well, and referenced through
# @loader_path rather than through the rpath to lib. The files in installed are hard links to
# those in packages, and dyld may expand @loader_path through the link in packages, which holds
# no lib directory. A library beside the tool is found through either link.
if(VCPKG_TARGET_IS_OSX)
    set(_tool "${CURRENT_PACKAGES_DIR}/tools/${PORT}/qmcorecmd")
    execute_process(COMMAND otool -L "${_tool}" OUTPUT_VARIABLE _libraries
        COMMAND_ERROR_IS_FATAL ANY)
    string(REGEX MATCHALL "@rpath/[^ \t\n]+" _libraries "${_libraries}")
    foreach(_library IN LISTS _libraries)
        string(REPLACE "@rpath/" "" _name "${_library}")
        file(REAL_PATH "${CURRENT_INSTALLED_DIR}/lib/${_name}" _file)
        file(COPY_FILE "${_file}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${_name}")
        execute_process(
            COMMAND install_name_tool -change "${_library}" "@loader_path/${_name}" "${_tool}"
            COMMAND_ERROR_IS_FATAL ANY)
    endforeach()
endif()

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

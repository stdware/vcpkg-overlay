vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO diffscope/opendspx
    REF 4464c0782bd6d57ae5b73104b299d9c1815b6bde
    SHA512 f309809bb20a2896f8a1310a2a8a5ddab78a481363c93ebcd6d9e6f01a4817c8ab89fbabc3118a0e80b3e7b4913ffe2cf14281c2a86dc793604e7549d3bdd482
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/share")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/share/${PORT}")

vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT} CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
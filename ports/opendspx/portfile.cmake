vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO diffscope/opendspx
        REF b3f22c8a128df5524d820bee63d77295b943e4cc
        SHA512 0028a1f8b125751c928ae183d154b95921d73796c3a8922c1bd3fb6f2e1688627963e85e9a15ac936bec6c32d0d1daf62691ae1d143bdfa5f337b93a43bd814a
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
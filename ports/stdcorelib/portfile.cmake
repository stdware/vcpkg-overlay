vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/stdcorelib
    REF 4a185d72137988fbf7e3cc91b3ab0f542eb6194b
    SHA512 c0992c05c7546228fba70b7e430532d407fc277e61daf1ebda6988db9cab4b7de8c7da0414a42ff4392906f20113dfa50d66db52ab8e8d60922eccacdea3d175
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSTDC_BUILD_SHARED=TRUE
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT} CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
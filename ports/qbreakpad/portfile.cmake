vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/qBreakpad
    REF d3c84d46eed2913299ca368d714e2a98e1d6e695
    SHA512 6bc7dbc3563b006aa815fbcb8984a31040ec0f28b4ca87e15c88a75c71daef4d827fafc257c5a198d3ff25dcce6ec2b35b4d25e070765d2925b9ff4f693285fe
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DQBREAKPAD_BUILD_SHARED=TRUE
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT} CONFIG_PATH lib/cmake/qBreakpad)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE.LGPL" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/" RENAME copyright)
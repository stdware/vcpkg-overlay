vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SineStriker/stdcorelib
    REF 04710e8d7a025b5dfd44530543c4691f36482018
    SHA512 5f5d7cdf13f0433fe662d8ecd76e95a4ee98784f04d01ebadc561dd225e7b39a5900fcc57dd9b6f2798a294435baede3e731777fdbc96657fb1688713c862c36
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSTDCORELIB_BUILD_STATIC=FALSE
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT} CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
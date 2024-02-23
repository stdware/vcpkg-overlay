vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdware/qwindowkit
    REF fa380df5aa3a9c302760be3903eeebb6d866d8ee
    SHA512 c7db856400cec4cce84866f590cbfc9416fd28cee0f7c56f61d98b8fe2ac52877131dcaa583c4de583d4e22c91b88909833298c1cff12661539115da48b7223d
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DQWINDOWKIT_BUILD_STATIC=OFF
        -DQWINDOWKIT_BUILD_WIDGETS=ON
        -DQWINDOWKIT_BUILD_QUICK=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT} CONFIG_PATH lib/cmake/QWindowKit)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/" RENAME copyright)
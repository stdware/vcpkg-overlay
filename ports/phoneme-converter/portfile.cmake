vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO diffscope/phoneme-converter
        REF 7aaa6f91ffe0eb6a01375afdfe533042ae9181b8
        SHA512 4f68e221424f517a414d391d7f7bc0072a3110334b0a3ab6bea7ec65d4042181a1f5643547eabd972787a0802a024154e61cbd731ed04256efba3cfe4486e7aa
        HEAD_REF main
)

vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/share")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/share/${PORT}")

vcpkg_cmake_config_fixup(PACKAGE_NAME PhonemeConverter CONFIG_PATH lib/cmake/PhonemeConverter)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

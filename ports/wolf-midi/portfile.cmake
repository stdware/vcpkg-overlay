vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfgitpr/wolf-midi
    REF 2097d1d9f356325a487a373741124feb9cd292ba
    SHA512 1a645b4ed448d2734ed4a8bbd3c026f07ef00784b73473261ac816622187d0a913aeb63434c425ff52055f44408cee1384e326c598250b068ab35a52280a4e25
    HEAD_REF main
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" WOLF_MIDI_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWOLF_MIDI_BUILD_STATIC=${WOLF_MIDI_BUILD_STATIC}
        -DWOLF_MIDI_BUILD_TESTS=FALSE
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)

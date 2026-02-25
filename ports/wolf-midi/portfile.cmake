vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfgitpr/wolf-midi
    REF faea017946a16bc63780f5ba1e0af369d7388ca5
    SHA512 4ea5b4d04d5d4fdf9b3175b150e4376c18347a371783f3cb7debcecb7eb71010c2a8f804aa30452d04aaab3822b9867126dfe89eecdf989cd1d81d398f2b2631
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

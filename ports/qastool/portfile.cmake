vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SineStriker/qt-json-autogen
    REF 9306c9442693ceb395f1b3830d04552ade3dbb06
    SHA512 0fcd537891627a1b60d69a5d97c1f69297a011dad5014b0f8c2a6a9dfea9347c5a33e68be2caf3187e667d336e1a82896b72d6675b877073014d535f71593136
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DQAS_BUILD_EXAMPLES=OFF
        -DQAS_BUILD_MOC_EXE=OFF
        -DQAS_VCPKG_TOOLS_HINT=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT}
    CONFIG_PATH lib/cmake/${PORT}
)

if(APPLE)
    get_filename_component(qt_lib_dir "$ENV{QT_DIR}/../.." REALPATH)
    execute_process(COMMAND install_name_tool -add_rpath "${qt_lib_dir}" "${CURRENT_PACKAGES_DIR}/tools/qastool/qasc")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug")
file(COPY "${CURRENT_PACKAGES_DIR}/tools" DESTINATION "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/" RENAME copyright)
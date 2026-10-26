vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jackaudio/jack2
    REF "v${VERSION}"
    SHA512 d93cb2bcc57b72b6815eed143de1092d14fe22542ae9a1f8480d9ed5f44b59c50f81279d18bdd84ff6276ddd71ca1aa64a1e46d61199a5eda0d873a356194ab4
)

vcpkg_replace_string("${SOURCE_PATH}/waflib/Context.py" "import os, re, imp, sys" "import os, re, sys, types")
vcpkg_replace_string("${SOURCE_PATH}/waflib/Context.py" "imp.new_module(WSCRIPT_FILE)" "types.ModuleType(WSCRIPT_FILE)")

vcpkg_find_acquire_program(PYTHON3)
vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")

foreach(configuration IN ITEMS RELEASE DEBUG)
    string(TOLOWER "${configuration}" build_type)
    if(VCPKG_BUILD_TYPE AND NOT VCPKG_BUILD_TYPE STREQUAL build_type)
        continue()
    endif()
    set(suffix)
    set(debug_option)
    if(configuration STREQUAL "DEBUG")
        set(suffix /debug)
        set(debug_option --debug)
    endif()
    set(build_dir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${build_type}")
    set(prefix "${CURRENT_PACKAGES_DIR}${suffix}")
    set(build_environment
        "CC=${VCPKG_DETECTED_CMAKE_C_COMPILER}"
        "CXX=${VCPKG_DETECTED_CMAKE_CXX_COMPILER}"
        "CFLAGS=${VCPKG_COMBINED_C_FLAGS_${configuration}}"
        "CXXFLAGS=${VCPKG_COMBINED_CXX_FLAGS_${configuration}}"
        "LINKFLAGS=${VCPKG_COMBINED_SHARED_LINKER_FLAGS_${configuration}}"
    )
    vcpkg_execute_required_process(
        COMMAND "${CMAKE_COMMAND}" -E env ${build_environment}
            "${PYTHON3}" "${SOURCE_PATH}/waf" configure
            "--out=${build_dir}" "--prefix=${prefix}" "--libdir=${prefix}/lib"
            --autostart=none --alsa=no --firewire=no --iio=no --portaudio=no --winmme=no
            --celt=no --opus=no --samplerate=no --systemd=no --db=no --tests=no
            ${debug_option}
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME "configure-${TARGET_TRIPLET}-${build_type}"
    )
    vcpkg_execute_required_process(
        COMMAND "${CMAKE_COMMAND}" -E env ${build_environment}
            "${PYTHON3}" "${SOURCE_PATH}/waf" build "--out=${build_dir}" --targets=clientlib "-j${VCPKG_CONCURRENCY}"
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME "build-${TARGET_TRIPLET}-${build_type}"
    )
    # Install only the client library. The server and hardware drivers belong to the target system.
    get_filename_component(client_library "${build_dir}/common/libjack.so" REALPATH)
    file(INSTALL "${client_library}" DESTINATION "${prefix}/lib" RENAME libjack.so.0.1.0)
    file(CREATE_LINK libjack.so.0.1.0 "${prefix}/lib/libjack.so.0" SYMBOLIC)
    file(CREATE_LINK libjack.so.0 "${prefix}/lib/libjack.so" SYMBOLIC)
    file(WRITE "${prefix}/lib/pkgconfig/jack.pc"
        "prefix=${prefix}\nlibdir=\${prefix}/lib\nincludedir=\${prefix}/include\n\nName: jack\nDescription: JACK client library\nVersion: ${VERSION}\nLibs: -L\${libdir} -ljack\nCflags: -I\${includedir}\n"
    )
endforeach()

file(INSTALL "${SOURCE_PATH}/common/jack" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
vcpkg_fixup_pkgconfig()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING" "${SOURCE_PATH}/common/jack/jack.h")

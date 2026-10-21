# Copies the PDB of each DLL of a MinGW package from the release build tree beside the DLL in the
# package, as vcpkg_copy_pdbs does for the MSVC ABI only. lld names the PDB after the binary, as
# libzip.pdb for libzip.dll. A DLL without exactly one such PDB is left without one. Included
# after each portfile by x64-mingw-dynamic through VCPKG_POST_PORTFILE_INCLUDES.
if(VCPKG_TARGET_IS_MINGW AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(GLOB z_mingw_dlls "${CURRENT_PACKAGES_DIR}/bin/*.dll")
    foreach(z_mingw_dll IN LISTS z_mingw_dlls)
        get_filename_component(z_mingw_name "${z_mingw_dll}" NAME_WE)
        file(GLOB_RECURSE z_mingw_pdbs
            "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${z_mingw_name}.pdb"
        )
        list(LENGTH z_mingw_pdbs z_mingw_count)
        if(z_mingw_count EQUAL 1)
            file(COPY ${z_mingw_pdbs} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        endif()
    endforeach()
    unset(z_mingw_dlls)
    unset(z_mingw_dll)
    unset(z_mingw_name)
    unset(z_mingw_pdbs)
    unset(z_mingw_count)
endif()

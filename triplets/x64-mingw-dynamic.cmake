set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)
set(VCPKG_ENV_PASSTHROUGH_UNTRACKED PATH)

set(VCPKG_CMAKE_SYSTEM_NAME MinGW)
set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled)

# The community triplet of vcpkg with debug information in a PDB beside each binary, for the
# debuggers and the tools for crash dumps of Windows, which read PDBs rather than DWARF. clang of
# llvm-mingw writes CodeView for -gcodeview, and lld writes the PDB for an empty --pdb=. GCC
# accepts neither option. The flag rather than the build type RelWithDebInfo carries the debug
# information, as in x64-linux.
set(VCPKG_C_FLAGS_RELEASE "-g -gcodeview")
set(VCPKG_CXX_FLAGS_RELEASE "-g -gcodeview")
set(VCPKG_LINKER_FLAGS_RELEASE "-Wl,--pdb=")

# vcpkg_copy_pdbs skips MinGW, so that the PDBs remain in the build trees.
set(VCPKG_POST_PORTFILE_INCLUDES "${CMAKE_CURRENT_LIST_DIR}/../scripts/cmake/mingw-copy-pdbs.cmake")

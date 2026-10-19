set(VCPKG_TARGET_ARCHITECTURE arm64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)

set(VCPKG_CMAKE_SYSTEM_NAME Darwin)
# The oldest macOS that the applications built on the ports support, that of Qt 6.11.
# Without it, the ports are built for the macOS of the SDK, and a library of a port then
# fails to load on an older macOS on which the application itself starts.
set(VCPKG_OSX_DEPLOYMENT_TARGET 13.0)
set(VCPKG_OSX_ARCHITECTURES arm64)

# Debug info comes from a flag rather than from building the ports as RelWithDebInfo. The build
# type is not free to change: vcpkg_cmake_config_fixup only rewrites the tool paths it finds in
# *-release.cmake, and the imported targets ports export are looked up as Release.
set(VCPKG_C_FLAGS_RELEASE "-g")
set(VCPKG_CXX_FLAGS_RELEASE "-g")
# vcpkg includes this file in the portfile of every port that depends on qmsetup, as a host
# dependency or not. A port takes qmsetup as a host dependency, because its modules run
# qmcorecmd at build time, and the toolchain of vcpkg finds the packages of the target triplet
# only. The two triplets are the same unless the build is cross-compiled, such as for
# x64-mingw-dynamic on x64-windows, so the configuration of the port is given this installation.
list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS "-Dqmsetup_DIR=${CMAKE_CURRENT_LIST_DIR}")

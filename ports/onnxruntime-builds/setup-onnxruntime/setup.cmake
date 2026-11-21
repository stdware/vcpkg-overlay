# ONNX Runtime payloads are fetched from NuGet. The upstream GitHub release
# assets are not served anymore, while every NuGet package carries the same
# headers and native binaries, keyed by runtime identifier (RID).
#
# CPU payload:  Microsoft.ML.OnnxRuntime               (all RIDs, one package)
# DML payload:  Microsoft.ML.OnnxRuntime.DirectML      (win-x64)
# CUDA payload: Microsoft.ML.OnnxRuntime.Gpu.Windows   (win-x64)
#               Microsoft.ML.OnnxRuntime.Gpu.Linux     (linux-x64)
#
# The cross-platform Microsoft.ML.OnnxRuntime.Gpu package is only a
# metapackage forwarding to the per-OS ones, so it is never downloaded.

include("${CMAKE_CURRENT_LIST_DIR}/versions.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/hashes.cmake")

# Map the vcpkg triplet onto the RID that keys the NuGet runtime directory.
function(_onnxruntime_nuget_rid out_var)
    if(VCPKG_TARGET_IS_WINDOWS)
        set(_rid_os "win")
    elseif(VCPKG_TARGET_IS_LINUX)
        set(_rid_os "linux")
    elseif(VCPKG_TARGET_IS_OSX)
        set(_rid_os "osx")
    else()
        message(FATAL_ERROR "Unsupported operating system: ${VCPKG_TARGET_TRIPLET}")
    endif()

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(_rid_arch "x64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(_rid_arch "x86")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(_rid_arch "arm64")
    else()
        message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
    endif()

    set(${out_var} "${_rid_os}-${_rid_arch}" PARENT_SCOPE)
endfunction()

# Deploy one native payload directory, whitelist-split by filename pattern
# into three physically separated destination trees (layout decision D7,
# docs/audit-report-onnxruntime-builds.md):
#   *.{dll,dylib,so,so.*}  runtime binaries → <runtime_dst> (pure-DLL tree;
#                          consumers glob it for deployment, symbols can
#                          never leak into shipped packages)
#   *.pdb / *.dSYM         debug symbols → <pdb_dst> (parallel tree, same
#                          flavor structure; consumers copy them on demand
#                          for Debug/RelWithDebInfo staging)
#   *.lib                  import libraries → <import_dst> (per-flavor
#                          private; kills the DML/GPU onnxruntime.lib
#                          overwrite; nothing links them today, kept as
#                          stock)
#   everything else        NOT deployed: upstream lib/cmake configs and
#                          pkgconfig embed dead upstream paths — junk in the
#                          vcpkg layout (and would cross-flavor overwrite too)
function(_deploy_runtime_contents _src _runtime_dst _pdb_dst _import_dst)
    file(GLOB SOURCE_FILES "${_src}/*")
    file(MAKE_DIRECTORY "${_runtime_dst}")
    foreach(FILE IN LISTS SOURCE_FILES)
        get_filename_component(_file_name "${FILE}" NAME)
        if(_file_name MATCHES "\\.dll$|\\.dylib$|\\.so(\\..*)?$")
            file(COPY "${FILE}" DESTINATION "${_runtime_dst}")
        elseif(_file_name MATCHES "\\.pdb$|\\.dSYM$")
            file(MAKE_DIRECTORY "${_pdb_dst}")
            file(COPY "${FILE}" DESTINATION "${_pdb_dst}")
        elseif(_file_name MATCHES "\\.lib$")
            file(MAKE_DIRECTORY "${_import_dst}")
            file(COPY "${FILE}" DESTINATION "${_import_dst}")
        endif()
    endforeach()
endfunction()

# Download one ONNX Runtime NuGet payload: headers land in the shared include
# directory, native binaries go through _deploy_runtime_contents. The file is
# stored with a .zip suffix because a NuGet package is a zip archive and
# vcpkg_extract_archive selects the extractor by file name.
function(_download_onnxruntime_nuget _package_id _version _rid
         _deploy_dst_dir _runtime_dst_dir _pdb_dst_dir _import_dst_dir)
    set(_url "https://www.nuget.org/api/v2/package/${_package_id}/${_version}")
    set(_download_filename "${_package_id}.${_version}.zip")

    message(STATUS "Downloading ${_package_id} ${_version} (${_rid}) from ${_url}")

    lookup_onnxruntime_package_sha512("${_download_filename}" _file_hash)
    vcpkg_download_distfile(
            _downloaded_file_path
            URLS "${_url}"
            FILENAME "${_download_filename}"
            SHA512 "${_file_hash}"
    )

    set(_extract_dir "${CURRENT_BUILDTREES_DIR}/tmp_onnxruntime")

    file(REMOVE_RECURSE "${_extract_dir}")

    vcpkg_extract_archive(
            ARCHIVE "${_downloaded_file_path}"
            DESTINATION "${_extract_dir}"
    )

    set(_native_dir "${_extract_dir}/runtimes/${_rid}/native")
    if(NOT EXISTS "${_native_dir}")
        message(FATAL_ERROR
            "${_package_id} ${_version} ships no native payload for ${_rid} "
            "(triplet: ${VCPKG_TARGET_TRIPLET})")
    endif()

    # Headers are published under build/native/include for the CPU and DirectML
    # packages and under buildTransitive/native/include for the per-OS CUDA
    # packages. A CUDA payload is layered on top of the default one, which has
    # already deployed the same headers, so a missing header tree is allowed.
    set(_include_dir "")
    foreach(_candidate IN ITEMS "build/native/include" "buildTransitive/native/include")
        file(GLOB _candidate_headers "${_extract_dir}/${_candidate}/*.h")
        if(_candidate_headers AND _include_dir STREQUAL "")
            set(_include_dir "${_extract_dir}/${_candidate}")
        endif()
    endforeach()
    if(NOT _include_dir STREQUAL "")
        file(COPY "${_include_dir}" DESTINATION "${_deploy_dst_dir}")
    endif()

    _deploy_runtime_contents("${_native_dir}" "${_runtime_dst_dir}" "${_pdb_dst_dir}" "${_import_dst_dir}")

    file(REMOVE_RECURSE "${_extract_dir}")
endfunction()

# Windows default flavor: DirectML build of ONNX Runtime.
function(download_onnxruntime_dml_from_nuget _deploy_dst_dir _runtime_dst_dir _pdb_dst_dir _import_dst_dir)
    _download_onnxruntime_nuget("Microsoft.ML.OnnxRuntime.DirectML" "${_version_ort_dml}" "win-x64"
            "${_deploy_dst_dir}" "${_runtime_dst_dir}" "${_pdb_dst_dir}" "${_import_dst_dir}")
endfunction()

# CPU build of ONNX Runtime, used by every non-Windows triplet.
function(download_onnxruntime_cpu_from_nuget _deploy_dst_dir _runtime_dst_dir _pdb_dst_dir _import_dst_dir)
    _onnxruntime_nuget_rid(_rid)
    _download_onnxruntime_nuget("Microsoft.ML.OnnxRuntime" "${_version_ort}" "${_rid}"
            "${_deploy_dst_dir}" "${_runtime_dst_dir}" "${_pdb_dst_dir}" "${_import_dst_dir}")
endfunction()

# CUDA 12 build of ONNX Runtime (cuda12 feature). There is no macOS payload.
function(download_onnxruntime_cuda_from_nuget _deploy_dst_dir _runtime_dst_dir _pdb_dst_dir _import_dst_dir)
    if(VCPKG_TARGET_IS_WINDOWS)
        set(_package_id "Microsoft.ML.OnnxRuntime.Gpu.Windows")
    elseif(VCPKG_TARGET_IS_LINUX)
        set(_package_id "Microsoft.ML.OnnxRuntime.Gpu.Linux")
    else()
        message(FATAL_ERROR
            "onnxruntime-builds: the cuda12 payload is unavailable on ${VCPKG_TARGET_TRIPLET}")
    endif()
    _onnxruntime_nuget_rid(_rid)
    _download_onnxruntime_nuget("${_package_id}" "${_version_ort}" "${_rid}"
            "${_deploy_dst_dir}" "${_runtime_dst_dir}" "${_pdb_dst_dir}" "${_import_dst_dir}")
endfunction()

function(download_dml_from_nuget _deploy_dst_dir _runtime_dst_dir _pdb_dst_dir _import_dst_dir)
    set(_url "https://www.nuget.org/api/v2/package/Microsoft.AI.DirectML/${_version_dml}")
    set(_download_filename "Microsoft.AI.DirectML.${_version_dml}.zip")

    message(STATUS "Downloading DirectML from ${_url}")

    lookup_onnxruntime_package_sha512("${_download_filename}" _file_hash)
    vcpkg_download_distfile(
            _downloaded_file_path_dml
            URLS "${_url}"
            FILENAME "${_download_filename}"
            SHA512 "${_file_hash}"
    )

    set(_extract_dir "${CURRENT_BUILDTREES_DIR}/tmp_directml")

    file(REMOVE_RECURSE "${_extract_dir}")

    vcpkg_extract_archive(
        ARCHIVE "${_downloaded_file_path_dml}"
        DESTINATION "${_extract_dir}"
    )

    file(COPY "${_extract_dir}/include" DESTINATION "${_deploy_dst_dir}")

    _deploy_runtime_contents("${_extract_dir}/bin/x64-win" "${_runtime_dst_dir}" "${_pdb_dst_dir}" "${_import_dst_dir}")

    file(REMOVE_RECURSE "${_extract_dir}")
endfunction()

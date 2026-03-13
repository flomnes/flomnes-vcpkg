vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/or-tools
    REF "v${VERSION}"
    SHA512 9e0f0c19c9e34c1a59562d602aeaf0eb22719bdb11054bc92504b4ac3e3f71bb1e5ccd7ef86d8f973f2d32c1827326448cedab3b7fd68515512a938686786d52
    HEAD_REF stable
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        coinor USE_COINOR
        glpk USE_GLPK
        highs USE_HIGHS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_DEPS=OFF
        -DBUILD_SAMPLES=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_PYTHON=OFF
        -DBUILD_JAVA=OFF
        -DBUILD_DOTNET=OFF
        -DUSE_GUROBI=OFF
        -DUSE_XPRESS=OFF
        -DUSE_SCIP=OFF
        -DOR_TOOLS_PROTOC_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/protobuf/protoc${VCPKG_HOST_EXECUTABLE_SUFFIX}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/ortools")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Upstream installs many language/docs/sample directory placeholders under include.
# Prune any empty include directories to satisfy vcpkg post-build checks.
set(_removed_empty_dir TRUE)
while(_removed_empty_dir)
    set(_removed_empty_dir FALSE)
    file(GLOB_RECURSE _include_dirs LIST_DIRECTORIES true "${CURRENT_PACKAGES_DIR}/include/*")
    foreach(_dir IN LISTS _include_dirs)
        if(IS_DIRECTORY "${_dir}")
            file(GLOB _dir_children "${_dir}/*")
            if(_dir_children STREQUAL "")
                file(REMOVE_RECURSE "${_dir}")
                set(_removed_empty_dir TRUE)
            endif()
        endif()
    endforeach()
endwhile()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

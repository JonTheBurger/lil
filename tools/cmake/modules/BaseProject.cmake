cmake_minimum_required(VERSION 3.16)
set(CPACK_PACKAGE_VENDOR "humanity")
#$file($line) : $text
#$file:$line: $text

#==============================================================================#
# Check if ${PROJECT_NAME} is being included as a sub-folder
#==============================================================================#
get_directory_property(hasParent PARENT_DIRECTORY)
if (hasParent)
  set(${PROJECT_NAME}_IS_MAIN_PROJECT FALSE)
else()
  set(${PROJECT_NAME}_IS_MAIN_PROJECT TRUE)
endif()

#==============================================================================#
# Include required cmake modules
#==============================================================================#
include(CMakePackageConfigHelpers)
include(GNUInstallDirs)
include(GenerateExportHeader)

#==============================================================================#
# Provide User Options; guess sane defaults
#==============================================================================#
if (${PROJECT_NAME}_IS_MAIN_PROJECT AND CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(projectMaintainer ON)
else()
  set(projectMaintainer OFF)
endif()

option(${PROJECT_NAME}_BUILD_DOCS
  "Build tests for ${PROJECT_NAME}"
  ${projectMaintainer}
)
option(${PROJECT_NAME}_BUILD_TESTS
  "Build tests for ${PROJECT_NAME}"
  ${projectMaintainer}
)
set(${PROJECT_NAME}_TEST_REGEX_FILTER
  ".*"
  CACHE PATH
  "Only test names that match this regular expression will be added (use _^ for none)"
)
set(${PROJECT_NAME}_INSTALL_CMAKE_CONFIG_MODULE_DIR
  "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}"
  CACHE PATH
  "Directory to install ${PROJECT_NAME}Config.cmake to"
)
option(CCACHE_ENABLE
  "Use compiler caching to speed up later compilation"
  ${projectMaintainer}
)

#==============================================================================#
# Standardize default options
#==============================================================================#
set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_EXPORT_NO_PACKAGE_REGISTRY ON)

# MAINTAINER OPTION: Require all symbols to be explicitly exported unless otherwise directed
if (${PROJECT_NAME}_EXPORT_ALL_SYMBOLS)
  set(WINDOWS_EXPORT_ALL_SYMBOLS ON)
else()
  set(CMAKE_C_VISIBILITY_PRESET hidden)
  set(CMAKE_CXX_VISIBILITY_PRESET hidden)
  set(CMAKE_VISIBILITY_INLINES_HIDDEN ON)
  set(WINDOWS_EXPORT_ALL_SYMBOLS OFF)
endif()
#generate_export_header(${PROJECT_NAME}
#  EXPORT_FILE_NAME ${PROJECT_NAME}.export.h
#)

# MAINTAINER OPTION: Install platform's standard libraries along with executable
# (see also: BundleUtilities, GetPrerequisites)
if (${PROJECT_NAME}_INSTALL_RUNTIME)
  set(CMAKE_INSTALL_SYSTEM_RUNTIME_COMPONENT ${PROJECT_NAME}_Runtime)
  include(InstallRequiredSystemLibraries)
endif()

# Set default directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_INSTALL_DOCDIR ${CMAKE_INSTALL_DATAROOTDIR}/doc/${PROJECT_NAME})
if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/install CACHE PATH "" FORCE)
endif()

# Enable relative shared object lookup, enabling relocatable binaries
file(RELATIVE_PATH relativeBinToLibDir
  ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}
  ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}
)
if (APPLE)
  set(originPath @loader_path)
else()
  set(originPath $ORIGIN)
endif()
set(CMAKE_INSTALL_RPATH ${originPath} ${originPath}/${relativeBinToLibDir})
set(CMAKE_BUILD_RPATH_USE_ORIGIN ON)

# Install package version info
write_basic_package_version_file(
  ${PROJECT_NAME}ConfigVersion.cmake
  COMPATIBILITY SameMinorVersion
)
install(
  FILES       ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
  DESTINATION ${${PROJECT_NAME}_INSTALL_CMAKE_CONFIG_MODULE_DIR}
)

# Create uninstall target
if(NOT TARGET uninstall)
  configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/cmake_uninstall.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
    IMMEDIATE @ONLY
  )

  add_custom_target(uninstall COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)
endif()

function(finalize_target TARGET)
  set_target_properties(${TARGET} PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
  )
  add_library(${PROJECT_NAME}::${TARGET} ALIAS ${TARGET})
  install(
    TARGETS
      ${TARGET}
    EXPORT
      ${PROJECT_NAME}
    RUNTIME
      DESTINATION ${CMAKE_INSTALL_BINDIR}
      COMPONENT   ${PROJECT_NAME}_Runtime
    LIBRARY
      DESTINATION ${CMAKE_INSTALL_LIBDIR}
      COMPONENT   ${PROJECT_NAME}_Runtime
      NAMELINK_COMPONENT ${PROJECT_NAME}_Development
    ARCHIVE
      DESTINATION ${CMAKE_INSTALL_LIBDIR}
      COMPONENT   ${PROJECT_NAME}_Development
    INCLUDES
      DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
  )
endfunction()

set(_THIS_MODULE_BASE_DIR "${CMAKE_CURRENT_LIST_DIR}")
function(finalize_project)
  install(EXPORT ${PROJECT_NAME}
    DESTINATION ${${PROJECT_NAME}_INSTALL_CMAKE_CONFIG_MODULE_DIR}
    NAMESPACE ${PROJECT_NAME}::
  )
  configure_package_config_file(
    ${_THIS_MODULE_BASE_DIR}/BaseProjectConfig.cmake.in
    ${PROJECT_NAME}Config.cmake
    INSTALL_DESTINATION ${${PROJECT_NAME}_INSTALL_CMAKE_CONFIG_MODULE_DIR}
    # PATH_VARS cmakeModulesDir
  )
  install(FILES ${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
    DESTINATION ${${PROJECT_NAME}_INSTALL_CMAKE_CONFIG_MODULE_DIR}
  )
endfunction()

#==============================================================================#
# Add custom CMake Build Type/Configurations
#==============================================================================#
find_package(BuildConfType)
if (projectMaintainer)
  set_default_build_type(Debug)
else()
  set_default_build_type(Release)
endif()

add_build_conf(
  NAME     Profile
  COMPILER Clang|GNU
  FLAGS    -p -g -O2
)
add_build_conf(
  NAME     ASan
  COMPILER Clang|GNU
  FLAGS    -fsanitize=address,leak -g
)
add_build_conf(
  NAME     MSan
  COMPILER Clang|GNU
  FLAGS    -fsanitize=memory
)
add_build_conf(
  NAME     TSan
  COMPILER Clang|GNU
  FLAGS    -fsanitize=thread
)
add_build_conf(
  NAME     UBSan
  COMPILER Clang|GNU
  FLAGS    -fsanitize=undefined
)
add_build_conf(
  NAME     Fuzz
  COMPILER Clang|GNU
  FLAGS    -fsanitize=fuzzer,address,leak
)

#==============================================================================#
# Compiler and Linker Settings
#==============================================================================#
find_package(CCache)
find_package(Linker)
set_preferred_linker(lld)
enable_link_time_optimization(CONFIG Release)

#==============================================================================#
# Documentation
#==============================================================================#
if (${PROJECT_NAME}_BUILD_DOCS)
# Doxygen
find_package(Doxygen)
set(DOXYGEN_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/docs)
configure_file(${PROJECT_SOURCE_DIR}/docs/Doxyfile.in ${DOXYGEN_OUTPUT_DIRECTORY}/Doxyfile)
# TODO: custom target DEPENDS on custom command that generates Doxyfile, use output as stamp
add_custom_target(${PROJECT_NAME}.doxygen.xml
  COMMAND
    Doxygen::doxygen ${PROJECT_BINARY_DIR}/docs/Doxyfile --verbose
  WORKING_DIRECTORY
    ${PROJECT_BINARY_DIR}/docs
)

# Sphinx
find_package(PythonVEnv)
add_python_venv()
add_python_venv_requirements(FILE ${PROJECT_SOURCE_DIR}/tools/cmake/docs/requirements.txt)
add_custom_target(.venv.pipfreeze
  COMMAND PythonVEnv::.venv::Interpreter -m pip freeze
)

configure_file(${PROJECT_SOURCE_DIR}/docs/source/conf.py ${DOXYGEN_OUTPUT_DIRECTORY}/source/conf.py)
configure_file(${PROJECT_SOURCE_DIR}/docs/source/index.rst ${DOXYGEN_OUTPUT_DIRECTORY}/source/index.rst)
add_python_venv_requirements(FILE ${PROJECT_SOURCE_DIR}/docs/source/requirements.txt)
add_custom_target(${PROJECT_NAME}.sphinx.pip_install
  COMMAND
    PythonVEnv::.venv::Interpreter -m pip install -r ${PROJECT_SOURCE_DIR}/tools/python/requirements.txt
)
add_custom_target(${PROJECT_NAME}.sphinx.breathe_apidocs
  COMMAND
    breathe-apidoc -o ${DOXYGEN_OUTPUT_DIRECTORY}/source ${DOXYGEN_OUTPUT_DIRECTORY}/xml
)
add_custom_target(${PROJECT_NAME}.sphinx
  COMMAND
    PythonVEnv::.venv::Interpreter -m sphinx -b html ${DOXYGEN_OUTPUT_DIRECTORY}/source ${DOXYGEN_OUTPUT_DIRECTORY}/sphinx
  WORKING_DIRECTORY
    ${DOXYGEN_OUTPUT_DIRECTORY}
)
add_dependencies(${PROJECT_NAME}.sphinx
  ${PROJECT_NAME}.sphinx.pip_install
  ${PROJECT_NAME}.doxygen.xml
  ${PROJECT_NAME}.sphinx.breathe_apidocs
)
endif()

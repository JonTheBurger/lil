cmake_minimum_required(VERSION 3.16)
set(CPACK_PACKAGE_VENDOR "humanity")

#==============================================================================#
# Check if ${PROJECT_NAME} is being included as a sub-folder
#==============================================================================#
set(${PROJECT_NAME}_IS_MAIN_PROJECT FALSE)
if (CMAKE_CURRENT_SOURCE_DIR STREQUAL PROJECT_SOURCE_DIR)
  set(${PROJECT_NAME}_IS_MAIN_PROJECT TRUE)
endif()

#==============================================================================#
# Provide User Options; guess sane defaults
#==============================================================================#
if (${PROJECT_NAME}_IS_MAIN_PROJECT AND CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  # TODO: Put this in cache
  set(isProjectMaintainer ON)
else()
  set(isProjectMaintainer OFF)
endif()
set(isProjectMaintainer ON)

option(${PROJECT_NAME}_BUILD_DOCS
  "Build tests for ${PROJECT_NAME}"
  ${isProjectMaintainer}
)
option(${PROJECT_NAME}_BUILD_TESTS
  "Build tests for ${PROJECT_NAME}"
  ${isProjectMaintainer}
)
set(${PROJECT_NAME}_TEST_REGEX_FILTER
  ".*"
  CACHE PATH
  "Only test names that match this regular expression will be added (use _^ for none)"
)
option(CCACHE_ENABLE
  "Use compiler caching to speed up later compilation"
  ${isProjectMaintainer}
)

#==============================================================================#
# Standardize default options
#==============================================================================#
include(GNUInstallDirs)
include(InstallPackage)
set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_EXPORT_NO_PACKAGE_REGISTRY ON)
set(CMAKE_DEBUG_POSTFIX _d)

# MAINTAINER OPTION: Require all symbols to be explicitly exported unless otherwise directed
if (${PROJECT_NAME}_EXPORT_ALL_SYMBOLS)
  set(WINDOWS_EXPORT_ALL_SYMBOLS ON)
else()
  set(CMAKE_C_VISIBILITY_PRESET hidden)
  set(CMAKE_CXX_VISIBILITY_PRESET hidden)
  set(CMAKE_VISIBILITY_INLINES_HIDDEN ON)
  set(WINDOWS_EXPORT_ALL_SYMBOLS OFF)
endif()

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

# Create uninstall target
configure_file(
  "${CMAKE_CURRENT_LIST_DIR}/cmake_uninstall.cmake.in"
  "${PROJECT_BINARY_DIR}/cmake_uninstall.cmake"
  @ONLY
)
add_custom_target(${PROJECT_NAME}.uninstall COMMAND ${CMAKE_COMMAND} -P ${PROJECT_BINARY_DIR}/cmake_uninstall.cmake)
if(${PROJECT_NAME}_IS_MAIN_PROJECT AND NOT TARGET uninstall)
  add_custom_target(uninstall COMMAND ${CMAKE_COMMAND} -P ${PROJECT_BINARY_DIR}/cmake_uninstall.cmake)
endif()

#==============================================================================#
# Add custom CMake Build Type/Configurations
#==============================================================================#
if (isProjectMaintainer)
  find_package(BuildConfType)
  set_default_build_type(Debug)
  add_build_type(Profile)
  set_build_flags(Profile
    COMPILER Clang|GNU
    CFLAGS   -p -g -pg -O2
    DOC      "Compile with profiling support"
    CACHE
  )

  find_package(Linker)
  set_preferred_linker(lld)
  enable_link_time_optimization(CONFIG Release)

  find_package(Sanitizers)
  if (${PROJECT_NAME}_ENABLE_ASAN)
#    list(APPEND LINK_LIRARIES Sanitizers::ASAN)
#    link_libraries($<LINK_ONLY:Sanitizers::ASAN>)
#    link_libraries($<BUILD_INTERFACE:Sanitizers::ASAN>)
  endif()
  if (${PROJECT_NAME}_ENABLE_TSAN)
    link_libraries(Sanitizers::TSAN)
  endif()
  if (${PROJECT_NAME}_ENABLE_MSAN)
    link_libraries(Sanitizers::MSAN)
  endif()

  find_package(ProfileGuidedOptimization)
  if (${PROJECT_NAME}_ENABLE_PGO_GENERATE)
    link_libraries(ProfileGuidedOptimization::Generate)
  endif()
  if (${PROJECT_NAME}_ENABLE_PGO_USE)
    link_libraries(ProfileGuidedOptimization::Use)
  endif()

  find_package(CCache)
elseif (${PROJECT_NAME}_IS_MAIN_PROJECT)
  find_package(BuildConfType)
  set_default_build_type(Release)
endif()

#==============================================================================#
# Documentation
#==============================================================================#
if (${PROJECT_NAME}_BUILD_DOCS)
  #$file($line) : $text
  #$file:$line: $text
  find_package(Documentation)
endif()

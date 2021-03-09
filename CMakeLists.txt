cmake_minimum_required(VERSION 3.16)
project(lil
  VERSION 0.0.1
  DESCRIPTION "Little Integrated Library"
  LANGUAGES C CXX ASM
)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 20)
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/tools/cmake/modules)
include(BaseProject)
include(GenerateExportHeader)

add_library(${PROJECT_NAME}
  ${CMAKE_CURRENT_LIST_DIR}/src/lil/Err.cpp
  ${CMAKE_CURRENT_LIST_DIR}/include/lil/Assert.hpp
  ${CMAKE_CURRENT_LIST_DIR}/include/lil/Binary.hpp
  ${CMAKE_CURRENT_LIST_DIR}/include/lil/Err.hpp
  ${CMAKE_CURRENT_LIST_DIR}/include/lil/Interval.hpp
  ${CMAKE_CURRENT_LIST_DIR}/include/lil/Str.hpp
  ${CMAKE_CURRENT_LIST_DIR}/include/lil/detail/IArr.hpp
)
generate_export_header(${PROJECT_NAME}
  EXPORT_FILE_NAME ${PROJECT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}.export.h
)
target_include_directories(${PROJECT_NAME}
  PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/${CMAKE_INSTALL_INCLUDEDIR}>
)
#add_library(${PROJECT_NAME}.config)
#target_precompile_headers(${PROJECT_NAME}
#  PRIVATE
#    $<BUILD_INTERFACE:$<$<COMPILE_LANGUAGE:CXX>:<PrecompiledHeader.hpp$<ANGLE-R>>>
#    $<BUILD_INTERFACE:$<$<COMPILE_LANGUAGE:C>:<PrecompiledHeader.h$<ANGLE-R>>>
#)
#target_precompile_headers(${PROJECT_NAME}.config REUSE_FROM ${PROJECT_NAME}.pch)
target_install_package(${PROJECT_NAME})

if (${${PROJECT_NAME}_BUILD_TESTS})
  # Prefer enable_testing over include(CTest) because CTest creates several targets we do not use
  enable_testing()
  add_subdirectory(tests)
endif()

project_install_package()

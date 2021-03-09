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

add_library(${PROJECT_NAME}
  ${CMAKE_CURRENT_LIST_DIR}/src/lil/Err.cpp
  ${CMAKE_CURRENT_LIST_DIR}/include/lil/Assert.hpp
  ${CMAKE_CURRENT_LIST_DIR}/include/lil/Binary.hpp
  ${CMAKE_CURRENT_LIST_DIR}/include/lil/Err.hpp
  ${CMAKE_CURRENT_LIST_DIR}/include/lil/Interval.hpp
  ${CMAKE_CURRENT_LIST_DIR}/include/lil/Str.hpp
  ${CMAKE_CURRENT_LIST_DIR}/include/lil/detail/IArr.hpp
)
target_include_directories(${PROJECT_NAME}
  PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
)
target_install_package(${PROJECT_NAME})

if (${${PROJECT_NAME}_BUILD_TESTS})
  # Prefer enable_testing over include(CTest) because CTest creates several targets we do not use
  enable_testing()
  add_subdirectory(tests)
endif()

project_install_package()

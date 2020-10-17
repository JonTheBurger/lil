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

add_library(${PROJECT_NAME})
add_subdirectory(src)
add_subdirectory(include)
if (${${PROJECT_NAME}_BUILD_TESTS})
  enable_testing()
  add_subdirectory(tests)
endif()

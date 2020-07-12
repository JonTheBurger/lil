cmake_minimum_required(VERSION 3.11)
project(lil
  VERSION 0.0.1
  DESCRIPTION "Little Integrated Library"
  LANGUAGES C CXX ASM
)

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/tools/cmake/modules)
set(CMAKE_CXX_STANDARD 14)

find_package(BuildConfType)
add_build_conf(NAME Profile)
add_build_conf(NAME ASAN)
add_build_conf(NAME MSAN)
add_build_conf(NAME TSAN)
set_default_build_type(Profile)

option(${PROJECT_NAME}_BUILD_TESTS "Build tests for ${PROJECT_NAME}" ON)
option(${PROJECT_NAME}_BUILD_DOCS "Build tests for ${PROJECT_NAME}" ON)
option(${PROJECT_NAME}_DEVELOPER "Build tests for ${PROJECT_NAME}" OFF)
#option(${PROJECT_NAME}_DEVOPS "Build tests for ${PROJECT_NAME}" OFF)
#set(${PROJECT_NAME}_IS_TOP_PROJECT "Build tests for ${PROJECT_NAME}" TRUE)

add_library(${PROJECT_NAME}
  ${CMAKE_CURRENT_LIST_DIR}/include/lil/Assert.hpp
  ${CMAKE_CURRENT_LIST_DIR}/include/lil/Err.hpp
  ${CMAKE_CURRENT_LIST_DIR}/include/lil/Interval.hpp
  ${CMAKE_CURRENT_LIST_DIR}/include/lil/Str.hpp
  ${CMAKE_CURRENT_LIST_DIR}/include/lil/detail/IArr.hpp
  ${CMAKE_CURRENT_LIST_DIR}/src/lil/Err.cpp
)
target_include_directories(${PROJECT_NAME}
  PUBLIC
    ${CMAKE_CURRENT_LIST_DIR}/include
    ${CMAKE_CURRENT_BINARY_DIR}
)

#==============================================================================#
# Documentation
#==============================================================================#
# Doxygen
#find_package(Doxygen)
#set(DOXYGEN_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/docs)
#configure_file(${PROJECT_SOURCE_DIR}/docs/Doxyfile.in ${DOXYGEN_OUTPUT_DIRECTORY}/Doxyfile)
#add_custom_target(${PROJECT_NAME}.doxygen.xml
#  COMMAND
#    Doxygen::doxygen ${PROJECT_BINARY_DIR}/docs/Doxyfile
#  WORKING_DIRECTORY
#    ${PROJECT_BINARY_DIR}/docs
#)

# Sphinx
#find_package(PythonVenv)
#configure_file(${PROJECT_SOURCE_DIR}/docs/source/conf.py ${DOXYGEN_OUTPUT_DIRECTORY}/source/conf.py)
#configure_file(${PROJECT_SOURCE_DIR}/docs/source/index.rst ${DOXYGEN_OUTPUT_DIRECTORY}/source/index.rst)
#add_custom_target(${PROJECT_NAME}.sphinx.pip_install
#  COMMAND
#    Python::Interpreter -m pip install -r ${PROJECT_SOURCE_DIR}/tools/python/requirements.txt
#)
#add_custom_target(${PROJECT_NAME}.sphinx
#  COMMAND
#    Python::Interpreter -m sphinx -b html ${DOXYGEN_OUTPUT_DIRECTORY}/source ${DOXYGEN_OUTPUT_DIRECTORY}/sphinx
#  WORKING_DIRECTORY
#    ${DOXYGEN_OUTPUT_DIRECTORY}
#)
#add_dependencies(${PROJECT_NAME}.sphinx ${PROJECT_NAME}.sphinx.pip_install ${PROJECT_NAME}.doxygen.xml)

if (${${PROJECT_NAME}_BUILD_TESTS})
  ################################################################################
  # GoogleTest/Mock - Test/Mock Framework
  ################################################################################
  if (${PROJECT_NAME}_BUILD_TESTS AND NOT TARGET gtest)
    cmake_minimum_required(VERSION 3.11)

    set(gtest_force_shared_crt ON CACHE BOOL "Always use msvcrt.dll" FORCE)
    include(FetchContent)
    FetchContent_Declare(
      googletest
      GIT_REPOSITORY https://github.com/google/googletest.git
      GIT_TAG        release-1.8.1
      QUIET
    )

    FetchContent_GetProperties(googletest)
    if(NOT googletest_POPULATED)
      FetchContent_Populate(googletest)
      add_subdirectory(${googletest_SOURCE_DIR} ${googletest_BINARY_DIR})
    endif()
  endif()

  ################################################################################
  # Specify test cpp file names.
  ################################################################################
  set(TEST_FILES
    Str.test
  )

  ################################################################################
  # Generate tests.
  ################################################################################
  foreach(TESTF ${TEST_FILES})
    add_executable(${TESTF} ${CMAKE_CURRENT_LIST_DIR}/tests/${TESTF}.cpp)
    target_link_libraries(${TESTF}
      PRIVATE
      ${PROJECT_NAME}
      gmock_main
      gtest
    )
    target_include_directories(${TESTF}
      PRIVATE
      ${CMAKE_CURRENT_LIST_DIR}/tests
    )
    add_test(NAME ${TESTF} COMMAND ${TESTF})
  endforeach()
endif()

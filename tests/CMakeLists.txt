#==============================================================================#
# Download GoogleTest and GoogleMock
#==============================================================================#
if (NOT TARGET gtest)
  cmake_minimum_required(VERSION 3.11)

  # Download gtest to a temp dir so the source files can be shared between builds
  include(TempDir)
  temp_dir(tmp)
  set(gtestVersion 1.10.0)
  set(gtestSourceDir "${tmp}/gtest/${gtestVersion}")
  file(MAKE_DIRECTORY ${gtestSourceDir})

  # Fetch the content
  include(FetchContent)
  set(gtest_force_shared_crt ON CACHE BOOL "Always use msvcrt.dll" FORCE)
  FetchContent_Declare(
    gtest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG        release-${gtestVersion}
    SOURCE_DIR     ${gtestSourceDir}
  )
  FetchContent_MakeAvailable(gtest)
endif()

#==============================================================================#
# Specify test cpp file names
#==============================================================================#
set(TEST_FILES
  Binary.test
  Str.test
)

#==============================================================================#
# Generate tests
#==============================================================================#
foreach(testSource ${TEST_FILES})
  add_executable(${testSource} ${CMAKE_CURRENT_LIST_DIR}/${testSource}.cpp)
  target_link_libraries(${testSource}
    PRIVATE
    ${PROJECT_NAME}
    gmock_main
    gtest
  )
  target_include_directories(${testSource}
    PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}/tests
  )
  add_test(NAME ${testSource} COMMAND ${testSource})
endforeach()

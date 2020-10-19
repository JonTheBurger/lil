cmake_minimum_required(VERSION 3.11)
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
# Set default directory output options
#==============================================================================#
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/install CACHE PATH "" FORCE)
endif()

#==============================================================================#
# Provide User Options; guess sane defaults
#==============================================================================#
if (${PROJECT_NAME}_IS_MAIN_PROJECT AND CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(useProjectDeveloperDefaults ON)
else()
  set(useProjectDeveloperDefaults OFF)
endif()

option(${PROJECT_NAME}_BUILD_TESTS "Build tests for ${PROJECT_NAME}" ${useProjectDeveloperDefaults})
option(${PROJECT_NAME}_BUILD_DOCS "Build tests for ${PROJECT_NAME}" ${useProjectDeveloperDefaults})
option(CCACHE_ENABLE "Use compiler caching to speed up later compilation" ${useProjectDeveloperDefaults})

#==============================================================================#
# Add custom CMake Build Type/Configurations
#==============================================================================#
find_package(BuildConfType)
if (useProjectDeveloperDefaults)
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
set_project_linker(lld)
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

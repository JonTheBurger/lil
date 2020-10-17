#[=======================================================================[.rst:
FindPythonVEnv
--------------

Provides access to a python 3 interpreter within a virtual enviornment. ``python3-venv`` must be installed.

Example Usages:

.. code-block:: cmake

  find_package(FindPythonVEnv)
  pythonvenv_dependency()

Imported Targets
^^^^^^^^^^^^^^^^

  ``PythonVEnv::Interpreter``
  Python interpreter within the virtual environment.

  ``PythonVEnv::HostInterpreter``
  Python interpreter used to generate the virtual environment.

Cache Variables
^^^^^^^^^^^^^^^

.. variable:: PythonVEnv_FOUND

  True if the ``python`` executable and ``venv`` module were found.

.. variable:: PythonVEnv_DefaultBase

  Directory to place python virtual enviornment. Defaults to ``${PROJECT_SOURCE_DIR}/.venv``.

.. variable:: PythonVEnv_HOST_EXECUTABLE

  Python executable required to generate the virtual environment.

Functions
^^^^^^^^^
#]=======================================================================]
cmake_minimum_required(VERSION 3.10)
include_guard(GLOBAL)
include(FindPackageHandleStandardArgs)

set(PythonVEnv_DefaultBase ${PROJECT_SOURCE_DIR} CACHE PATH "Directory to place python virtual enviornment")

find_program(PythonVEnv_HOST_EXECUTABLE
  NAMES python3 python
)

add_executable(PythonVEnv IMPORTED GLOBAL)
set_property(TARGET PythonVEnv PROPERTY IMPORTED_LOCATION ${PythonVEnv_HOST_EXECUTABLE})
add_executable(PythonVEnv::HostInterpreter ALIAS PythonVEnv)

execute_process(
  COMMAND "${PythonVEnv_HOST_EXECUTABLE}" -m venv --help
  RESULT_VARIABLE venvReturnCode
  OUTPUT_QUIET
  ERROR_QUIET
)

if (NOT venvReturnCode EQUAL 0)
  unset(PythonVEnv_HOST_EXECUTABLE CACHE)
endif()

find_package_handle_standard_args(PythonVEnv REQUIRED_VARS
  PythonVEnv_HOST_EXECUTABLE
)

#[=======================================================================[.rst:
.. command:: pythonvenv_dependency

  .

  Signatures::

    pythonvenv_dependency(
      NAME <name>
      FILE <path/to/requirements.txt>
    )

  The options are:

  ``NAME <name>``
  .

  ``FILE <path/to/requirements.txt>``
  .

  Example usage:

  .. code-block:: cmake

  pythonvenv_dependency(
    NAME sphinx_requires
    FILE ${CMAKE_CURRENT_LIST_DIR}/sphinx/requirements.txt
  )
#]=======================================================================]
function(add_python_venv)
  list(APPEND CMAKE_MESSAGE_INDENT "[FindPythonVEnv::add_python_venv] ")
  set(optArgs)
  set(oneValueArgs NAME DIR)
  set(multiValueArgs)
  cmake_parse_arguments(arg "${optArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if (NOT arg_NAME)
    set(arg_NAME ".venv")
  endif()
  if (NOT arg_DIR)
    set(arg_DIR ${PythonVEnv_DefaultBase})
  endif()

  execute_process(
    COMMAND ${PythonVEnv_HOST_EXECUTABLE} -m venv ${arg_NAME}
    WORKING_DIRECTORY ${arg_DIR}
  )
  set(PythonVEnv_${arg_NAME}_python ${arg_DIR}/${arg_NAME}/bin/python CACHE FILEPATH "")

  add_executable(${arg_NAME} IMPORTED GLOBAL)
  set_property(TARGET ${arg_NAME} PROPERTY IMPORTED_LOCATION ${PythonVEnv_${arg_NAME}_python})
  add_executable(PythonVEnv::${arg_NAME}::Interpreter ALIAS ${arg_NAME})
endfunction()

#[=======================================================================[.rst:
.. command:: pythonvenv_dependency

  .

  Signatures::

    pythonvenv_dependency(
      NAME <name>
      FILE <path/to/requirements.txt>
    )

  The options are:

  ``NAME <name>``
  .

  ``FILE <path/to/requirements.txt>``
  .

  Example usage:

  .. code-block:: cmake

  pythonvenv_dependency(
    NAME sphinx_requires
    FILE ${CMAKE_CURRENT_LIST_DIR}/sphinx/requirements.txt
  )
#]=======================================================================]
set(PythonVEnv_REQIREMENTS_COUNTER 0 CACHE INTERNAL "")

function(add_python_venv_requirements)
  list(APPEND CMAKE_MESSAGE_INDENT "[FindPythonVEnv::add_python_venv_requirements] ")
  set(optArgs)
  set(oneValueArgs NAME FILE)
  set(multiValueArgs)
  cmake_parse_arguments(arg "${optArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if (NOT arg_NAME)
    set(arg_NAME ".venv")
  endif()
  if (NOT arg_FILE)
    message(FATAL_ERROR "requires: FILE <path/to/requirements.txt>")
  endif()
  if (NOT TARGET ${arg_NAME})
#    message(FATAL_ERROR "Target venv ${arg_NAME} does not exist; call `add_python_venv(<NAME>)` in your build script.")
  endif()

  add_custom_target(${arg_NAME}.requirements.${PythonVEnv_REQIREMENTS_COUNTER}
    COMMAND ${PythonVEnv_${arg_NAME}_python} -m pip install -r ${arg_FILE}
  )

  add_dependencies(${arg_NAME} ${arg_NAME}.requirements.${PythonVEnv_REQIREMENTS_COUNTER})

  math(EXPR nextCounter "${PythonVEnv_REQIREMENTS_COUNTER}+1")
  set(PythonVEnv_REQIREMENTS_COUNTER ${nextCounter} CACHE INTERNAL "" FORCE)
endfunction()

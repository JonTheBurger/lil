#[=======================================================================[.rst:
FindBuildConfType
-----------------

Adds convenient functions for adding and managing :variable:`CMAKE_BUILD_TYPE`
and :variable:`CMAKE_CONFIGURATION_TYPES`.

Example Usages:

.. code-block:: cmake

  find_package(BuildConfType)
  add_build_conf(
    NAME     ASan
    COMPILER Clang|GNU
    FLAGS    -fsanitize=address,leak
  )
  set_default_build_type(Debug)

Functions
^^^^^^^^^
#]=======================================================================]
cmake_minimum_required(VERSION 3.11)
include_guard(GLOBAL)
include(CheckCCompilerFlag)

# On parse, add default build types as combobox entries if not present
set(CMAKE_BUILD_TYPE "" CACHE STRING "")
get_property(buildTypes CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS)
if (NOT buildTypes)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS Debug Release RelWithDebInfo MinSizeRel)
endif()

#[=======================================================================[.rst:
.. command:: add_build_conf

  Adds a new :variable:`CMAKE_BUILD_TYPE` and :variable:`CMAKE_CONFIGURATION_TYPES`
  with the provided flags.

  Signatures::

    add_build_conf(
      NAME <name>
      [COMPILER <pattern>]
      [DOC <docstring>]
      FLAGS <flag1> [<flag2> ...]
    )

  The options are:

  ``NAME <name>``
  Name of the new Build Type/Configuration. Uppercase <NAME> is used for :variable:`CMAKE_<LANG>_FLAGS_<CONFIG>`, and
  lowercase <name> is used for :prop_tgt:`<CONFIG>_POSTFIX`.

  ``COMPILER <pattern>``
  Pattern matching compilers that provided ``FLAGS`` can be used for. If not set, compiler is used to verify each flag
  and check that it is supported. Unsupported flags are then dropped.

  ``DOC <docstring>``
  Docstring to add to :variable:`CMAKE_<LANG>_FLAGS_<CONFIG>` in the CMake Cache.

  ``FLAGS <flag1> [<flag2> ...]``
  Compiler flags to apply to the given Build Type/Configuration.

  Example usage:

  .. code-block:: cmake

  add_build_conf(
    NAME     Profile
    COMPILER Clang|GNU
    DOC      "Compile with profiling support"
    FLAGS    -p -g -O2
  )
#]=======================================================================]
function(add_build_conf)
  list(APPEND CMAKE_MESSAGE_INDENT "[FindBuildConfType::add_build_conf] ")
  message(VERBOSE "(${ARGV})")
  set(optArgs)
  set(oneValueArgs NAME COMPILER DOC)
  set(multiValueArgs FLAGS)
  cmake_parse_arguments(arg "${optArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  if (NOT arg_NAME)
    message(FATAL_ERROR "requires: NAME <argument>")
  endif()

  # If Build/Configuration flags are only valid for certain compilers, skip for non-compliant compilers
  if (arg_COMPILER)
    if (NOT ${CMAKE_C_COMPILER_ID} MATCHES ${arg_COMPILER})
      message(VERBOSE "Ignoring flags for ${arg_COMPILER}")
      return()
    endif()
  # Otherwise, automatically see which flags are valid for the given compiler
  else()
    set(supportedFlags "")
    foreach(flag ${arg_FLAGS})
      string(REGEX REPLACE "[^a-zA-Z0-9]" "" ${flag}Ok ${flag})
      check_c_compiler_flag(${flag} ${flag}Ok)
      if (${${flag}Ok})
        list(APPEND supportedFlags ${flag})
      endif()
    endforeach()
    set(arg_FLAGS ${supportedFlags})
    message(VERBOSE "Supported flags: ${supportedFlags}")
  endif()

  # Add flags for given Build/Configuration to CMakeCache.txt
  string(TOUPPER ${arg_NAME} uppername)
  string(REPLACE ";" " " flags "${arg_FLAGS}")
  set(CMAKE_C_FLAGS_${uppername}             "${flags}" CACHE STRING "${arg_DOC}" FORCE)
  set(CMAKE_CXX_FLAGS_${uppername}           "${flags}" CACHE STRING "${arg_DOC}" FORCE)
  set(CMAKE_EXE_LINKER_FLAGS_${uppername}    "${flags}" CACHE STRING "${arg_DOC}" FORCE)
  set(CMAKE_SHARED_LINKER_FLAGS_${uppername} "${flags}" CACHE STRING "${arg_DOC}" FORCE)
  set(CMAKE_MODULE_LINKER_FLAGS_${uppername} "${flags}" CACHE STRING "${arg_DOC}" FORCE)
  mark_as_advanced(CMAKE_C_FLAGS_${uppername})
  mark_as_advanced(CMAKE_CXX_FLAGS_${uppername})
  mark_as_advanced(CMAKE_EXE_LINKER_FLAGS_${uppername})
  mark_as_advanced(CMAKE_SHARED_LINKER_FLAGS_${uppername})
  mark_as_advanced(CMAKE_MODULE_LINKER_FLAGS_${uppername})

  # Add to CMAKE_BUILD_TYPE combobox
  get_property(buildTypes CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS)
  if (NOT "${arg_NAME}" IN_LIST buildTypes)
    list(APPEND buildTypes "${arg_NAME}")
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS ${buildTypes})
  endif()

  # Add to CMAKE_CONFIGURATION_TYPES for multi-config generators (Visual Studio, XCode, Ninja-Multi)
  get_property(isMultiConf GLOBAL PROPERTY GENERATOR_IS_MULTICONFIG)
  if (isMultiConf)
    if (NOT "${arg_NAME}" IN_LIST CMAKE_CONFIGURATION_TYPES)
      set(CMAKE_CONFIGURATION_TYPES "${CMAKE_CONFIGURATION_TYPES};${arg_NAME}" CACHE STRING "Semicolon separated list of supported configuration types" FORCE)
      string(TOLOWER ${arg_NAME} lowername)
      set(CMAKE_${uppername}_POSTFIX _${lowername})
    endif()
  endif()
endfunction()

#[=======================================================================[.rst:
.. command:: set_default_build_type

  Sets the :variable:`CMAKE_BUILD_TYPE` to a particular ``TYPE`` if none is supplied by the user.

  Signatures::

    set_default_build_type(
      ``<type>``
    )

  The options are:

  ``<type>``
  Name of the Build Type/Configuration to set if currently unset.

  Example usage:

  .. code-block:: cmake

  set_default_build_type(Debug)
#]=======================================================================]
function(set_default_build_type)
  list(APPEND CMAKE_MESSAGE_INDENT "[FindBuildConfType::set_default_build_type] ")
  get_property(buildTypes CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS)
  if (NOT ARGV0)
    message(WARNING "set_default_build_type(...) requires oneof: {${buildTypes}}")
  endif()

  if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE ${ARGV0} CACHE STRING "" FORCE)
  endif()
endfunction()

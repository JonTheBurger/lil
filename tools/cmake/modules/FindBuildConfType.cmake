#[=======================================================================[.rst:
FindBuildConfType
-----------------

Adds convenient functions for adding and managing :variable:`CMAKE_BUILD_TYPE`
and :variable:`CMAKE_CONFIGURATION_TYPES`.

Example Usages:

.. code-block:: cmake

  find_package(BuildConfType)
  add_build_type(ASan)
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
.. command:: set_default_build_type

  Sets the :variable:`CMAKE_BUILD_TYPE` to a particular ``TYPE`` if none is supplied by the user.

  Signatures::

    set_default_build_type(<type>)

  The options are:

  ``<type>``
  Name of the Build Type/Configuration to set if currently unset. Prefer ``PascalCase`` such as ``RelWithDebInfo``.

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

#[=======================================================================[.rst:
.. command:: add_build_type

  Adds a new :variable:`CMAKE_BUILD_TYPE` and :variable:`CMAKE_CONFIGURATION_TYPES`.

  Signatures::

    add_build_type(<name>)

  The options are:

  ``<name>``
  Name of the new Build Type/Configuration. Prefer ``PascalCase`` such as ``RelWithDebInfo``. Uppercase <name> will be
  used for :variable:`CMAKE_<LANG>_FLAGS_<CONFIG>`, and lowercase <name> for :prop_tgt:`<CONFIG>_POSTFIX`.


  Example usage:

.. code-block:: cmake

  add_build_type(Profile)
#]=======================================================================]
function(add_build_type NAME)
  string(TOUPPER ${NAME} uppername)
  string(TOLOWER ${NAME} lowername)

  # Add to CMAKE_BUILD_TYPE combobox
  get_property(buildTypes CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS)
  if (NOT "${NAME}" IN_LIST buildTypes)
    list(APPEND buildTypes "${NAME}")
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS ${buildTypes})
  endif()

  # Add to CMAKE_CONFIGURATION_TYPES for multi-config generators (Visual Studio, XCode, Ninja-Multi)
  get_property(isMultiConf GLOBAL PROPERTY GENERATOR_IS_MULTICONFIG)
  if (isMultiConf)
    if (NOT "${NAME}" IN_LIST CMAKE_CONFIGURATION_TYPES)
      set(CMAKE_CONFIGURATION_TYPES "${CMAKE_CONFIGURATION_TYPES};${NAME}" CACHE STRING "Semicolon separated list of supported configuration types" FORCE)
      string(TOLOWER ${NAME} lowername)
      set(CMAKE_${uppername}_POSTFIX _${lowername})
    endif()
  endif()
endfunction()

#[=======================================================================[.rst:
.. command:: set_build_flags

  Sets the flags for a given build type/configuration.
  .. note:: If you only want to add additional flags, use `command`:add_compile_options: or `command`:add_link_options:
  with the generator expression ``$<CONFIG:cfgs>`` instead.

  Signatures::

    set_build_flags(
      <name>
      [COMPILER <pattern>]
      [FLAGS <flag1> [<flag2> ...]]
      [CFLAGS <flag1> [<flag2> ...]]
      [LFLAGS <flag1> [<flag2> ...]]
      [NO_CACHE]
      [DOC <docstring>]
      [ALLOW_BAD_NEIGHBOR]
    )

  The options are:

  ``<name>``
  Name of the Build Type/Configuration to set flags for.

  ``COMPILER <pattern>``
  Pattern matching compilers that provided flags can be used for. If not set, compiler (and linker if CMake >= 3.18)
  is used to verify each flag and check that it is supported. Unsupported flags are then dropped.
  .. note:: Generator expressions are only supported if COMPILER is explicitly set.

  ``FLAGS <flag1> [<flag2> ...]``
  List of flags to apply to both the linker and compiler for the given Build Type/Configuration.

  ``CFLAGS <flag1> [<flag2> ...]``
  List of flags to apply only to the compiler for the given Build Type/Configuration.

  ``LFLAGS <flag1> [<flag2> ...]``
  List of flags to apply only to the linker for the given Build Type/Configuration.

  ``NO_CACHE``
  Prevents setting :variable:`CMAKE_<LANG>_FLAGS_<CONFIG>` in the CMake cache.
  Cache sets are FORCED if this is the top level project.

  ``DOC <docstring>``
  Docstring to add to :variable:`CMAKE_<LANG>_FLAGS_<CONFIG>` in the CMake Cache.

  ``ALLOW_BAD_NEIGHBOR``
  Forces setting of the CACHE even if this is not the top level project. This is a bad thing to do as a library.

  Example usage:

.. code-block:: cmake

  find_package(BuildConfType)
  add_build_type(Profile)
  set_build_flags(Profile
    COMPILER Clang|GNU
    CFLAGS   -p -g -O2
    DOC      "Compile with profiling support"
  )
#]=======================================================================]
function(set_build_flags NAME)
  list(APPEND CMAKE_MESSAGE_INDENT "[FindBuildConfType::set_build_flags] ")
  message(VERBOSE "(${ARGV})")
  set(optArgs NO_CACHE ALLOW_BAD_NEIGHBOR)
  set(oneValueArgs NAME COMPILER)
  set(multiValueArgs FLAGS CFLAGS LFLAGS)
  cmake_parse_arguments(PARSE_ARGV 1 arg "${optArgs}" "${oneValueArgs}" "${multiValueArgs}")

  if (arg_COMPILER)
    # If flags are specified as only valid for certain compilers, skip for non-matching compilers.
    if (NOT ${CMAKE_C_COMPILER_ID} MATCHES ${arg_COMPILER})
      message(VERBOSE "Ignoring flags for ${arg_COMPILER}")
      return()
    endif()
    # Otherwise trust the user's provided flags. CMAKE_<LANG>_FLAGS must be a string rather than a list.
    string(REPLACE ";" " " cflags "${arg_CFLAGS}")
    string(REPLACE ";" " " lflags "${arg_LFLAGS}")
  else()
    # If the user did not specify a valid compiler, automatically deduce which flags are valid.
    set(cflags "")
    foreach(flag IN LISTS arg_FLAGS arg_CFLAGS)
      string(MAKE_C_IDENTIFIER ${flag}_cflag_supported this_cflag_supported)
      check_c_compiler_flag(${flag} ${this_cflag_supported})
      if (${this_cflag_supported})
        list(APPEND cflags ${flag})
        set(${this_cflag_supported} "" CACHE INTERNAL "" FORCE)
      endif()
    endforeach()

    # Check linker flags as well.
    set(lflags "")
    if (CMAKE_VERSION VERSION_GREATER_EQUAL 3.18)
      # But only if our cmake version is new enough to support checking.
      include(CheckLinkerFlag)
      foreach(flag IN LISTS arg_FLAGS arg_LFLAGS)
        string(MAKE_C_IDENTIFIER ${flag}_lflag_supported this_lflag_supported)
        check_linker_flag(CXX ${flag} ${this_lflag_supported})
        if (${this_lflag_supported})
          list(APPEND lflags ${flag})
          set(${this_lflag_supported} "" CACHE INTERNAL "" FORCE)
        endif()
      endforeach()
    else()
      # If cmake is too old, pretend all flags passed the check.
      set(lflags ${arg_FLAGS} ${arg_LFLAGS})
    endif()

    # Turn arg lists into strings. CMAKE_<LANG>_FLAGS must be a string rather than a list.
    string(REPLACE ";" " " cflags "${cflags}")
    string(REPLACE ";" " " lflags "${lflags}")
  endif()

  if (NOT arg_NO_CACHE)
    # Create a default docstring if one is not provided by the user.
    if (NOT arg_DOC)
      set(arg_DOC "Overridden by ${PROJECT_NAME}")
    endif()
    # If the user requested to set cached variables, then attempt to do so.
    set(setFlagArguments CACHE STRING "${arg_DOC}")
    if (CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME OR arg_ALLOW_BAD_NEIGHBOR)
      # If the user's project is the top level project, forceably override.
      # Sub-projects may also override if they admit they are being a bad neighboar.
      list(APPEND setFlagArguments FORCE)
    endif()
  endif()

  string(TOUPPER ${NAME} uppername)

  set(CMAKE_C_FLAGS_${uppercase}             "${cflags}" ${setFlagArguments})
  set(CMAKE_CXX_FLAGS_${uppercase}           "${cflags}" ${setFlagArguments})
  set(CMAKE_EXE_LINKER_FLAGS_${uppercase}    "${lflags}" ${setFlagArguments})
  set(CMAKE_SHARED_LINKER_FLAGS_${uppercase} "${lflags}" ${setFlagArguments})
  set(CMAKE_MODULE_LINKER_FLAGS_${uppercase} "${lflags}" ${setFlagArguments})

  if (arg_CACHE)
    mark_as_advanced(CMAKE_C_FLAGS_${uppercase})
    mark_as_advanced(CMAKE_CXX_FLAGS_${uppercase})
    mark_as_advanced(CMAKE_EXE_LINKER_FLAGS_${uppercase})
    mark_as_advanced(CMAKE_SHARED_LINKER_FLAGS_${uppercase})
    mark_as_advanced(CMAKE_MODULE_LINKER_FLAGS_${uppercase})
  endif()
endfunction()

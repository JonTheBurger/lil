#[=======================================================================[.rst:
FindLinker
----------

Adds convenient functions for enabling linker specific optimizations, including
overriding the project linker and enabling link time optimization (LTO).

Example Usages:

.. code-block:: cmake

  find_package(Linker)
  set_preferred_linker(lld)
  enable_link_time_optimization(CONFIG Release)

Functions
^^^^^^^^^
#]=======================================================================]
cmake_minimum_required(VERSION 3.9.4)
if (_findLinkerIncluded)
  return()
endif()
set(_findLinkerIncluded TRUE)

find_program(GOLD_EXECUTABLE gold)
find_program(LLD_EXECUTABLE lld)
include(CheckIPOSupported)
check_ipo_supported(RESULT ltoSupported OUTPUT ltoError)

#[=======================================================================[.rst:
.. command:: set_preferred_linker

  If possible, overrides the project linker.

  Signatures::

    set_preferred_linker(
      NAME <name>
    )

  The options are:

  ``NAME <name>``
  Name of the linker, usually `lld` or `gold`.

  Example usage:

  .. code-block:: cmake

  set_preferred_linker(gold)

#]=======================================================================]
function(set_preferred_linker NAME)
  list(APPEND CMAKE_MESSAGE_INDENT "[FindLinker::set_preferred_linker] ")

  find_program(${PROJECT_NAME}_LINKER_EXECUTABLE ${NAME})
  if (NOT ${PROJECT_NAME}_LINKER_EXECUTABLE)
    message(WARNING "linker ${NAME} not found")
    if (CMAKE_CXX_COMPILER_ID MATCHES "Clang" OR CMAKE_CXX_COMPILER_ID MATCHES "GNU")
      add_link_options(-fuse-ld=${NAME})
    endif()
  endif()
endfunction()

#[=======================================================================[.rst:
.. command:: enable_link_time_optimization

  If possible, enables :prop_dir:`INTERPROCEDURAL_OPTIMIZATION` or :prop_dir:`INTERPROCEDURAL_OPTIMIZATION_<CONFIG>` for
  this directory and below.

  Signatures::

    enable_link_time_optimization(
      [CONFIG <type>]
    )

  The options are:

  ``CONFIG <type>``
  Name of the Build Type/Configuration where LTO should be applied globally.

  Example usage:

  .. code-block:: cmake

  # Release only
  enable_link_time_optimization(CONFIG Release)
  # All Configurations
  enable_link_time_optimization()
#]=======================================================================]
function(enable_link_time_optimization)
  list(APPEND CMAKE_MESSAGE_INDENT "[FindLinker::enable_link_time_optimization] ")
  message(VERBOSE "(${ARGV})")
  set(optArgs)
  set(oneValueArgs CONFIG)
  set(multiValueArgs)
  cmake_parse_arguments(arg "${optArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if (NOT ltoSupported)
    message(NOTICE "LTO unsupported: ${ltoError}")
    return()
  endif()

  if (arg_CONFIG)
    string(TOUPPER "${arg_CONFIG}" configName)
    set_property(DIRECTORY PROPERTY INTERPROCEDURAL_OPTIMIZATION_${configName} TRUE)
  else()
    set_property(DIRECTORY PROPERTY INTERPROCEDURAL_OPTIMIZATION TRUE)
  endif()
endfunction()

#[=======================================================================[.rst:
.. command:: target_link_time_optimization

  If possible, enables :prop_tgt:`INTERPROCEDURAL_OPTIMIZATION` or :prop_tgt:`INTERPROCEDURAL_OPTIMIZATION_<CONFIG>` for
  the given target.

  Signatures::

    target_link_time_optimization(
      TARGET <target>
      [CONFIG <type>]
    )

  The options are:

  ``TARGET <target>``
  Name of the target where LTO shall be applied.

  ``CONFIG <type>``
  Name of the Build Type/Configuration where LTO should be applied for the given target.

  Example usage:

  .. code-block:: cmake

  # Release only
  target_link_time_optimization(
    TARGET main
    CONFIG Release
  )
  # All Configurations
  target_link_time_optimization(TARGET main)
#]=======================================================================]
function(target_link_time_optimization)
  list(APPEND CMAKE_MESSAGE_INDENT "[FindLinker::target_link_time_optimization] ")
  message(VERBOSE "(${ARGV})")
  set(optArgs)
  set(oneValueArgs TARGET CONFIG)
  set(multiValueArgs)
  cmake_parse_arguments(arg "${optArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if (NOT arg_TARGET)
    message(FATAL_ERROR "requires: TARGET <argument>")
  endif()

  if (NOT ltoSupported)
    message(NOTICE "LTO unsupported: ${ltoError}")
    return()
  endif()

  if (arg_CONFIG)
    string(TOUPPER "${arg_CONFIG}" configName)
    set_property(TARGET ${arg_TARGET} PROPERTY INTERPROCEDURAL_OPTIMIZATION_${configName} TRUE)
  else()
    set_property(TARGET ${arg_TARGET} PROPERTY INTERPROCEDURAL_OPTIMIZATION TRUE)
  endif()
endfunction()

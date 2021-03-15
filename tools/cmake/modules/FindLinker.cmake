#[=======================================================================[.rst:
FindLinker
----------

.. _ld: https://linux.die.net/man/1/ld
.. _lld: https://manpages.debian.org/experimental/lld-10/ld.lld-10.1.en.html
.. _gold: https://manpages.ubuntu.com/manpages/trusty/man1/ld.gold.1.html
.. _LINK.exe: https://docs.microsoft.com/en-us/cpp/build/reference/linker-options?view=msvc-160

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
cmake_minimum_required(VERSION 3.13) # target_link_options
include_guard(GLOBAL)

find_program(GOLD_EXECUTABLE gold)
find_program(LLD_EXECUTABLE lld)
include(CheckIPOSupported)
check_ipo_supported(RESULT ltoSupported OUTPUT ltoError)

#[=======================================================================[.rst:
.. command:: set_preferred_linker

  If possible, overrides the project linker from ld_ to an alternative. Ignored on ld-like linkers such as LINK.exe_.

  Signatures::

    set_preferred_linker(
      NAME <name>
    )

  The options are:

  ``NAME <name>``
  Name of the linker, usually lld_ or gold_.

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

#[=======================================================================[.rst:
.. command:: target_linker_script

  Sets the linker scripts and script search paths for a given target.

  Signatures::

    target_linker_script(
      TARGET <target>
      LINKER_SCRIPT <path-to-linker-script> [<path-to-linker-script-2> ...]
      [INCLUDE_DIRS <path-to-search-dir> [<path-to-search-dir-2> ...]]
    )

  The options are:

  ``TARGET <target>``
  Name of the target the linker script shall be applied to.

  ``LINKER_SCRIPT <path-to-linker-script> [<path-to-linker-script-2> ...]``
  Paths to the linker scripts.

  ``[INCLUDE_DIRS <path-to-search-dir> [<path-to-search-dir-2> ...]]``
  Paths to directories where the linker will search for scripts. This sets the INCLUDE search path for ld.

  Example usage:

  .. code-block:: cmake

  # Set Executable's Linker Script
  target_linker_script(
    TARGET         main.elf
    LINKER_SCRIPTS src/ld/linker_script.ld
    INCLUDE_DIRS   src/ld
                   src/ld/shared
  )
#]=======================================================================]
function(target_linker_script)
  list(APPEND CMAKE_MESSAGE_INDENT "[FindLinker::target_linker_script] ")
  message(VERBOSE "(${ARGV})")
  set(optArgs)
  set(oneValueArgs TARGET)
  set(multiValueArgs LINKER_SCRIPTS INCLUDE_DIRS)
  cmake_parse_arguments(arg "${optArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if (NOT arg_TARGET)
    message(FATAL_ERROR "requires: TARGET <target>")
  endif()
  if (NOT arg_LINKER_SCRIPT)
    message(FATAL_ERROR "requires: LINKER_SCRIPT <path-to-linker-script> [<path-to-linker-script-2> ...]")
  endif()

  # TODO: Check if interface target and use INTERFACE instead of public
  # Add linker scripts
  foreach(script ${arg_LINKER_SCRIPTS})
    # Causes TARGET to be re-linked if LINKER_SCRIPT changes on disk
    set_target_properties(${arg_TARGET} PROPERTIES LINK_DEPENDS ${script})
    target_link_options(${arg_TARGET}
      PUBLIC
        $<$<OR:$<C_COMPILER_ID:GNU>,$<C_COMPILER_ID:Clang>>:
          LINKER:-T${script}
        >
        $<$<C_COMPILER_ID:IAR>:
          LINKER:--config ${script}
        >
    )
  endforeach()

  # Add search paths
  foreach(indir ${arg_INCLUDE_DIRS})
    target_link_options(${arg_TARGET}
      PUBLIC
        $<$<OR:$<C_COMPILER_ID:GNU>,$<C_COMPILER_ID:Clang>>:
          LINKER:-L${indir}
        >
    )
  endforeach()
endfunction()

#[=======================================================================[.rst:
.. command:: target_map_file

  Generates a map file for a given executable.

  Signatures::

    target_map_file(
      TARGET <target>
      [OUTPUT_PATH <path-to-output-file>]
    )

  The options are:

  ``TARGET <target>``
  Name of the target the linker shall generate a map file for.

  ``[OUTPUT_PATH <path-to-output-file>]``
  Overrides the output path of the map file (`${TARGET}.map` by default).

  Example usage:

  .. code-block:: cmake

  # Generate map file for executable
  target_map_file(TARGET main.elf)
#]=======================================================================]
function(target_map_file)
  list(APPEND CMAKE_MESSAGE_INDENT "[FindLinker::target_map_file] ")
  message(VERBOSE "(${ARGV})")
  set(optArgs)
  set(oneValueArgs TARGET OUTPUT_PATH)
  set(multiValueArgs)
  cmake_parse_arguments(arg "${optArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if (NOT arg_TARGET)
    message(FATAL_ERROR "requires: TARGET <target>")
  endif()

  set(outputPath ${arg_OUTPUT_PATH})
  if (NOT arg_OUTPUT_PATH)
    set(outputPath ${TARGET}.map)
  endif()

  target_link_options(${arg_TARGET}
    PUBLIC
      $<$<OR:$<C_COMPILER_ID:GNU>,$<C_COMPILER_ID:Clang>>:
        LINKER:-Map${outputPath}
      >
      $<$<C_COMPILER_ID:MSVC>:
        LINKER:/MAP:${outputPath}
      >
      $<$<C_COMPILER_ID:IAR>:
        LINKER:--map ${outputPath}
      >
  )
endfunction()

#[=======================================================================[.rst:
.. command:: target_print_size

  Prints the size of the executable on build

  Signatures::

    target_print_size(
      TARGET <target>
    )

  The options are:

  ``TARGET <target>``
  Name of the target the size should be printed for.

  Example usage:

  .. code-block:: cmake

  # Prints the size of the executable on build
  target_print_size(TARGET main.elf)
#]=======================================================================]
function(target_print_size)
  list(APPEND CMAKE_MESSAGE_INDENT "[FindLinker::print_size] ")
  message(VERBOSE "(${ARGV})")
  set(optArgs)
  set(oneValueArgs TARGET)
  set(multiValueArgs)
  cmake_parse_arguments(arg "${optArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if (NOT arg_TARGET)
    message(FATAL_ERROR "requires: TARGET <target>")
  endif()

  target_link_options(${arg_TARGET}
    PUBLIC
      $<$<OR:$<C_COMPILER_ID:GNU>,$<C_COMPILER_ID:Clang>>:
        LINKER:--print-memory-usage
      >
  )
endfunction()

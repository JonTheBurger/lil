#[=======================================================================[.rst:
EmbeddedSystem
--------------

Provides a suite of functions commonly used in bare metal and RTOS-based
embedded systems.

Example Usages:

.. code-block:: cmake

  include(EmbeddedSystem)

Functions
^^^^^^^^^
#]=======================================================================]
cmake_minimum_required(VERSION 3.13) # target_link_options
if (_embeddedSystemIncluded)
  return()
endif()
set(_embeddedSystemIncluded TRUE)

message(STATUS "MCU_INFO: {
  \"MCU_VENDOR\": \"${MCU_VENDOR}\",
  \"MCU_BOARD\": \"${MCU_BOARD}\",
  \"MCU_SERIES\": \"${MCU_SERIES}\",
  \"MCU_FAMILY\": \"${MCU_FAMILY}\",
  \"MCU_CPU\": \"${MCU_CPU}\",
  \"MCU_ARCH\": \"${MCU_ARCH}\",
  \"MCU_FPU\": \"${MCU_FPU}\",
  \"MCU_FLOAT_ABI\": \"${MCU_FLOAT_ABI}\"
}")

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
  list(APPEND CMAKE_MESSAGE_INDENT "[EmbeddedSystem::target_linker_script] ")
  message(VERBOSE "(${ARGV})")
  set(optArgs)
  set(oneValueArgs TARGET)
  set(multiValueArgs LINKER_SCRIPTS INCLUDE_DIRS)
  cmake_parse_arguments(arg "${optArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  # Add linker scripts
  foreach(script ${arg_LINKER_SCRIPTS})
    # Causes TARGET to be re-linked if LINKER_SCRIPT changes on disk
    set_target_properties(${arg_TARGET} PROPERTIES LINK_DEPENDS ${script})
    target_link_options(${arg_TARGET}
      PUBLIC
        $<$<OR:$<C_COMPILER_ID:GNU>,$<C_COMPILER_ID:Clang>>:
          LINKER:-T${script}
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

function(target_map_file)
  list(APPEND CMAKE_MESSAGE_INDENT "[EmbeddedSystem::target_map_file] ")
  message(VERBOSE "(${ARGV})")
  set(optArgs)
  set(oneValueArgs)
  set(multiValueArgs)
  cmake_parse_arguments(arg "${optArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
endfunction()

function(target_print_size)
  list(APPEND CMAKE_MESSAGE_INDENT "[EmbeddedSystem::print_size] ")
  message(VERBOSE "(${ARGV})")
  set(optArgs)
  set(oneValueArgs)
  set(multiValueArgs)
  cmake_parse_arguments(arg "${optArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
endfunction()

function(target_binary_files)
  list(APPEND CMAKE_MESSAGE_INDENT "[EmbeddedSystem::target_binary_files] ")
  message(VERBOSE "(${ARGV})")
  set(optArgs)
  set(oneValueArgs)
  set(multiValueArgs)
  cmake_parse_arguments(arg "${optArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
endfunction()

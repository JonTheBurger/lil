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

  if (NOT arg_TARGET)
    message(FATAL_ERROR "requires: TARGET <target>")
  endif()
  if (NOT arg_LINKER_SCRIPT)
    message(FATAL_ERROR "requires: LINKER_SCRIPT <path-to-linker-script> [<path-to-linker-script-2> ...]")
  endif()

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
  list(APPEND CMAKE_MESSAGE_INDENT "[EmbeddedSystem::target_map_file] ")
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
  list(APPEND CMAKE_MESSAGE_INDENT "[EmbeddedSystem::print_size] ")
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

#[=======================================================================[.rst:
.. command:: target_binary_files

  Generates additional binary formats for an executable.

  Signatures::

    target_binary_files(
      TARGET <target>
      FORMAT <format> [<format-2> ...]
    )

  The options are:

  ``TARGET <target>``
  Name of the target that additional binaries shall be generated for.

  ``FORMAT <format> [<format-2> ...]``
  Format to generate on build. One of `ihex, bin, srec`.

  Example usage:

  .. code-block:: cmake

  # Prints the size of the executable on build
  target_binary_file(
    TARGET
      main.elf
    FORMAT
      ihex
      bin
      srec
  )
#]=======================================================================]
function(target_binary_files)
  list(APPEND CMAKE_MESSAGE_INDENT "[EmbeddedSystem::target_binary_files] ")
  message(VERBOSE "(${ARGV})")
  set(optArgs)
  set(oneValueArgs TARGET)
  set(multiValueArgs FORMAT)
  cmake_parse_arguments(arg "${optArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if (NOT arg_TARGET)
    message(FATAL_ERROR "requires: TARGET <target>")
  endif()
  if (NOT arg_FORMAT)
    message(FATAL_ERROR "requires: FORMAT <format> [<format-2> ...]")
  endif()
  if (NOT CMAKE_OBJCOPY)
    message(FATAL_ERROR "CMAKE_OBJCOPY must be set (e.g. `set(CMAKE_OBJCOPY /usr/bin/objcopy)`)")
  endif()

  foreach(format ${arg_FORMAT})
    add_custom_command(
      TARGET ${arg_TARGET}
      POST_BUILD
      COMMAND ${CMAKE_OBJCOPY} -O ${format}
      COMMENT "Generating ${arg_TARGET} ${format}"
    )
  endforeach()
endfunction()

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
cmake_minimum_required(VERSION 3.11)
include_guard(GLOBAL)

macro(get_mcu_info OUTPUT_VAR)
  set(${OUTPUT_VAR} "MCU_INFO: {
    \"MCU_VENDOR\": \"${MCU_VENDOR}\",
    \"MCU_BOARD\": \"${MCU_BOARD}\",
    \"MCU_SERIES\": \"${MCU_SERIES}\",
    \"MCU_FAMILY\": \"${MCU_FAMILY}\",
    \"MCU_CPU\": \"${MCU_CPU}\",
    \"MCU_ARCH\": \"${MCU_ARCH}\",
    \"MCU_FPU\": \"${MCU_FPU}\",
    \"MCU_FLOAT_ABI\": \"${MCU_FLOAT_ABI}\"
  }")
endmacro()

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
    message(INFO "CMAKE_OBJCOPY is not set; consider `find_program(CMAKE_OBJCOPY objcopy)`. IGNORING")
    return()
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

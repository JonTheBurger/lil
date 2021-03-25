#[=======================================================================[.rst:
FindProfileGuidedOptimization
-----------------------------

Lorem ipsum.

Cache Variables
^^^^^^^^^^^^^^^
.. variable:: PROFILE_GUIDED_OPTIMIZATION_DATA_DIR

  Instrument Lorem ipsum

.. variable:: ${PROJECT_NAME}_ENABLE_PGO_GENERATE

  Lorem ipsum

.. variable:: ${PROJECT_NAME}_ENABLE_PGO_USE

  Lorem ipsum

Imported Targets
^^^^^^^^^^^^^^^^
``ProfileGuidedOptimization::Generate``

  Lorem ipsum

Example Usages:

.. code-block:: cmake

  find_package(ProfileGuidedOptimization)
#]=======================================================================]
cmake_minimum_required(VERSION 3.13)
include_guard(GLOBAL)
include(CheckCCompilerFlag)

set(PROFILE_GUIDED_OPTIMIZATION_DATA_DIR ${CMAKE_BINARY_DIR}/tmp/pgo CACHE PATH
    "Directory where profile guided optimization data will be written to and read from")
mark_as_advanced(PROFILE_GUIDED_OPTIMIZATION_DATA_DIR)

# ============================================================================ #
#
# ============================================================================ #
set(testFlags -fprofile-generate=${PROFILE_GUIDED_OPTIMIZATION_DATA_DIR})
set(PROFILE_GUIDED_OPTIMIZATION_GENERATE_FLAGS "")
foreach(flag IN LISTS testFlags)
  string(MAKE_C_IDENTIFIER ${flag}_cflag_supported this_cflag_supported)
  check_c_compiler_flag(${flag} ${this_cflag_supported})
  if (${this_cflag_supported})
    list(APPEND PROFILE_GUIDED_OPTIMIZATION_GENERATE_FLAGS ${flag})
    set(${this_cflag_supported} "" CACHE INTERNAL "" FORCE)
  endif()
endforeach()

add_library(.profileguidedoptimization.generate INTERFACE)
target_compile_options(.profileguidedoptimization.generate
  INTERFACE
    ${PROFILE_GUIDED_OPTIMIZATION_GENERATE_FLAGS}
)
target_link_options(.profileguidedoptimization.generate
  INTERFACE
    $<$<C_COMPILER_ID:MSVC>:"LINKER:/LTCG LINKER:/GENPROFILE">
)
add_library(ProfileGuidedOptimization::Generate ALIAS .profileguidedoptimization.generate)

# ============================================================================ #
#
# ============================================================================ #
set(testFlags -fprofile-use=${PROFILE_GUIDED_OPTIMIZATION_DATA_DIR})
set(PROFILE_GUIDED_OPTIMIZATION_USE_FLAGS "")
foreach(flag IN LISTS arg_FLAGS testFlags)
  string(MAKE_C_IDENTIFIER ${flag}_cflag_supported this_cflag_supported)
  check_c_compiler_flag(${flag} ${this_cflag_supported})
  if (${this_cflag_supported})
    list(APPEND PROFILE_GUIDED_OPTIMIZATION_USE_FLAGS ${flag})
    set(${this_cflag_supported} "" CACHE INTERNAL "" FORCE)
  endif()
endforeach()

add_library(.profileguidedoptimization.use INTERFACE)
target_compile_options(.profileguidedoptimization.use
  INTERFACE
    ${PROFILE_GUIDED_OPTIMIZATION_USE_FLAGS}
)
target_link_options(.profileguidedoptimization.generate
  INTERFACE
    $<$<C_COMPILER_ID:MSVC>:"LINKER:/LTCG LINKER:/USEPROFILE">
)
add_library(ProfileGuidedOptimization::Use ALIAS .profileguidedoptimization.use)

# ============================================================================ #
# Auto-Declare Global Project Options
# ============================================================================ #
option(${PROJECT_NAME}_ENABLE_PGO_GENERATE "Globally enables instrumenting code for profile guided optimization" OFF)
option(${PROJECT_NAME}_ENABLE_PGO_USE "Globally enables using profile guided optimization instrumentation files" OFF)

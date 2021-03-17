#[=======================================================================[.rst:
FindCompilerTracing
-------------------

.. _GNU Developer Options: https://gcc.gnu.org/onlinedocs/gcc/Developer-Options.html
.. _Clang Command Line Reference: https://clang.llvm.org/docs/ClangCommandLineReference.html

Generates targets, convenience functions, and project options for generating and consuming additional output information
from compilers and linkers. Some options only work on certain compilers. If a compiler does not support an option, it
will be silently ignored. See `GNU Developer Options`_ or `Clang Command Line Reference`_ for more options.

Example Usages:

.. code-block:: cmake

  find_package(CompilerTracing)

Imported Targets
^^^^^^^^^^^^^^^^
  ``CompilerTracing::TimeReport``

  Enables generating output related to how long the build took to run.

  ``CompilerTracing::StackUsage``

  Enables generating stack usage metrics on functions.

  ``CompilerTracing::CallGraph``

  Enables generating call graphs for functions.

  ``CompilerTracing::Temporaries``

  Keeps temporary files (such as preprocessed sources) on disk rather than discarding them.

  ``CompilerTracing::Optimization``

  Enables writing out information relating to how the compiler decided to optimize.

  ``CompilerTracing::Ast``

  Emits the abstract syntax tree of the sources being compiled.

  ``CompilerTracing::All``

  Enables all available compiler tracing facilities.

#]=======================================================================]
cmake_minimum_required(VERSION 3.11)
include_guard(GLOBAL)
include(CheckCCompilerFlag)

# ============================================================================ #
# Time Report
# ============================================================================ #
set(testFlags "")
if (MSVC)
  set(testFlags /Bt+ /d2cgsummary /d1reportTime)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  set(testFlags -ftime-trace)
endif()

set(COMPILE_TRACING_TIME_REPORT_FLAGS "")
foreach(flag IN LISTS testFlags)
check_c_compiler_flag("${flag}" hasFlag)
if (hasFlag)
  list(APPEND COMPILE_TRACING_TIME_REPORT_FLAGS ${flag})
endif()

add_library(.ctcompile_time_report_flags INTERFACE)
target_compile_options(.ctcompile_time_report_flags INTERFACE ${COMPILE_TRACING_TIME_REPORT_FLAGS})
add_library(CompilerTracing::TimeReport ALIAS .ctcompile_time_report_flags)

# ============================================================================ #
# Stack Usage
# ============================================================================ #
set(testFlags -fstack-usage)
set(COMPILE_TRACING_STACK_USAGE_FLAGS "")
foreach(flag IN LISTS testFlags)
  check_c_compiler_flag("${flag}" hasFlag)
  if (hasFlag)
    list(APPEND COMPILE_TRACING_STACK_USAGE_FLAGS ${flag})
  endif()
endforeach()

add_library(.ctstack_usage_flags INTERFACE)
target_compile_options(.ctstack_usage_flags INTERFACE ${COMPILE_TRACING_STACK_USAGE_FLAGS})
add_library(CompilerTracing::StackUsage ALIAS .ctstack_usage_flags)

# ============================================================================ #
# Call Graph
# ============================================================================ #
# Create a function to use either:
# https://github.com/chaudron/cally
# https://stackoverflow.com/questions/5373714/how-to-generate-a-calling-graph-for-c-code -S -emit-llvm
set(testFlags -fdump-ipa-cgraph)
set(COMPILE_TRACING_CALLGRAPH_FLAGS "")
foreach(flag IN LISTS testFlags)
  check_c_compiler_flag("${flag}" hasFlag)
  if (hasFlag)
    list(APPEND COMPILE_TRACING_CALLGRAPH_FLAGS ${flag})
  endif()
endforeach()

add_library(.ctcallgraph_info_flags INTERFACE)
target_compile_options(.ctcallgraph_info_flags INTERFACE ${COMPILE_TRACING_STACK_USAGE_FLAGS})
add_library(CompilerTracing::CallGraph ALIAS .ctcallgraph_info_flags)

# ============================================================================ #
# Temporaries
# ============================================================================ #
set(testFlags -save-temps)
set(COMPILE_TRACING_TEMPORARIES_FLAGS "")
foreach(flag IN LISTS testFlags)
  check_c_compiler_flag("${flag}" hasFlag)
  if (hasFlag)
    list(APPEND COMPILE_TRACING_TEMPORARIES_FLAGS ${flag})
  endif()
endforeach()

add_library(.cttemporaries_flags INTERFACE)
target_compile_options(.cttemporaries_flags INTERFACE ${COMPILE_TRACING_TEMPORARIES_FLAGS})
add_library(CompilerTracing::Temporaries ALIAS .cttemporaries_flags)

# ============================================================================ #
# Optimization
# ============================================================================ #
set(testFlags -fopt-info -fsave-optimization-record)
set(COMPILE_TRACING_OPTIMIZATION_FLAGS "")
foreach(flag IN LISTS testFlags)
  check_c_compiler_flag("${flag}" hasFlag)
  if (hasFlag)
    list(APPEND COMPILE_TRACING_OPTIMIZATION_FLAGS ${flag})
  endif()
endforeach()

add_library(.ctoptimization_flags INTERFACE)
target_compile_options(.ctoptimization_flags INTERFACE ${COMPILE_TRACING_OPTIMIZATION_FLAGS})
add_library(CompilerTracing::Optimization ALIAS .ctoptimization_flags)

# ============================================================================ #
# Ast
# ============================================================================ #
set(testFlags -fdump-tree-all-graph -emit-ast)
set(COMPILE_TRACING_AST_FLAGS "")
foreach(flag IN LISTS testFlags)
  check_c_compiler_flag("${flag}" hasFlag)
  if (hasFlag)
    list(APPEND COMPILE_TRACING_AST_FLAGS ${flag})
  endif()
endforeach()

add_library(.ctast_flags INTERFACE)
target_compile_options(.ctast_flags INTERFACE ${COMPILE_TRACING_AST_FLAGS})
add_library(CompilerTracing::Ast ALIAS .ctast_flags)

# ============================================================================ #
# All
# ============================================================================ #
add_library(.ctcompiler_tracing_all_flags INTERFACE)
target_link_libraries(.ctcompiler_tracing_all_flags
  INTERFACE
    CompilerTracing::TimeReport
    CompilerTracing::StackUsage
    CompilerTracing::CallGraph
    CompilerTracing::Temporaries
    CompilerTracing::Optimization
    CompilerTracing::Ast
)
add_library(CompilerTracing::All ALIAS .ctcompiler_tracing_all_flags)

#[=======================================================================[.rst:
FindCompilerTracing
-------------------


Example Usages:

.. code-block:: cmake

  find_package(CompilerTracing)

#]=======================================================================]
cmake_minimum_required(VERSION 3.11)
include_guard(GLOBAL)
include(CheckCCompilerFlag)

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

add_library(.compile_time_report_flags INTERFACE)
target_compile_options(.compile_time_report_flags INTERFACE ${COMPILE_TRACING_TIME_REPORT_FLAGS})
add_library(CompilerTracing::TimeReport ALIAS .compile_time_report_flags)

set(testFlags -fstack-usage)
set(COMPILE_TRACING_STACK_USAGE_FLAGS "")
foreach(flag IN LISTS testFlags)
  check_c_compiler_flag("${flag}" hasFlag)
  if (hasFlag)
    list(APPEND COMPILE_TRACING_STACK_USAGE_FLAGS ${flag})
  endif()
endforeach()

add_library(.stack_usage_flags INTERFACE)
target_compile_options(.stack_usage_flags INTERFACE ${COMPILE_TRACING_STACK_USAGE_FLAGS})
add_library(CompilerTracing::StackUsage ALIAS .stack_usage_flags)

# https://github.com/chaudron/cally
set(testFlags -fdump-rtl-expand -fdump-ipa-cgraph)
set(COMPILE_TRACING_CALLGRAPH_FLAGS "")
foreach(flag IN LISTS testFlags)
  check_c_compiler_flag("${flag}" hasFlag)
  if (hasFlag)
    list(APPEND COMPILE_TRACING_CALLGRAPH_FLAGS ${flag})
  endif()
endforeach()

add_library(.callgraph_info_flags INTERFACE)
target_compile_options(.callgraph_info_flags INTERFACE ${COMPILE_TRACING_STACK_USAGE_FLAGS})
add_library(CompilerTracing::CallGraph ALIAS .callgraph_info_flags)

set(testFlags -fdump-tree-all-graph)
set(COMPILE_TRACING_AST_FLAGS "")
foreach(flag IN LISTS testFlags)
  check_c_compiler_flag("${flag}" hasFlag)
  if (hasFlag)
    list(APPEND COMPILE_TRACING_AST_FLAGS ${flag})
  endif()
endforeach()

add_library(.ast_flags INTERFACE)
target_compile_options(.ast_flags INTERFACE ${COMPILE_TRACING_AST_FLAGS})
add_library(CompilerTracing::Ast ALIAS .ast_flags)

add_library(.compiler_tracing_all_flags INTERFACE)
target_link_libraries(.compiler_tracing_all_flags
  INTERFACE
    CompilerTracing::TimeReport
    CompilerTracing::StackUsage
    CompilerTracing::CallGraph
    CompilerTracing::Ast
)
add_library(CompilerTracing::All ALIAS .compiler_tracing_all_flags)

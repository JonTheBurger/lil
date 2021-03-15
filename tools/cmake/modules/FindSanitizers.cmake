#[=======================================================================[.rst:
FindSanitizers
--------------

.. _google_asan_docs: https://github.com/google/sanitizers/wiki/AddressSanitizerFlags#run-time-flags
.. _gcc_asan_docs: https://gcc.gnu.org/onlinedocs/gcc-7.3.0/gcc/Instrumentation-Options.html
.. _clang_asan_docs: https://clang.llvm.org/docs/AddressSanitizer.html
.. _msvc_asan_docs: https://docs.microsoft.com/en-us/cpp/sanitizers/asan?view=msvc-160

Generates targets and project options for all sanitizer types. Because sanitizers could be reasonably combine with any
build type/configuration, it is more scalable to conditionally enable sanitizers rather than create a custom build
type/configuration (though clang in particular recommends compiling with ``-O1``).

Example Usages:

.. code-block:: cmake

  # Example 1: Globally enable ASAN compatible sanitizers (Leak + UB)
  find_package(Sanitizers)
  if (${PROJECT_NAME}_ENABLE_ASAN)
    link_libraries(Sanitizers::ASAN)
  endif()

  # Example 2: Globally enable only Address Sanitizer
  find_package(Sanitizers)
  link_libraries(Sanitizers::Address)

  # Example 3: Enable Fuzz testing for an executable with libfuzzer
  find_package(Sanitizers)
  target_link_libraries(MyFuzzTest PRIVATE Sanitizers::Fuzzer)

Cache Variables
^^^^^^^^^^^^^^^
.. variable:: ${PROJECT_NAME}_ENABLE_ASAN

  Globally enables all Address Sanitizer compatible sanitizers, namely LSan and UBSan, and optimal stacktrace flags.
  Any sanitizers not found are silently ignored.

.. variable:: ${PROJECT_NAME}_ENABLE_TSAN

  Globally enables all Thread Sanitizer compatible sanitizers, namely UBSan, and optimal stacktrace flags.
  Any sanitizers not found are silently ignored.

.. variable:: ${PROJECT_NAME}_ENABLE_MSAN

  Globally enables all Memory Sanitizer compatible sanitizers, namely UBSan, and optimal stacktrace flags.
  Any sanitizers not found are silently ignored.

Components
^^^^^^^^^^
* ``ASAN``: check for ASAN support.
* ``LSAN``: check for LSAN support.
* ``UBSAN``: check for UBSAN support.
* ``MSAN``: check for MSAN support.
* ``FUZZER``: check for libFuzzer support.

If no ``COMPONENTS`` are specified, only ``ASAN`` is verified for validity.

Result Variables
^^^^^^^^^^^^^^^^
.. variable:: Sanitizers_FOUND

  True if all requested components were supported.

.. variable:: Sanitizers_ASAN_FOUND

  True if the compiler supports ASAN.

.. variable:: Sanitizers_LSAN_FOUND

  True if the compiler supports LSAN.

.. variable:: Sanitizers_UBSAN_FOUND

  True if the compiler supports UBSAN.

.. variable:: Sanitizers_MSAN_FOUND

  True if the compiler supports MSAN.

.. variable:: Sanitizers_FUZZER_FOUND

  True if the compiler supports libFuzzer.

Imported Targets
^^^^^^^^^^^^^^^^
Because UBSan is compatible with all other sanitizers, it does not receive an aggregated target.

  ``Sanitizers::ASAN``

  Enables all Address Sanitizer compatible sanitizers, namely LSan and UBSan, and optimal stacktrace flags.

  ``Sanitizers::TSAN``

  Enables all Thread Sanitizer compatible sanitizers, UBSan, and optimal stacktrace flags.

  ``Sanitizers::MSAN``

  Enables all Memory Sanitizer compatible sanitizers, UBSan, and optimal stacktrace flags.

  ``Sanitizers::Fuzzer``

  Enables only LibFuzzer. If the sanitizer could not be found, the interface target is created with no flags.
  .. note:: Be sure to define ``int LLVMFuzzerTestOneInput(const uint8_t* data, size_t size)`` with C linkage
  and return 0.

  ``Sanitizers::Address``

  Enables only Address Sanitizer. If the sanitizer could not be found, the interface target is created with no flags.
  .. see:: google_asan_docs_ gcc_asan_docs_ clang_asan_docs_ msvc_asan_docs_

  ``Sanitizers::Leak``

  Enables only Leak Sanitizer. If the sanitizer could not be found, the interface target is created with no flags.

  ``Sanitizers::Undefined``

  Enables only Undefined Behavior Sanitizer. If the sanitizer could not be found, the interface target is created with
  no flags.

  ``Sanitizers::Memory``

  Enables only Memory Sanitizer. If the sanitizer could not be found, the interface target is created with no flags.

  ``Sanitizers::DebugFlags``

  Enables the compiler flags required to produce the optimal stacktrace on failure.
#]=======================================================================]
cmake_minimum_required(VERSION 3.13) # target_link_options
include_guard(GLOBAL)
include(CheckCCompilerFlag)

# Set default components to ASAN if none specified
if (NOT Sanitizers_FIND_COMPONENTS)
  set(Sanitizers_FIND_COMPONENTS ASAN)
endif()

# ============================================================================ #
# Address Sanitizer
# ============================================================================ #
# Check the possible compile flags
foreach(flag IN ITEMS /fsanitize=address -fsanitize=address -fsanitize-address-use-after-scope)
check_c_compiler_flag("${flag}" hasFlag)
if (hasFlag)
  list(APPEND Sanitizers_ADDRESS_FLAGS ${flag})
endif()
# Unconditionally add library with required compile flags. Targets starting with dot are hidden by some generators.
add_library(.sanitizers_address INTERFACE)
target_compile_options(.sanitizers_address INTERFACE ${Sanitizers_ADDRESS_FLAGS})
if (Sanitizers_ADDRESS_FLAGS)
  # If any flags worked, mark that we found ASAN
  set(Sanitizers_ASAN_FOUND TRUE)
  if (NOT MSVC)
    # Non-MSVC sanitizers require a link option
    target_link_options(.sanitizers_address INTERFACE -fsanitize=address)
  endif()
endif()
# Create alias that caller will use
add_library(Sanitizers::Address ALIAS .sanitizers_address)

# ============================================================================ #
# Leak Sanitizer
# ============================================================================ #
# Check the possible compile flags
foreach(flag IN ITEMS /fsanitize=leak -fsanitize=leak)
  check_c_compiler_flag("${flag}" hasFlag)
  if (hasFlag)
    list(APPEND Sanitizers_LEAK_FLAGS ${flag})
  endif()
endforeach()
# Unconditionally add library with required compile flags. Targets starting with dot are hidden by some generators.
add_library(.sanitizers_leak INTERFACE)
target_compile_options(.sanitizers_leak INTERFACE ${Sanitizers_LEAK_FLAGS})
if (Sanitizers_LEAK_FLAGS)
  # If any flags worked, mark that we found LSAN
  set(Sanitizers_LSAN_FOUND TRUE)
  if (NOT MSVC)
    # Non-MSVC sanitizers require a link option
    target_link_options(.sanitizers_leak INTERFACE -fsanitize=leak)
  endif()
endif()
# Create alias that caller will use
add_library(Sanitizers::Leak ALIAS .sanitizers_leak)

# ============================================================================ #
# Undefined Behavior Sanitizer
# ============================================================================ #
# Check the possible compile flags
foreach(flag IN ITEMS /fsanitize=undefined -fsanitize=undefined)
  check_c_compiler_flag("${flag}" hasFlag)
  if (hasFlag)
    list(APPEND Sanitizers_UNDEFINED_BEHAVIOR_FLAGS ${flag})
  endif()
endforeach()
# Unconditionally add library with required compile flags. Targets starting with dot are hidden by some generators.
add_library(.sanitizers_undefined INTERFACE)
target_compile_options(.sanitizers_undefined INTERFACE ${Sanitizers_UNDEFINED_FLAGS})
if (Sanitizers_UNDEFINED_FLAGS)
  # If any flags worked, mark that we found UBSAN
  set(Sanitizers_UBSAN_FOUND TRUE)
  if (NOT MSVC)
    # Non-MSVC sanitizers require a link option
    target_link_options(.sanitizers_undefined INTERFACE -fsanitize=undefined)
  endif()
endif()
# Create alias that caller will use
add_library(Sanitizers::Undefined ALIAS .sanitizers_undefined)

# ============================================================================ #
# Thread Sanitizer
# ============================================================================ #
# Check the possible compile flags
foreach(flag IN ITEMS /fsanitize=thread -fsanitize=thread)
  check_c_compiler_flag("${flag}" hasFlag)
  if (hasFlag)
    list(APPEND Sanitizers_THREAD_FLAGS ${flag})
  endif()
endforeach()
# Unconditionally add library with required compile flags. Targets starting with dot are hidden by some generators.
add_library(.sanitizers_thread INTERFACE)
target_compile_options(.sanitizers_thread INTERFACE ${Sanitizers_THREAD_FLAGS})
if (Sanitizers_THREAD_FLAGS)
  # If any flags worked, mark that we found TSAN
  set(Sanitizers_TSAN_FOUND TRUE)
  if (NOT MSVC)
    # Non-MSVC sanitizers require a link option
    target_link_options(.sanitizers_thread INTERFACE -fsanitize=thread)
  endif()
endif()
# Create alias that caller will use
add_library(Sanitizers::Thread ALIAS .sanitizers_thread)

# ============================================================================ #
# Memory Sanitizer
# ============================================================================ #
# Check the possible compile flags
foreach(flag IN ITEMS /fsanitize=memory -fsanitize=memory)
  check_c_compiler_flag("${flag}" hasFlag)
  if (hasFlag)
    list(APPEND Sanitizers_MEMORY_FLAGS ${flag})
  endif()
endforeach()
# Unconditionally add library with required compile flags. Targets starting with dot are hidden by some generators.
add_library(.sanitizers_memory INTERFACE)
target_compile_options(.sanitizers_memory INTERFACE ${Sanitizers_MEMORY_FLAGS})
if (Sanitizers_MEMORY_FLAGS)
  # If any flags worked, mark that we found TSAN
  set(Sanitizers_MSAN_FOUND TRUE)
  if (NOT MSVC)
    # Non-MSVC sanitizers require a link option
    target_link_options(.sanitizers_memory INTERFACE -fsanitize=memory)
  endif()
endif()
# Create alias that caller will use
add_library(Sanitizers::Memory ALIAS .sanitizers_memory)

# ============================================================================ #
# libFuzzer
# ============================================================================ #
# Check the possible compile flags
foreach(flag IN ITEMS /fsanitize=fuzzer -fsanitize=fuzzer)
  check_c_compiler_flag("${flag}" hasFlag)
  if (hasFlag)
    list(APPEND Sanitizers_FUZZER_FLAGS ${flag})
  endif()
endforeach()
# Unconditionally add library with required compile flags. Targets starting with dot are hidden by some generators.
add_library(.sanitizers_fuzzer INTERFACE)
target_compile_options(.sanitizers_fuzzer INTERFACE ${Sanitizers_FUZZER_FLAGS})
if (Sanitizers_FUZZER_FLAGS)
  # If any flags worked, mark that we found TSAN
  set(Sanitizers_FUZZER_FOUND TRUE)
  if (NOT MSVC)
    # Non-MSVC sanitizers require a link option
    target_link_options(.sanitizers_fuzzer INTERFACE -fsanitize=fuzzer)
  endif()
endif()
# Create alias that caller will use
add_library(Sanitizers::Fuzzer ALIAS .sanitizers_fuzzer)

# ============================================================================ #
# Stacktrace Flags
# ============================================================================ #
# Check the possible compile flags
foreach(flag IN ITEMS -fno-optimize-sibling-calls -fno-omit-frame-pointer -g /Zi)
  check_c_compiler_flag("${flag}" hasFlag)
  if (hasFlag)
    list(APPEND SANITIZER_DEBUG_FLAGS ${flag})
  endif()
endforeach()
# Unconditionally add library with required compile flags. Targets starting with dot are hidden by some generators.
add_library(.sanitizers_debug_flags INTERFACE)
target_compile_options(.sanitizers_debug_flags INTERFACE ${SANITIZER_DEBUG_FLAGS})
# Create alias that caller will use
add_library(Sanitizers::DebugFlags ALIAS .sanitizers_debug_flags)

# ============================================================================ #
# Aggregate Targets
# ============================================================================ #
# Create library for all ASAN compatible sanitizers
add_library(.sanitizers_asan INTERFACE)
target_link_libraries(.sanitizers_asan
  INTERFACE
    Sanitizers::Address
    Sanitizers::Leak
    Sanitizers::Undefined
    Sanitizers::DebugFlags
)
add_library(Sanitizers::ASAN ALIAS .sanitizers_asan)

# Create library for all TSAN compatible sanitizers
add_library(.sanitizers_tsan INTERFACE)
target_link_libraries(.sanitizers_tsan
  INTERFACE
    Sanitizers::Thread
    Sanitizers::Undefined
    Sanitizers::DebugFlags
)
add_library(Sanitizers::TSAN ALIAS .sanitizers_tsan)

# Create library for all MSAN compatible sanitizers
add_library(.sanitizers_msan INTERFACE)
target_link_libraries(.sanitizers_msan
  INTERFACE
    Sanitizers::Memory
    Sanitizers::Undefined
    Sanitizers::DebugFlags
)
add_library(Sanitizers::MSAN ALIAS .sanitizers_msan)

# ============================================================================ #
# Auto-Declare Global Project Options
# ============================================================================ #
option(${PROJECT_NAME}_ENABLE_ASAN "Globally enables Address, Leak, and Undefined Behavior sanitizers" OFF)
option(${PROJECT_NAME}_ENABLE_TSAN "Globally enables Thread and Undefined Behavior sanitizers" OFF)
option(${PROJECT_NAME}_ENABLE_MSAN "Globally enables Memory and Undefined Behavior sanitizers" OFF)

# Let CMake handle the details
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Sanitizers
  HANDLE_COMPONENTS
)

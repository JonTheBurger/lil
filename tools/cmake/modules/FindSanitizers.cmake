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
    add_asan_options()
  endif()

  # Example 2: Enable Fuzz testing for an executable with libfuzzer
  find_package(Sanitizers)
  target_link_libraries(MyFuzzTest PRIVATE Sanitizers::Fuzzer)

Components
^^^^^^^^^^
* ``ASAN``: check for ASAN support.
* ``LSAN``: check for LSAN support.
* ``UBSAN``: check for UBSAN support.
* ``TSAN``: check for TSAN support.
* ``MSAN``: check for MSAN support.
* ``FUZZER``: check for libFuzzer support.

If no ``COMPONENTS`` are specified, only ``ASAN`` is verified for validity.

Result Variables
^^^^^^^^^^^^^^^^
.. variable:: Sanitizers_FOUND

  True if all requested components were supported.

.. variable:: Sanitizers_ASAN_FOUND

  True if the compiler supports ASAN.

.. variable:: Sanitizers_ADDRESS_FLAGS

  Compiler flags required for address sanitizer. Additional linker flags may be required.

.. variable:: Sanitizers_LSAN_FOUND

  True if the compiler supports LSAN.

.. variable:: Sanitizers_LEAK_FLAGS

  Compiler flags required for leak sanitizer. Additional linker flags may be required.

.. variable:: Sanitizers_UBSAN_FOUND

  True if the compiler supports UBSAN.

.. variable:: Sanitizers_UNDEFINED_FLAGS

  Compiler flags required for undefined behavior sanitizer. Additional linker flags may be required.

.. variable:: Sanitizers_TSAN_FOUND

  True if the compiler supports TSAN.

.. variable:: Sanitizers_THREAD_FLAGS

  Compiler flags required for thread sanitizer. Additional linker flags may be required.

.. variable:: Sanitizers_MSAN_FOUND

  True if the compiler supports MSAN.

.. variable:: Sanitizers_MEMORY_FLAGS

  Compiler flags required for memory sanitizer. Additional linker flags may be required.

.. variable:: Sanitizers_FUZZER_FOUND

  True if the compiler supports libFuzzer.

.. variable:: Sanitizers_FUZZER_FLAGS

  Compiler flags required for libfuzzer. Additional linker flags may be required.

.. variable:: Sanitizers_DEBUG_FLAGS

  Compiler flags required for sanitizers to produce a proper backtrace on error. Additional linker flags may be
  required.

Imported Targets
^^^^^^^^^^^^^^^^
  ``Sanitizers::Fuzzer``

  Enables only LibFuzzer. If the sanitizer could not be found, the interface target is created with no flags.
  .. note:: Be sure to define ``int LLVMFuzzerTestOneInput(const uint8_t* data, size_t size)`` with C linkage
  and return 0.

  ``Sanitizers::DebugFlags``

  Enables the compiler flags required to produce the optimal stacktrace on failure.

Functions
^^^^^^^^^
#]=======================================================================]
cmake_minimum_required(VERSION 3.13) # add_link_options
include_guard(GLOBAL)
include(CheckCCompilerFlag)
include(CMakePushCheckState)

# Set default components to ASAN if none specified
if (NOT Sanitizers_FIND_COMPONENTS)
  set(Sanitizers_FIND_COMPONENTS ASAN)
endif()

# ============================================================================ #
# Address Sanitizer
# ============================================================================ #
# Check the possible compile flags
foreach(flag IN ITEMS /fsanitize=address -fsanitize=address -fsanitize-address-use-after-scope)
  # check_c_compiler_flag prints the flag variable being tested. Create a descriptive variable for the user.
  string(MAKE_C_IDENTIFIER ${flag}_cflag_supported this_cflag_supported)
  cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_FLAGS ${flag})
  check_c_compiler_flag(${flag} ${this_cflag_supported})
  if (${this_cflag_supported})
    # If any flags worked, mark that we found ASAN
    set(Sanitizers_ASAN_FOUND TRUE)
    list(APPEND Sanitizers_ADDRESS_FLAGS ${flag})
  endif()
  cmake_pop_check_state(RESET)
  # check_c_compiler_flag creates a CACHE variable. Clear it so we can reuse the variable.
  set(${this_cflag_supported} "" CACHE INTERNAL "" FORCE)
endforeach()

#[=======================================================================[.rst:
.. command:: add_address_sanitizer_options

  Adds necessary compiler and linker flags for address sanitizer to all targets declared in this directory and below.

  Signatures::

    add_address_sanitizer_options()

  Example usage:

.. code-block:: cmake

  add_address_sanitizer_options()
#]=======================================================================]
function(add_address_sanitizer_options)
  if (NOT Sanitizers_ASAN_FOUND)
    list(APPEND CMAKE_MESSAGE_INDENT "[FindSanitizers::add_address_sanitizer_options] ")
    message(WARNING "Ignoring attempt to add missing sanitizer")
    return()
  endif()

  add_compile_options(${Sanitizers_ADDRESS_FLAGS})
  if (NOT MSVC)
    # Non-MSVC sanitizers require a link option
    add_link_options(-fsanitize=address)
  endif()

  set(CMAKE_XCODE_GENERATE_SCHEME ON)
  set(CMAKE_XCODE_SCHEME_ADDRESS_SANITIZER ON)
  set(CMAKE_XCODE_SCHEME_ADDRESS_SANITIZER_USE_AFTER_RETURN ON)
endfunction()

# ============================================================================ #
# Leak Sanitizer
# ============================================================================ #
# Check the possible compile flags
foreach(flag IN ITEMS /fsanitize=leak -fsanitize=leak)
  # check_c_compiler_flag prints the flag variable being tested. Create a descriptive variable for the user.
  string(MAKE_C_IDENTIFIER ${flag}_cflag_supported this_cflag_supported)
  cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_FLAGS ${flag})
  check_c_compiler_flag(${flag} ${this_cflag_supported})
  if (${this_cflag_supported})
    # If any flags worked, mark that we found LSAN
    set(Sanitizers_LSAN_FOUND TRUE)
    list(APPEND Sanitizers_LEAK_FLAGS ${flag})
  endif()
  cmake_pop_check_state(RESET)
  # check_c_compiler_flag creates a CACHE variable. Clear it so we can reuse the variable.
  set(${this_cflag_supported} "" CACHE INTERNAL "" FORCE)
endforeach()

#[=======================================================================[.rst:
.. command:: add_leak_sanitizer_options

  Adds necessary compiler and linker flags for leak sanitizer to all targets declared in this directory and below.

  Signatures::

    add_leak_sanitizer_options()

  Example usage:

.. code-block:: cmake

  add_leak_sanitizer_options()
#]=======================================================================]
function(add_leak_sanitizer_options)
  if (NOT Sanitizers_LSAN_FOUND)
    list(APPEND CMAKE_MESSAGE_INDENT "[FindSanitizers::add_leak_sanitizer_options] ")
    message(WARNING "Ignoring attempt to add missing sanitizer")
    return()
  endif()

  add_compile_options(${Sanitizers_LEAK_FLAGS})
  if (NOT MSVC)
    # Non-MSVC sanitizers require a link option
    add_link_options(-fsanitize=leak)
  endif()
endfunction()

# ============================================================================ #
# Undefined Behavior Sanitizer
# ============================================================================ #
# Check the possible compile flags
foreach(flag IN ITEMS /fsanitize=undefined -fsanitize=undefined)
  # check_c_compiler_flag prints the flag variable being tested. Create a descriptive variable for the user.
  string(MAKE_C_IDENTIFIER ${flag}_cflag_supported this_cflag_supported)
  cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_FLAGS ${flag})
  check_c_compiler_flag(${flag} ${this_cflag_supported})
  if (${this_cflag_supported})
    # If any flags worked, mark that we found UBSAN
    set(Sanitizers_UBSAN_FOUND TRUE)
    list(APPEND Sanitizers_UNDEFINED_FLAGS ${flag})
  endif()
  cmake_pop_check_state(RESET)

  # check_c_compiler_flag creates a CACHE variable. Clear it so we can reuse the variable.
  set(${this_cflag_supported} "" CACHE INTERNAL "" FORCE)
endforeach()

#[=======================================================================[.rst:
.. command:: add_undefined_sanitizer_options

  Adds necessary compiler and linker flags for undefined behavior sanitizer to all targets declared in this directory
  and below.

  Signatures::

    add_undefined_sanitizer_options()

  Example usage:

.. code-block:: cmake

  add_undefined_sanitizer_options()
#]=======================================================================]
function(add_undefined_sanitizer_options)
  if (NOT Sanitizers_UBSAN_FOUND)
    list(APPEND CMAKE_MESSAGE_INDENT "[FindSanitizers::add_undefined_sanitizer_options] ")
    message(WARNING "Ignoring attempt to add missing sanitizer")
    return()
  endif()

  add_compile_options(${Sanitizers_UNDEFINED_FLAGS})
  if (NOT MSVC)
    # Non-MSVC sanitizers require a link option
    add_link_options(-fsanitize=undefined)
  endif()

  set(CMAKE_XCODE_GENERATE_SCHEME ON)
  set(CMAKE_XCODE_SCHEME_UNDEFINED_BEHAVIOUR_SANITIZER ON)
  set(CMAKE_XCODE_SCHEME_UNDEFINED_BEHAVIOUR_SANITIZER_STOP ON)
endfunction()

# ============================================================================ #
# Thread Sanitizer
# ============================================================================ #
# Check the possible compile flags
foreach(flag IN ITEMS /fsanitize=thread -fsanitize=thread)
  # check_c_compiler_flag prints the flag variable being tested. Create a descriptive variable for the user.
  string(MAKE_C_IDENTIFIER ${flag}_cflag_supported this_cflag_supported)
  cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_FLAGS ${flag})
  check_c_compiler_flag(${flag} ${this_cflag_supported})
  if (${this_cflag_supported})
    # If any flags worked, mark that we found TSAN
    set(Sanitizers_TSAN_FOUND TRUE)
    list(APPEND Sanitizers_THREAD_FLAGS ${flag})
  endif()
  cmake_pop_check_state(RESET)
  # check_c_compiler_flag creates a CACHE variable. Clear it so we can reuse the variable.
  set(${this_cflag_supported} "" CACHE INTERNAL "" FORCE)
endforeach()

#[=======================================================================[.rst:
.. command:: add_thread_sanitizer_options

  Adds necessary compiler and linker flags for thread sanitizer to all targets declared in this directory and below.

  Signatures::

    add_thread_sanitizer_options()

  Example usage:

.. code-block:: cmake

  add_thread_sanitizer_options()
#]=======================================================================]
function(add_thread_sanitizer_options)
  if (NOT Sanitizers_TSAN_FOUND)
    list(APPEND CMAKE_MESSAGE_INDENT "[FindSanitizers::add_thread_sanitizer_options] ")
    message(WARNING "Ignoring attempt to add missing sanitizer")
    return()
  endif()

  add_compile_options(${Sanitizers_THREAD_FLAGS})
  if (NOT MSVC)
    # Non-MSVC sanitizers require a link option
    add_link_options(-fsanitize=thread)
  endif()

  set(CMAKE_XCODE_GENERATE_SCHEME ON)
  set(CMAKE_XCODE_SCHEME_THREAD_SANITIZER ON)
  set(CMAKE_XCODE_SCHEME_THREAD_SANITIZER_STOP ON)
endfunction()

# ============================================================================ #
# Memory Sanitizer
# ============================================================================ #
# Check the possible compile flags
foreach(flag IN ITEMS /fsanitize=memory -fsanitize=memory)
  # check_c_compiler_flag prints the flag variable being tested. Create a descriptive variable for the user.
  string(MAKE_C_IDENTIFIER ${flag}_cflag_supported this_cflag_supported)

  cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_FLAGS ${flag})
  check_c_compiler_flag(${flag} ${this_cflag_supported})

  if (${this_cflag_supported})
    # If any flags worked, mark that we found MSAN
    set(Sanitizers_MSAN_FOUND TRUE)
    list(APPEND Sanitizers_MEMORY_FLAGS ${flag})
  endif()

  cmake_pop_check_state(RESET)

  # check_c_compiler_flag creates a CACHE variable. Clear it so we can reuse the variable.
  set(${this_cflag_supported} "" CACHE INTERNAL "" FORCE)
endforeach()

#[=======================================================================[.rst:
.. command:: add_memory_sanitizer_options

  Adds necessary compiler and linker flags for memory sanitizer to all targets declared in this directory and below.

  Signatures::

    add_memory_sanitizer_options()

  Example usage:

.. code-block:: cmake

  add_memory_sanitizer_options()
#]=======================================================================]
function(add_memory_sanitizer_options)
  if (NOT Sanitizers_MSAN_FOUND)
    list(APPEND CMAKE_MESSAGE_INDENT "[FindSanitizers::add_memory_sanitizer_options] ")
    message(WARNING "Ignoring attempt to add missing sanitizer")
    return()
  endif()

  add_compile_options(${Sanitizers_MEMORY_FLAGS})
  if (NOT MSVC)
    # Non-MSVC sanitizers require a link option
    add_link_options(-fsanitize=memory)
  endif()
endfunction()

# ============================================================================ #
# libFuzzer
# ============================================================================ #
# Check the possible compile flags
foreach(flag IN ITEMS /fsanitize=fuzzer -fsanitize=fuzzer)
  cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_FLAGS ${flag})
  string(MAKE_C_IDENTIFIER ${flag}_cflag_supported this_cflag_supported)
  check_c_compiler_flag(${flag} ${this_cflag_supported})
  if (${this_cflag_supported})
    list(APPEND Sanitizers_FUZZER_FLAGS ${flag})
    set(${this_cflag_supported} "" CACHE INTERNAL "" FORCE)
  endif()
  cmake_pop_check_state(RESET)
endforeach()

# Unconditionally add library with required compile flags. Targets starting with dot are hidden by some generators.
add_library(.sanitizers_fuzzer INTERFACE)
target_compile_options(.sanitizers_fuzzer INTERFACE ${Sanitizers_FUZZER_FLAGS})
if (Sanitizers_FUZZER_FLAGS)
  # If any flags worked, mark that we found FUZZER
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
  cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_FLAGS ${flag})
  string(MAKE_C_IDENTIFIER ${flag}_cflag_supported this_cflag_supported)
  check_c_compiler_flag(${flag} ${this_cflag_supported})
  if (${this_cflag_supported})
    list(APPEND Sanitizers_DEBUG_FLAGS ${flag})
    set(${this_cflag_supported} "" CACHE INTERNAL "" FORCE)
  endif()
  cmake_pop_check_state(RESET)
endforeach()

# Unconditionally add library with required compile flags. Targets starting with dot are hidden by some generators.
add_library(.sanitizers_debug_flags INTERFACE)
target_compile_options(.sanitizers_debug_flags INTERFACE ${Sanitizers_DEBUG_FLAGS})
# Create alias that caller will use
add_library(Sanitizers::DebugFlags ALIAS .sanitizers_debug_flags)

#[=======================================================================[.rst:
.. command:: add_sanitizer_debug_options

  Adds necessary compiler and linker flags for sanitizers to produce proper stacktraces when an error is detected.

  Signatures::

    add_sanitizer_debug_options()

  Example usage:

.. code-block:: cmake

  add_sanitizer_debug_options()
#]=======================================================================]
function(add_sanitizer_debug_options)
  if (NOT Sanitizers_DEBUG_FLAGS)
    list(APPEND CMAKE_MESSAGE_INDENT "[FindSanitizers::add_sanitizer_debug_options] ")
    message(WARNING "Ignoring attempt to add missing sanitizer")
    return()
  endif()

  add_compile_options(${Sanitizers_DEBUG_FLAGS})
endfunction()

# ============================================================================ #
# Aggregate Functions
# ============================================================================ #
#[=======================================================================[.rst:
.. command:: add_asan_options

  Adds compiler and linker flags for address sanitizer and all compatible sanitizers to all targets declared in this
  directory and below.

  Signatures::

    add_asan_options()

  Example usage:

.. code-block:: cmake

  add_asan_options()
#]=======================================================================]
function(add_asan_options)
  add_address_sanitizer_options()
  add_leak_sanitizer_options()
  add_undefined_sanitizer_options()
  add_sanitizer_debug_options()
endfunction()

#[=======================================================================[.rst:
.. command:: add_tsan_options

  Adds compiler and linker flags for thread sanitizer and all compatible sanitizers to all targets declared in this
  directory and below.

  Signatures::

    add_tsan_options()

  Example usage:

.. code-block:: cmake

  add_tsan_options()
#]=======================================================================]
function(add_tsan_options)
  add_thread_sanitizer_options()
  add_undefined_sanitizer_options()
  add_sanitizer_debug_options()
endfunction()

#[=======================================================================[.rst:
.. command:: add_msan_options

  Adds compiler and linker flags for memory sanitizer and all compatible sanitizers to all targets declared in this
  directory and below.

  Signatures::

    add_msan_options()

  Example usage:

.. code-block:: cmake

  add_msan_options()
#]=======================================================================]
function(add_msan_options)
  add_memory_sanitizer_options()
  add_undefined_sanitizer_options()
  add_sanitizer_debug_options()
endfunction()

# ============================================================================ #
# Find Package
# ============================================================================ #
# Let CMake handle the details
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Sanitizers
  HANDLE_COMPONENTS
)

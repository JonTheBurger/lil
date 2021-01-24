#!cmake -P
#[=======================================================================[.rst:
FindSRecord
-----------

.. _SRecord: http://srecord.sourceforge.net/
.. _srec_cat: http://srecord.sourceforge.net/man/man1/srec_cat.html
.. _srec_cmp: http://srecord.sourceforge.net/man/man1/srec_cmp.html
.. _srec_info: http://srecord.sourceforge.net/man/man1/srec_info.html

Find the SRecord_ Tools for manipulating binary firmware files.

Components
^^^^^^^^^^
* ``cat``: search for srec_cat_.
* ``cmp``: search for srec_cmp_.
* ``info``: search for srec_info_.

If no ``COMPONENTS`` are specified, ``cat``, ``cmp``, and ``info`` are assumed.

Cache Variables
^^^^^^^^^^^^^^^
.. variable:: SRecord_ROOT

  Additional paths to search for srecord tools

.. variable:: SRecord_cat_EXECUTABLE

  Path to the srec_cat_ executable used to concatenate binary files.

.. variable:: SRecord_cmp_EXECUTABLE

  Path to the srec_cmp_ executable used to compare binary files for equality.

.. variable:: SRecord_info_EXECUTABLE

  Path to the srec_info_ executable used to concatenate binary files.

Result Variables
^^^^^^^^^^^^^^^^
.. variable:: SRecord_FOUND

  True if all requested components were found

.. variable:: SRecord_cat_FOUND

  True if the srec_cat_ executable was found successfully.

.. variable:: SRecord_cmp_FOUND

  True if the srec_cmp_ executable was found successfully.

.. variable:: SRecord_info_FOUND

  True if the srec_info_ executable was found successfully.

.. variable:: SRecord_VERSION

  Semantic version string of srec tools

.. variable:: SRecord_VERSION_MAJOR

  Major version; increment indicates breaking changes

.. variable:: SRecord_VERSION_MINOR

  Minor version; incrememnt indicates new features

Imported Targets
^^^^^^^^^^^^^^^^
  ``SRecord::cat``

  .. see:: :variable:`SRecord_cat_EXECUTABLE`

  ``SRecord::cmp``

  .. see:: :variable:`SRecord_cmp_EXECUTABLE`

  ``SRecord::info``

  .. see:: :variable:`SRecord_info_EXECUTABLE`

Example Usages:

.. code-block:: cmake

  find_package(SRecord VERSION 1.64)
#]=======================================================================]
cmake_minimum_required(VERSION 3.14)
include_guard(GLOBAL)

# CMAKE_FIND_PACKAGE_NAME is not set if used via `cmake -P <script>`; deduce from file name
get_filename_component(CMAKE_FIND_PACKAGE_NAME ${CMAKE_CURRENT_LIST_FILE} NAME_WLE)
string(SUBSTRING ${CMAKE_FIND_PACKAGE_NAME} 4 -1 CMAKE_FIND_PACKAGE_NAME)
# Helps give a hint to user explaining how to plug in a custom install location if necessary
set(${CMAKE_FIND_PACKAGE_NAME}_ROOT "" CACHE PATH "Additional paths searched to find ${CMAKE_FIND_PACKAGE_NAME}")
# Check if we're running in a project (or e.g. via `cmake -P <script>`)
get_property(cmakeRole GLOBAL PROPERTY CMAKE_ROLE)

# Set default components to all if none specified
if (NOT ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
  set(${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS cat cmp info)
endif()

# Find each of the components
foreach(component ${${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS})
  # CMake 3.12+ automatically checks paths in <PackageName>_ROOT (both CMake & env var)
  find_program(${CMAKE_FIND_PACKAGE_NAME}_${component}_EXECUTABLE
    srec_${component}
  )

  # If the executable was successfully found:
  if (${CMAKE_FIND_PACKAGE_NAME}_${component}_EXECUTABLE)
    # Set component as found; each find component must be found for the full package to be considered found
    set(${CMAKE_FIND_PACKAGE_NAME}_${component}_FOUND TRUE)
    mark_as_advanced(${CMAKE_FIND_PACKAGE_NAME}_${component}_EXECUTABLE)

    # Add imported executable; enables running `cmake -P` for standalone package searching
    if (cmakeRole STREQUAL "PROJECT" AND NOT TARGET ${CMAKE_FIND_PACKAGE_NAME}::${component})
      add_executable(${CMAKE_FIND_PACKAGE_NAME}::${component} IMPORTED)
      set_property(
        TARGET ${CMAKE_FIND_PACKAGE_NAME}::${component}
        PROPERTY IMPORTED_LOCATION "${${CMAKE_FIND_PACKAGE_NAME}_${component}_EXECUTABLE}"
      )
    endif()

    # Parse version from first executable we discover
    if (NOT ${CMAKE_FIND_PACKAGE_NAME}_VERSION)
      # Run `<program> --version`
      execute_process(
        COMMAND ${${CMAKE_FIND_PACKAGE_NAME}_${component}_EXECUTABLE} --version
        OUTPUT_VARIABLE packageVersion
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
      )

      # Parse the version
      string(REGEX MATCH "[0-9]+(\.[0-9]+)*" ${CMAKE_FIND_PACKAGE_NAME}_VERSION "${packageVersion}")
      # Pad with zeroes so minor/patch/tweak are filled in automatically; no major becomes error; convert to list
      string(REPLACE "." ";" versionNumbers "${${CMAKE_FIND_PACKAGE_NAME}_VERSION}.0.0.0")
      list(GET versionNumbers 0 ${CMAKE_FIND_PACKAGE_NAME}_VERSION_MAJOR)
      list(GET versionNumbers 1 ${CMAKE_FIND_PACKAGE_NAME}_VERSION_MINOR)
      list(GET versionNumbers 2 ${CMAKE_FIND_PACKAGE_NAME}_VERSION_PATCH)
      list(GET versionNumbers 3 ${CMAKE_FIND_PACKAGE_NAME}_VERSION_TWEAK)
    endif()
  endif()
endforeach()

# Let CMake handle the details
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(${CMAKE_FIND_PACKAGE_NAME}
  HANDLE_COMPONENTS
  HANDLE_VERSION_RANGE
  NAME_MISMATCHED
  REASON_FAILURE_MESSAGE
    "Ubuntu: Consider running `sudo apt-get install srecord`"
  VERSION_VAR
    ${CMAKE_FIND_PACKAGE_NAME}_VERSION
)

# Hide <PackageName>_ROOT only if package is found
if (${CMAKE_FIND_PACKAGE_NAME_FOUND})
  mark_as_advanced(${CMAKE_FIND_PACKAGE_NAME}_ROOT)
endif()

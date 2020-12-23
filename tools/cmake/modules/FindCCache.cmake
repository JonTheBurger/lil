#[=======================================================================[.rst:
FindCCache
----------

.. _ccache: https://ccache.dev/

Enables ccache_ compiler caching, if available.

Cache Variables
^^^^^^^^^^^^^^^

.. variable:: CCACHE_ENABLE

  User toggle for enabling/disabling ccache. Defaults to ``ON``.

Example Usages:

.. code-block:: cmake

  find_package(CCache)
#]=======================================================================]
cmake_minimum_required(VERSION 3.4)
if (_findCCacheIncluded)
  return()
endif()
set(_findCCacheIncluded TRUE)

option(CCACHE_ENABLE "Use compiler caching to speed up recompilation" ON)

find_program(CCACHE_EXECUTABLE ccache)
if (CCACHE_EXECUTABLE AND CCACHE_ENABLE)
  set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ${CCACHE_EXECUTABLE})
  set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK ${CCACHE_EXECUTABLE})
endif()

cmake_minimum_required(VERSION 3.11)

# On parse, add default build types as combobox entries if not present
get_property(buildTypes CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS)
if (NOT buildTypes)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS Debug Release RelWithDebInfo MinSizeRel)
endif()

function(add_build_conf)
  set(optArgs)
  set(oneValueArgs NAME)
  set(multiValueArgs FLAGS)
  cmake_parse_arguments(arg "${optArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  if (NOT arg_NAME)
    message(FATAL_ERROR "add_build_conf(...) requires: NAME <argument>")
  endif()

  # Add to CMAKE_BUILD_TYPE comobobx
  get_property(buildTypes CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS)
  if (NOT "${arg_NAME}" IN_LIST buildTypes)
    list(APPEND buildTypes "${arg_NAME}")
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS ${buildTypes})
  endif()

  # Add to CMAKE_CONFIGURATION_TYPES
  get_property(isMultiConf GLOBAL PROPERTY GENERATOR_IS_MULTICONFIG)
  if (isMultiConf)
    if (NOT "${arg_NAME}" IN_LIST CMAKE_CONFIGURATION_TYPES)
      list(APPEND CMAKE_CONFIGURATION_TYPES "${arg_NAME}")
      string(TOUPPER ${arg_NAME} uppername)
      string(TOLOWER ${arg_NAME} lowername)
      set(CMAKE_${uppername}_POSTFIX _${lowername})
    endif()
  endif()
endfunction()

function(set_default_build_type)
  get_property(buildTypes CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS)
  if (NOT ARGV0)
    message(FATAL_ERROR "set_default_build_type(...) requires oneof: {${buildTypes}}")
  endif()

  if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE ${ARGV0} CACHE STRING "" FORCE)
  endif()
endfunction()

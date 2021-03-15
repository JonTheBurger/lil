function(target_split_debug)
  list(APPEND CMAKE_MESSAGE_INDENT "[FindDebugger::target_split_debug] ")
  message(VERBOSE "(${ARGV})")
  set(optArgs)
  set(oneValueArgs TARGET)
  set(multiValueArgs)
  cmake_parse_arguments(arg "${optArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if (CMAKE_C_COMPILER_ID MATCHES "GNU" OR CMAKE_C_COMPILER_ID MATCHES "Clang")
    if (NOT CMAKE_OBJCOPY)
      message(FATAL_ERROR "CMAKE_OBJCOPY must be set (e.g. `find_program(CMAKE_OBJCOPY objcopy)`)")
    endif()

    get_property(targetLocation TARGET ${arg_TARGET} PROPERTY LOCATION)
    add_custom_command(
      TARGET ${arg_TARGET}
      POST_BUILD
      WORKING_DIRECTORY ${targetLocation}
      COMMAND ${CMAKE_OBJCOPY} --only-keep-debug ${arg_TARGET} ${arg_TARGET}.debug
      COMMAND ${CMAKE_OBJCOPY} --strip-debug ${arg_TARGET}
      COMMAND ${CMAKE_OBJCOPY} --add-gnu-debuglink=${arg_TARGET}.debug
      COMMENT "Generating debug link ${arg_TARGET}.debug for ${arg_TARGET}"
    )
  endif()
endfunction()

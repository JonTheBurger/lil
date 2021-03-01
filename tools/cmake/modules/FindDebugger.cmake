function(target_debug_link)
  list(APPEND CMAKE_MESSAGE_INDENT "[FindDebugger::target_debug_link] ")
  message(VERBOSE "(${ARGV})")
  set(optArgs)
  set(oneValueArgs TARGET)
  set(multiValueArgs)
  cmake_parse_arguments(arg "${optArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if (NOT CMAKE_OBJCOPY)
    message(FATAL_ERROR "CMAKE_OBJCOPY must be set (e.g. `set(CMAKE_OBJCOPY /usr/bin/objcopy)`)")
  endif()

  add_custom_command(
    TARGET ${arg_TARGET}
    POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} --only-keep-debug ${arg_TARGET} ${arg_TARGET}.debug
    COMMAND ${CMAKE_OBJCOPY} --strip-debug ${arg_TARGET}
    COMMAND ${CMAKE_OBJCOPY} --add-gnu-debuglink=${arg_TARGET}.debug
    COMMENT "Generating debug link ${arg_TARGET}.debug for ${arg_TARGET}"
  )
endfunction()

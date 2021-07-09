cmake_minimum_required(VERSION 3.13)
#[=======================================================================[.rst:
.. command:: target_weaken_symbols

  Weakens all symbols in ``target``

  Signatures::

    target_weaken_symbols(``target``)

  The options are:

  ``<target>``
  Name of the target where symbols shall be weakened.
#]=======================================================================]
function(target_weaken_symbols TARGET)
  list(APPEND CMAKE_MESSAGE_INDENT "[FindLinker::target_weaken_symbols] ")

  if (NOT CMAKE_OBJCOPY)
    message(INFO "CMAKE_OBJCOPY is not set; consider `find_program(CMAKE_OBJCOPY objcopy)`. IGNORING")
    return()
  endif()

  add_custom_command(
    TARGET ${TARGET}
    POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} --weaken-symbol=* --wildcard $<TARGET_FILE:${TARGET}>
  )
# TODO: Explain why this will always rebuild
#  get_target_property(libraryType ${TARGET} TYPE)

#  # TODO suffix from TYPE
#  set(suffix ".a")

#  add_custom_command(
#    OUTPUT  ${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.weak${suffix}
#    COMMAND ${CMAKE_OBJCOPY} --weaken-symbol=* --wildcard $<TARGET_FILE:${TARGET}> ${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.weak${suffix}
#    DEPENDS ${TARGET}
#  )

#  # TODO type from TYPE (static shared module)
#  set(type STATIC)
#  add_library(${TARGET}.weak STATIC IMPORTED GLOBAL)
#  set_target_properties(${TARGET}.weak PROPERTIES
#    IMPORTED_LOCATION ${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.weak${suffix}
#  )
endfunction()

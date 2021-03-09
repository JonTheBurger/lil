set(findPkgConfigGeneratorCMakeDir ${CMAKE_CURRENT_LIST_DIR})
set(${PROJECT_NAME}_INSTALL_PKG_CONFIG_MODULE_DIR
  "${CMAKE_INSTALL_LIBDIR}/pkgconfig"
  CACHE PATH
  "Install prefix relative directory where ${PROJECT_NAME}.pc installs to"
)
configure_file(
  ${findPkgConfigGeneratorCMakeDir}/BaseProject.pc.in
  ${PROJECT_BINARY_DIR}/${${PROJECT_NAME}_INSTALL_PKG_CONFIG_MODULE_DIR}/${PROJECT_NAME}.pc
  @ONLY
)
install(
  FILES
    ${PROJECT_BINARY_DIR}/${${PROJECT_NAME}_INSTALL_PKG_CONFIG_MODULE_DIR}/${PROJECT_NAME}.pc
  DESTINATION
    ${${PROJECT_NAME}_INSTALL_PKG_CONFIG_MODULE_DIR}
)
